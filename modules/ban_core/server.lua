-- ================================
-- MODULE: BAN_CORE
-- Gestion du système de bannissement de base
-- ================================

if not Config.Modules.BanCore then return end

BanCore = {}

-- ================================
-- VÉRIFICATION DE BAN
-- ================================

function BanCore.CheckBan(identifier, callback)
    local tableName = Utils.GetTableName("bans")
    
    MySQL.Async.fetchAll(
        ('SELECT * FROM %s WHERE identifier = @identifier'):format(tableName),
        {['@identifier'] = identifier},
        function(result)
            if not result[1] then
                callback(false, nil)
                return
            end
            
            local ban = result[1]
            local currentTime = os.time()
            
            -- Ban permanent
            if ban.permanent == 1 or ban.permanent == true then
                Utils.Log(_U('log_ban_check', identifier, "permanent"), "BAN")
                callback(true, {
                    permanent = true,
                    reason = ban.reason or Config.BanReason.permanent,
                    bannedBy = ban.banned_by or "Console",
                    banDate = ban.ban_date or Utils.GetCurrentDate(),
                    identifier = identifier
                })
                return
            end
            
            -- Ban temporaire
            local expireTime = ban.expire_time
            
            if expireTime and currentTime < expireTime then
                Utils.Log(_U('log_ban_check', identifier, "temporaire"), "TEMPBAN")
                callback(true, {
                    permanent = false,
                    reason = ban.reason or Config.BanReason.temporary,
                    bannedBy = ban.banned_by or "Console",
                    banDate = ban.ban_date or Utils.GetCurrentDate(),
                    expireTime = expireTime,
                    identifier = identifier
                })
                return
            end
            
            -- Ban expiré - suppression automatique
            BanCore.RemoveBan(identifier, function(success)
                if success then
                    Utils.Log(_U('log_ban_expire', identifier), "EXPIRE")
                end
            end)
            
            callback(false, nil)
        end
    )
end

-- ================================
-- AJOUTER UN BAN
-- ================================

function BanCore.AddBan(data, callback)
    local tableName = Utils.GetTableName("bans")
    
    -- Vérifier si déjà banni
    BanCore.CheckBan(data.identifier, function(isBanned, banInfo)
        if isBanned then
            callback(false, "already_banned")
            return
        end
        
        local query
        local params = {
            ['@identifier'] = data.identifier,
            ['@reason'] = data.reason,
            ['@banned_by'] = data.bannedBy,
            ['@ban_date'] = data.banDate,
            ['@permanent'] = data.permanent and 1 or 0
        }
        
        if data.permanent then
            query = ('INSERT INTO %s (identifier, reason, banned_by, ban_date, permanent) VALUES (@identifier, @reason, @banned_by, @ban_date, @permanent)'):format(tableName)
        else
            query = ('INSERT INTO %s (identifier, reason, banned_by, ban_date, permanent, expire_time) VALUES (@identifier, @reason, @banned_by, @ban_date, @permanent, @expire_time)'):format(tableName)
            params['@expire_time'] = data.expireTime
        end
        
        MySQL.Async.execute(query, params, function(rowsChanged)
            if rowsChanged > 0 then
                Utils.Log(
                    data.permanent and 
                        _U('log_ban', data.bannedBy, data.playerName or "Inconnu", data.identifier, data.reason) or
                        _U('log_tempban', data.bannedBy, data.playerName or "Inconnu", data.identifier, Utils.FormatDuration(data.duration), data.reason),
                    data.permanent and "BAN" or "TEMPBAN"
                )
                callback(true)
            else
                callback(false, "database_error")
            end
        end)
    end)
end

-- ================================
-- RETIRER UN BAN
-- ================================

function BanCore.RemoveBan(identifier, callback)
    local tableName = Utils.GetTableName("bans")
    
    MySQL.Async.execute(
        ('DELETE FROM %s WHERE identifier = @identifier'):format(tableName),
        {['@identifier'] = identifier},
        function(rowsChanged)
            callback(rowsChanged > 0)
        end
    )
end

-- ================================
-- OBTENIR LA LISTE DES BANS
-- ================================

function BanCore.GetBanList(page, limit, callback)
    page = page or 1
    limit = limit or 10
    local offset = (page - 1) * limit
    
    local tableName = Utils.GetTableName("bans")
    
    -- Compter le total
    MySQL.Async.fetchScalar(
        ('SELECT COUNT(*) FROM %s'):format(tableName),
        {},
        function(total)
            -- Récupérer les bans
            MySQL.Async.fetchAll(
                ('SELECT * FROM %s ORDER BY ban_date DESC LIMIT @limit OFFSET @offset'):format(tableName),
                {
                    ['@limit'] = limit,
                    ['@offset'] = offset
                },
                function(bans)
                    callback({
                        bans = bans,
                        total = total,
                        page = page,
                        totalPages = math.ceil(total / limit)
                    })
                end
            )
        end
    )
end

-- ================================
-- OBTENIR UN BAN PAR IDENTIFIER
-- ================================

function BanCore.GetBan(identifier, callback)
    local tableName = Utils.GetTableName("bans")
    
    MySQL.Async.fetchAll(
        ('SELECT * FROM %s WHERE identifier = @identifier'):format(tableName),
        {['@identifier'] = identifier},
        function(result)
            callback(result[1])
        end
    )
end

-- ================================
-- ÉVÉNEMENT: CONNEXION JOUEUR
-- ================================

AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    local src = source
    deferrals.defer()
    
    Wait(50)
    deferrals.update(_U('checking_status'))
    
    local identifier = Utils.GetPrimaryIdentifier(src)
    
    if not identifier then
        deferrals.done(_U('identifier_error'))
        Utils.Debug("Impossible de récupérer l'identifier pour le joueur " .. playerName, "error")
        return
    end
    
    BanCore.CheckBan(identifier, function(isBanned, banInfo)
        if not isBanned then
            deferrals.done()
            return
        end
        
        -- Ban permanent
        if banInfo.permanent then
            local msg = Utils.BuildBanMessage(banInfo)
            deferrals.done(msg)
            return
        end
        
        -- Ban temporaire
        if not banInfo.expireTime then
            deferrals.done()
            return
        end
        
        local remaining = banInfo.expireTime - os.time()
        
        if remaining <= 0 then
            BanCore.RemoveBan(identifier, function(success)
                deferrals.done()
            end)
            return
        end
        
        local timeLeftFormatted = Utils.FormatTime(remaining)
        local msg = Utils.BuildBanMessage(banInfo, timeLeftFormatted)
        deferrals.done(msg)
    end)
end)

-- ================================
-- COMMANDES
-- ================================

-- Commande: /ban
RegisterCommand('ban', function(source, args)
    -- Vérifier cooldown
    local canUse, remaining = Utils.CheckCommandCooldown(source, 'ban')
    if not canUse then
        Utils.SendChatMessage(source, "Attendez " .. remaining .. " seconde(s) avant de réutiliser cette commande", "warning")
        return
    end
    
    -- Vérifier permissions
    if not Utils.HasPermission(source, Config.AcePerms.Ban) then
        Utils.SendChatMessage(source, _U('no_permission'), "error")
        return
    end
    
    -- Vérifier arguments
    if #args < 2 then
        Utils.SendChatMessage(source, _U('ban_usage'), "error")
        return
    end
    
    local targetId = tonumber(args[1])
    table.remove(args, 1)
    local reason = table.concat(args, " ")
    
    -- Vérifier que le joueur existe
    if not Utils.IsValidPlayerId(targetId) then
        Utils.SendChatMessage(source, _U('player_not_found'), "error")
        return
    end
    
    local identifier = Utils.GetPrimaryIdentifier(targetId)
    if not identifier then
        Utils.SendChatMessage(source, _U('identifier_error'), "error")
        return
    end
    
    local targetName = GetPlayerName(targetId)
    local bannedBy = Utils.GetPlayerName(source)
    local banDate = Utils.GetCurrentDate()
    
    -- Ajouter le ban
    BanCore.AddBan({
        identifier = identifier,
        reason = reason,
        bannedBy = bannedBy,
        banDate = banDate,
        permanent = true,
        playerName = targetName
    }, function(success, error)
        if success then
            -- Déclencher l'événement pour les autres modules
            TriggerEvent('banSystem:playerBanned', {
                identifier = identifier,
                playerName = targetName,
                reason = reason,
                adminIdentifier = source ~= 0 and Utils.GetPrimaryIdentifier(source) or nil,
                adminName = bannedBy,
                banDate = banDate,
                playerId = targetId
            })
            
            -- Kick le joueur
            DropPlayer(targetId, Utils.BuildBanMessage({
                permanent = true,
                reason = reason,
                bannedBy = bannedBy,
                banDate = banDate
            }))
            
            Utils.SendChatMessage(source, _U('ban_success', targetName, reason), "success")
        else
            if error == "already_banned" then
                Utils.SendChatMessage(source, _U('already_banned'), "error")
            else
                Utils.SendChatMessage(source, "Erreur lors du bannissement", "error")
            end
        end
    end)
end, false)

-- Commande: /tempban
RegisterCommand('tempban', function(source, args)
    -- Vérifier cooldown
    local canUse, remaining = Utils.CheckCommandCooldown(source, 'tempban')
    if not canUse then
        Utils.SendChatMessage(source, "Attendez " .. remaining .. " seconde(s) avant de réutiliser cette commande", "warning")
        return
    end
    
    -- Vérifier permissions
    if not Utils.HasPermission(source, Config.AcePerms.Tempban) then
        Utils.SendChatMessage(source, _U('no_permission'), "error")
        return
    end
    
    -- Vérifier arguments
    if #args < 3 then
        Utils.SendChatMessage(source, _U('tempban_usage'), "error")
        return
    end
    
    local targetId = tonumber(args[1])
    local duration = tonumber(args[2])
    table.remove(args, 1)
    table.remove(args, 1)
    local reason = table.concat(args, " ")
    
    -- Validations
    if not Utils.IsValidPlayerId(targetId) then
        Utils.SendChatMessage(source, _U('player_not_found'), "error")
        return
    end
    
    if not Utils.IsValidDuration(duration) then
        Utils.SendChatMessage(source, _U('invalid_duration'), "error")
        return
    end
    
    local identifier = Utils.GetPrimaryIdentifier(targetId)
    if not identifier then
        Utils.SendChatMessage(source, _U('identifier_error'), "error")
        return
    end
    
    local targetName = GetPlayerName(targetId)
    local bannedBy = Utils.GetPlayerName(source)
    local banDate = Utils.GetCurrentDate()
    local expireTime = os.time() + (duration * 3600)
    
    -- Ajouter le ban
    BanCore.AddBan({
        identifier = identifier,
        reason = reason,
        bannedBy = bannedBy,
        banDate = banDate,
        permanent = false,
        expireTime = expireTime,
        duration = duration,
        playerName = targetName
    }, function(success, error)
        if success then
            -- Déclencher l'événement pour les autres modules
            TriggerEvent('banSystem:playerTempBanned', {
                identifier = identifier,
                playerName = targetName,
                reason = reason,
                adminIdentifier = source ~= 0 and Utils.GetPrimaryIdentifier(source) or nil,
                adminName = bannedBy,
                duration = duration,
                expireTime = expireTime,
                banDate = banDate,
                playerId = targetId
            })
            
            -- Kick le joueur
            DropPlayer(targetId, Utils.BuildBanMessage({
                permanent = false,
                reason = reason,
                bannedBy = bannedBy,
                banDate = banDate,
                expireTime = expireTime
            }, Utils.FormatTime(expireTime - os.time())))
            
            Utils.SendChatMessage(source, _U('tempban_success', targetName, Utils.FormatDuration(duration), reason), "success")
        else
            if error == "already_banned" then
                Utils.SendChatMessage(source, _U('already_banned'), "error")
            else
                Utils.SendChatMessage(source, "Erreur lors du bannissement", "error")
            end
        end
    end)
end, false)

-- Commande: /unban
RegisterCommand('unban', function(source, args)
    -- Vérifier cooldown
    local canUse, remaining = Utils.CheckCommandCooldown(source, 'unban')
    if not canUse then
        Utils.SendChatMessage(source, "Attendez " .. remaining .. " seconde(s) avant de réutiliser cette commande", "warning")
        return
    end
    
    -- Vérifier permissions
    if not Utils.HasPermission(source, Config.AcePerms.Unban) then
        Utils.SendChatMessage(source, _U('no_permission'), "error")
        return
    end
    
    -- Vérifier arguments
    if #args < 1 then
        Utils.SendChatMessage(source, _U('unban_usage'), "error")
        return
    end
    
    local identifier = args[1]
    
    if not Utils.IsValidIdentifier(identifier) then
        Utils.SendChatMessage(source, "Identifier invalide", "error")
        return
    end
    
    -- Retirer le ban
    BanCore.RemoveBan(identifier, function(success)
        if success then
            -- Déclencher l'événement pour les autres modules
            TriggerEvent('banSystem:playerUnbanned', {
                identifier = identifier,
                adminIdentifier = source ~= 0 and Utils.GetPrimaryIdentifier(source) or nil,
                adminName = Utils.GetPlayerName(source),
                reason = "Débannissement manuel"
            })
            
            Utils.Log(_U('log_unban', Utils.GetPlayerName(source), identifier), "UNBAN")
            Utils.SendChatMessage(source, _U('unban_success', identifier), "success")
        else
            Utils.SendChatMessage(source, _U('no_ban_found', identifier), "error")
        end
    end)
end, false)

-- Commande: /banlist
RegisterCommand('banlist', function(source, args)
    -- Vérifier permissions
    if not Utils.HasPermission(source, Config.AcePerms.BanList) then
        Utils.SendChatMessage(source, _U('no_permission'), "error")
        return
    end
    
    local page = tonumber(args[1]) or 1
    
    BanCore.GetBanList(page, 10, function(data)
        if #data.bans == 0 then
            Utils.SendChatMessage(source, "Aucun ban trouvé", "warning")
            return
        end
        
        Utils.SendChatMessage(source, string.format("^5===== Liste des bans (Page %d/%d) =====", data.page, data.totalPages), "info")
        
        for i, ban in ipairs(data.bans) do
            local banType = (ban.permanent == 1) and "PERMANENT" or "TEMPORAIRE"
            local msg = string.format("^3%d.^0 [%s] %s - %s (par %s)",
                i,
                banType,
                ban.identifier,
                ban.reason,
                ban.banned_by
            )
            Utils.SendChatMessage(source, msg, "info")
        end
        
        Utils.SendChatMessage(source, string.format("^5Total: %d ban(s)", data.total), "info")
    end)
end, false)

-- ================================
-- INITIALISATION
-- ================================

Utils.Log("^2Module BAN_CORE chargé avec succès", "INFO")
