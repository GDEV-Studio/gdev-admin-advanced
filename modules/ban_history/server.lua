-- ================================
-- MODULE: BAN_HISTORY
-- Historique complet des bannissements par joueur
-- ================================

if not Config.Modules.BanHistory then return end

BanHistory = {}

-- ================================
-- AJOUTER UNE ENTRÉE À L'HISTORIQUE
-- ================================

function BanHistory.Add(data)
    if not Config.History.Enabled then return end
    if not Config.History.SaveToDatabase then return end
    
    local tableName = Utils.GetTableName("history")
    
    -- Récupérer les identifiants additionnels si configuré
    local allIdentifiers = {}
    if Config.History.SaveAdditionalIdentifiers and data.playerId then
        allIdentifiers = Utils.GetAllIdentifiers(data.playerId)
    end
    
    MySQL.Async.execute(
        ('INSERT INTO %s (identifier, player_name, action, reason, admin_identifier, admin_name, duration, ban_date, expire_time, all_identifiers, timestamp) VALUES (@identifier, @player_name, @action, @reason, @admin_identifier, @admin_name, @duration, @ban_date, @expire_time, @all_identifiers, @timestamp)'):format(tableName),
        {
            ['@identifier'] = data.identifier,
            ['@player_name'] = data.playerName,
            ['@action'] = data.action,
            ['@reason'] = data.reason,
            ['@admin_identifier'] = data.adminIdentifier or "console",
            ['@admin_name'] = data.adminName or "Console",
            ['@duration'] = data.duration or 0,
            ['@ban_date'] = data.banDate,
            ['@expire_time'] = data.expireTime or 0,
            ['@all_identifiers'] = json.encode(allIdentifiers),
            ['@timestamp'] = os.time()
        }
    )
    
    -- Limiter le nombre d'entrées si configuré
    if Config.History.MaxEntriesPerPlayer > 0 then
        BanHistory.CleanupOldEntries(data.identifier)
    end
end

-- ================================
-- RÉCUPÉRER L'HISTORIQUE D'UN JOUEUR
-- ================================

function BanHistory.Get(identifier, callback)
    local tableName = Utils.GetTableName("history")
    
    MySQL.Async.fetchAll(
        ('SELECT * FROM %s WHERE identifier = @identifier ORDER BY timestamp DESC'):format(tableName),
        {['@identifier'] = identifier},
        function(result)
            callback(result)
        end
    )
end

-- ================================
-- RÉCUPÉRER L'HISTORIQUE COMPLET
-- ================================

function BanHistory.GetAll(page, limit, callback)
    page = page or 1
    limit = limit or 20
    local offset = (page - 1) * limit
    
    local tableName = Utils.GetTableName("history")
    
    -- Compter le total
    MySQL.Async.fetchScalar(
        ('SELECT COUNT(*) FROM %s'):format(tableName),
        {},
        function(total)
            -- Récupérer l'historique
            MySQL.Async.fetchAll(
                ('SELECT * FROM %s ORDER BY timestamp DESC LIMIT @limit OFFSET @offset'):format(tableName),
                {
                    ['@limit'] = limit,
                    ['@offset'] = offset
                },
                function(history)
                    callback({
                        history = history,
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
-- NETTOYER LES VIEILLES ENTRÉES
-- ================================

function BanHistory.CleanupOldEntries(identifier)
    local tableName = Utils.GetTableName("history")
    local maxEntries = Config.History.MaxEntriesPerPlayer
    
    -- Récupérer le nombre d'entrées
    MySQL.Async.fetchScalar(
        ('SELECT COUNT(*) FROM %s WHERE identifier = @identifier'):format(tableName),
        {['@identifier'] = identifier},
        function(count)
            if count > maxEntries then
                -- Supprimer les plus anciennes
                MySQL.Async.execute(
                    ('DELETE FROM %s WHERE identifier = @identifier ORDER BY timestamp ASC LIMIT @limit'):format(tableName),
                    {
                        ['@identifier'] = identifier,
                        ['@limit'] = count - maxEntries
                    }
                )
            end
        end
    )
end

-- ================================
-- STATISTIQUES
-- ================================

function BanHistory.GetStats(identifier, callback)
    local tableName = Utils.GetTableName("history")
    
    MySQL.Async.fetchAll(
        ('SELECT action, COUNT(*) as count FROM %s WHERE identifier = @identifier GROUP BY action'):format(tableName),
        {['@identifier'] = identifier},
        function(result)
            local stats = {
                totalBans = 0,
                totalTempBans = 0,
                totalUnbans = 0,
                lastAction = nil
            }
            
            for _, row in ipairs(result) do
                if row.action == "BAN" then
                    stats.totalBans = row.count
                elseif row.action == "TEMPBAN" then
                    stats.totalTempBans = row.count
                elseif row.action == "UNBAN" then
                    stats.totalUnbans = row.count
                end
            end
            
            -- Récupérer la dernière action
            MySQL.Async.fetchAll(
                ('SELECT * FROM %s WHERE identifier = @identifier ORDER BY timestamp DESC LIMIT 1'):format(tableName),
                {['@identifier'] = identifier},
                function(lastResult)
                    if lastResult[1] then
                        stats.lastAction = lastResult[1]
                    end
                    callback(stats)
                end
            )
        end
    )
end

-- ================================
-- HOOKS SUR LES ÉVÉNEMENTS
-- ================================

-- Hook: Ban ajouté
AddEventHandler('banSystem:playerBanned', function(data)
    BanHistory.Add({
        identifier = data.identifier,
        playerName = data.playerName,
        action = "BAN",
        reason = data.reason,
        adminIdentifier = data.adminIdentifier,
        adminName = data.adminName,
        banDate = data.banDate,
        playerId = data.playerId
    })
end)

-- Hook: Tempban ajouté
AddEventHandler('banSystem:playerTempBanned', function(data)
    BanHistory.Add({
        identifier = data.identifier,
        playerName = data.playerName,
        action = "TEMPBAN",
        reason = data.reason,
        adminIdentifier = data.adminIdentifier,
        adminName = data.adminName,
        duration = data.duration,
        banDate = data.banDate,
        expireTime = data.expireTime,
        playerId = data.playerId
    })
end)

-- Hook: Unban
AddEventHandler('banSystem:playerUnbanned', function(data)
    BanHistory.Add({
        identifier = data.identifier,
        playerName = data.playerName or "Inconnu",
        action = "UNBAN",
        reason = data.reason or "Débannissement manuel",
        adminIdentifier = data.adminIdentifier,
        adminName = data.adminName,
        banDate = Utils.GetCurrentDate()
    })
end)

-- ================================
-- COMMANDES
-- ================================

-- Commande: /banhistory
RegisterCommand('banhistory', function(source, args)
    if not Utils.HasPermission(source, Config.AcePerms.BanHistory) then
        Utils.SendChatMessage(source, _U('no_permission'), "error")
        return
    end
    
    if #args < 1 then
        Utils.SendChatMessage(source, _U('banhistory_usage'), "error")
        return
    end
    
    local identifier = args[1]
    
    if not Utils.IsValidIdentifier(identifier) then
        Utils.SendChatMessage(source, "Identifier invalide", "error")
        return
    end
    
    BanHistory.Get(identifier, function(history)
        if #history == 0 then
            Utils.SendChatMessage(source, "Aucun historique trouvé pour cet identifier", "warning")
            return
        end
        
        Utils.SendChatMessage(source, string.format("^5===== Historique de %s =====", identifier), "info")
        
        for i, entry in ipairs(history) do
            local timestamp = os.date("%d/%m/%Y %H:%M", entry.timestamp)
            local duration = ""
            
            if entry.action == "TEMPBAN" and entry.duration > 0 then
                duration = string.format(" (%s)", Utils.FormatDuration(entry.duration))
            end
            
            local msg = string.format("^3[%s]^0 %s%s: %s (par %s)",
                timestamp,
                entry.action,
                duration,
                entry.reason,
                entry.admin_name
            )
            Utils.SendChatMessage(source, msg, "info")
        end
        
        -- Afficher les statistiques
        BanHistory.GetStats(identifier, function(stats)
            Utils.SendChatMessage(source, string.format("^5Total: %d ban(s), %d tempban(s), %d unban(s)",
                stats.totalBans,
                stats.totalTempBans,
                stats.totalUnbans
            ), "info")
        end)
    end)
end, false)

-- Commande: /banstats
RegisterCommand('banstats', function(source, args)
    if not Utils.HasPermission(source, Config.AcePerms.BanHistory) then
        Utils.SendChatMessage(source, _U('no_permission'), "error")
        return
    end
    
    if #args < 1 then
        Utils.SendChatMessage(source, "Usage: /banstats [identifier]", "error")
        return
    end
    
    local identifier = args[1]
    
    BanHistory.GetStats(identifier, function(stats)
        Utils.SendChatMessage(source, string.format("^5===== Statistiques de %s =====", identifier), "info")
        Utils.SendChatMessage(source, string.format("^3Bans permanents:^0 %d", stats.totalBans), "info")
        Utils.SendChatMessage(source, string.format("^3Bans temporaires:^0 %d", stats.totalTempBans), "info")
        Utils.SendChatMessage(source, string.format("^3Débannissements:^0 %d", stats.totalUnbans), "info")
        
        if stats.lastAction then
            local timestamp = os.date("%d/%m/%Y %H:%M", stats.lastAction.timestamp)
            Utils.SendChatMessage(source, string.format("^3Dernière action:^0 %s (%s)",
                stats.lastAction.action,
                timestamp
            ), "info")
        end
    end)
end, false)

-- ================================
-- INITIALISATION
-- ================================

Utils.Log("^2Module BAN_HISTORY chargé avec succès", "INFO")
