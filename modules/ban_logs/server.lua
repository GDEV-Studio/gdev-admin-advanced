-- ================================
-- MODULE: BAN_LOGS
-- Système de logs détaillés pour toutes les actions
-- ================================

if not Config.Modules.BanLogs then return end

BanLogs = {}

-- ================================
-- AJOUTER UN LOG
-- ================================

function BanLogs.Add(data)
    if not Config.Logs.Enabled then return end
    
    -- Log console
    if Config.Logs.PrintToConsole then
        local logMessage = string.format(
            "[%s] %s - %s (par %s) - %s",
            data.action,
            data.targetIdentifier or "N/A",
            data.targetName or "N/A",
            data.adminName or "Console",
            data.reason or "N/A"
        )
        Utils.Log(logMessage, data.action)
    end
    
    -- Log base de données
    if Config.Logs.SaveToDatabase then
        local tableName = Utils.GetTableName("logs")
        
        MySQL.Async.execute(
            ('INSERT INTO %s (action, admin_identifier, admin_name, target_identifier, target_name, reason, additional_data, timestamp) VALUES (@action, @admin_identifier, @admin_name, @target_identifier, @target_name, @reason, @additional_data, @timestamp)'):format(tableName),
            {
                ['@action'] = data.action,
                ['@admin_identifier'] = data.adminIdentifier or "console",
                ['@admin_name'] = data.adminName or "Console",
                ['@target_identifier'] = data.targetIdentifier,
                ['@target_name'] = data.targetName,
                ['@reason'] = data.reason,
                ['@additional_data'] = json.encode(data.additionalData or {}),
                ['@timestamp'] = os.time()
            }
        )
    end
end

-- ================================
-- RÉCUPÉRER LES LOGS
-- ================================

function BanLogs.Get(filters, callback)
    local tableName = Utils.GetTableName("logs")
    local whereClause = "1=1"
    local params = {}
    
    -- Filtres
    if filters.action then
        whereClause = whereClause .. " AND action = @action"
        params['@action'] = filters.action
    end
    
    if filters.targetIdentifier then
        whereClause = whereClause .. " AND target_identifier = @target_identifier"
        params['@target_identifier'] = filters.targetIdentifier
    end
    
    if filters.adminIdentifier then
        whereClause = whereClause .. " AND admin_identifier = @admin_identifier"
        params['@admin_identifier'] = filters.adminIdentifier
    end
    
    if filters.startDate then
        whereClause = whereClause .. " AND timestamp >= @start_date"
        params['@start_date'] = filters.startDate
    end
    
    if filters.endDate then
        whereClause = whereClause .. " AND timestamp <= @end_date"
        params['@end_date'] = filters.endDate
    end
    
    -- Pagination
    local page = filters.page or 1
    local limit = filters.limit or 50
    local offset = (page - 1) * limit
    
    -- Compter le total
    MySQL.Async.fetchScalar(
        ('SELECT COUNT(*) FROM %s WHERE %s'):format(tableName, whereClause),
        params,
        function(total)
            -- Récupérer les logs
            params['@limit'] = limit
            params['@offset'] = offset
            
            MySQL.Async.fetchAll(
                ('SELECT * FROM %s WHERE %s ORDER BY timestamp DESC LIMIT @limit OFFSET @offset'):format(tableName, whereClause),
                params,
                function(logs)
                    callback({
                        logs = logs,
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
-- NETTOYER LES VIEUX LOGS
-- ================================

function BanLogs.Cleanup()
    if Config.Logs.RetentionDays == 0 then return end
    
    local tableName = Utils.GetTableName("logs")
    local cutoffTime = os.time() - (Config.Logs.RetentionDays * 86400)
    
    MySQL.Async.execute(
        ('DELETE FROM %s WHERE timestamp < @cutoff'):format(tableName),
        {['@cutoff'] = cutoffTime},
        function(rowsChanged)
            if rowsChanged > 0 then
                Utils.Log(string.format("Nettoyage des logs: %d entrée(s) supprimée(s)", rowsChanged), "INFO")
            end
        end
    )
end

-- ================================
-- HOOKS SUR LES ÉVÉNEMENTS
-- ================================

-- Hook: Ban ajouté
AddEventHandler('banSystem:playerBanned', function(data)
    if not Config.Logs.Types.BAN then return end
    
    BanLogs.Add({
        action = "BAN",
        adminIdentifier = data.adminIdentifier,
        adminName = data.adminName,
        targetIdentifier = data.identifier,
        targetName = data.playerName,
        reason = data.reason,
        additionalData = {
            permanent = true,
            banDate = data.banDate
        }
    })
end)

-- Hook: Tempban ajouté
AddEventHandler('banSystem:playerTempBanned', function(data)
    if not Config.Logs.Types.TEMPBAN then return end
    
    BanLogs.Add({
        action = "TEMPBAN",
        adminIdentifier = data.adminIdentifier,
        adminName = data.adminName,
        targetIdentifier = data.identifier,
        targetName = data.playerName,
        reason = data.reason,
        additionalData = {
            permanent = false,
            duration = data.duration,
            expireTime = data.expireTime,
            banDate = data.banDate
        }
    })
end)

-- Hook: Unban
AddEventHandler('banSystem:playerUnbanned', function(data)
    if not Config.Logs.Types.UNBAN then return end
    
    BanLogs.Add({
        action = "UNBAN",
        adminIdentifier = data.adminIdentifier,
        adminName = data.adminName,
        targetIdentifier = data.identifier,
        targetName = data.playerName or "Inconnu",
        reason = data.reason or "Débannissement manuel",
        additionalData = {}
    })
end)

-- Hook: Ban expiré
AddEventHandler('banSystem:banExpired', function(data)
    if not Config.Logs.Types.BAN_EXPIRE then return end
    
    BanLogs.Add({
        action = "BAN_EXPIRE",
        adminIdentifier = "system",
        adminName = "Système",
        targetIdentifier = data.identifier,
        targetName = data.playerName or "Inconnu",
        reason = "Ban temporaire expiré",
        additionalData = {
            originalExpireTime = data.expireTime
        }
    })
end)

-- Hook: Vérification de ban
AddEventHandler('banSystem:banChecked', function(data)
    if not Config.Logs.Types.BAN_CHECK then return end
    
    BanLogs.Add({
        action = "BAN_CHECK",
        adminIdentifier = "system",
        adminName = "Système",
        targetIdentifier = data.identifier,
        targetName = data.playerName,
        reason = data.isBanned and "Joueur banni détecté" or "Aucun ban",
        additionalData = {
            isBanned = data.isBanned,
            banType = data.banType
        }
    })
end)

-- ================================
-- COMMANDE: VOIR LES LOGS
-- ================================

RegisterCommand('banlogs', function(source, args)
    if not Utils.HasPermission(source, Config.AcePerms.BanList) then
        Utils.SendChatMessage(source, _U('no_permission'), "error")
        return
    end
    
    local filters = {
        page = tonumber(args[1]) or 1,
        limit = 20
    }
    
    -- Filtre par action
    if args[2] then
        filters.action = string.upper(args[2])
    end
    
    BanLogs.Get(filters, function(data)
        if #data.logs == 0 then
            Utils.SendChatMessage(source, "Aucun log trouvé", "warning")
            return
        end
        
        Utils.SendChatMessage(source, string.format("^5===== Logs (Page %d/%d) =====", data.page, data.totalPages), "info")
        
        for i, log in ipairs(data.logs) do
            local timestamp = os.date("%d/%m/%Y %H:%M", log.timestamp)
            local msg = string.format("^3[%s]^0 %s: ^6%s^0 → ^2%s^0 (par %s)",
                timestamp,
                log.action,
                log.target_identifier or "N/A",
                log.target_name or "N/A",
                log.admin_name or "Console"
            )
            Utils.SendChatMessage(source, msg, "info")
        end
        
        Utils.SendChatMessage(source, string.format("^5Total: %d log(s) | Usage: /banlogs [page] [action]", data.total), "info")
    end)
end, false)

-- ================================
-- NETTOYAGE AUTOMATIQUE
-- ================================

if Config.Logs.RetentionDays > 0 then
    CreateThread(function()
        while true do
            Wait(86400000) -- 24 heures
            BanLogs.Cleanup()
        end
    end)
end

-- ================================
-- INITIALISATION
-- ================================

Utils.Log("^2Module BAN_LOGS chargé avec succès", "INFO")
