-- ================================
-- MAIN SERVER FILE
-- Gestion des événements et hooks entre modules
-- ================================

-- ================================
-- TRIGGERS POUR LES MODULES
-- ================================

-- Wrapper pour déclencher les événements de ban
function TriggerBanEvent(eventName, data)
    TriggerEvent('banSystem:' .. eventName, data)
end

-- ================================
-- HOOKS MODIFIÉS DANS BAN_CORE
-- ================================

-- Modifier les commandes ban/tempban/unban pour déclencher les événements

-- Hook original de ban
local originalBanCommand = _G.RegisterCommand

-- Override des commandes pour ajouter les événements
Citizen.CreateThread(function()
    Wait(1000) -- Attendre que tous les modules soient chargés
    
    -- Note: Les événements sont déjà intégrés dans ban_core/server.lua
    -- Ce fichier sert de point central pour les futures extensions
end)

-- ================================
-- EXPORTS
-- ================================

-- Export: Bannir un joueur
exports('BanPlayer', function(playerId, reason, adminName)
    if not Utils.IsValidPlayerId(playerId) then
        return false, "player_not_found"
    end
    
    local identifier = Utils.GetPrimaryIdentifier(playerId)
    if not identifier then
        return false, "identifier_error"
    end
    
    local targetName = GetPlayerName(playerId)
    local banDate = Utils.GetCurrentDate()
    
    BanCore.AddBan({
        identifier = identifier,
        reason = reason,
        bannedBy = adminName or "API",
        banDate = banDate,
        permanent = true,
        playerName = targetName
    }, function(success, error)
        if success then
            TriggerBanEvent('playerBanned', {
                identifier = identifier,
                playerName = targetName,
                reason = reason,
                adminIdentifier = nil,
                adminName = adminName or "API",
                banDate = banDate,
                playerId = playerId
            })
        end
    end)
    
    return true
end)

-- Export: Bannir temporairement un joueur
exports('TempBanPlayer', function(playerId, duration, reason, adminName)
    if not Utils.IsValidPlayerId(playerId) then
        return false, "player_not_found"
    end
    
    if not Utils.IsValidDuration(duration) then
        return false, "invalid_duration"
    end
    
    local identifier = Utils.GetPrimaryIdentifier(playerId)
    if not identifier then
        return false, "identifier_error"
    end
    
    local targetName = GetPlayerName(playerId)
    local banDate = Utils.GetCurrentDate()
    local expireTime = os.time() + (duration * 3600)
    
    BanCore.AddBan({
        identifier = identifier,
        reason = reason,
        bannedBy = adminName or "API",
        banDate = banDate,
        permanent = false,
        expireTime = expireTime,
        duration = duration,
        playerName = targetName
    }, function(success, error)
        if success then
            TriggerBanEvent('playerTempBanned', {
                identifier = identifier,
                playerName = targetName,
                reason = reason,
                adminIdentifier = nil,
                adminName = adminName or "API",
                duration = duration,
                expireTime = expireTime,
                banDate = banDate,
                playerId = playerId
            })
        end
    end)
    
    return true
end)

-- Export: Débannir un joueur
exports('UnbanPlayer', function(identifier, adminName)
    if not Utils.IsValidIdentifier(identifier) then
        return false, "invalid_identifier"
    end
    
    BanCore.RemoveBan(identifier, function(success)
        if success then
            TriggerBanEvent('playerUnbanned', {
                identifier = identifier,
                adminIdentifier = nil,
                adminName = adminName or "API",
                reason = "Débannissement via API"
            })
        end
    end)
    
    return true
end)

-- Export: Vérifier si un identifier est banni
exports('IsPlayerBanned', function(identifier, callback)
    BanCore.CheckBan(identifier, callback)
end)

-- Export: Récupérer la liste des bans
exports('GetBanList', function(page, limit, callback)
    BanCore.GetBanList(page, limit, callback)
end)

-- Export: Récupérer l'historique d'un joueur
exports('GetPlayerHistory', function(identifier, callback)
    if Config.Modules.BanHistory then
        BanHistory.Get(identifier, callback)
    else
        callback(nil)
    end
end)

-- Export: Récupérer les logs
exports('GetLogs', function(filters, callback)
    if Config.Modules.BanLogs then
        BanLogs.Get(filters, callback)
    else
        callback(nil)
    end
end)

-- ================================
-- INITIALISATION
-- ================================

Citizen.CreateThread(function()
    Wait(500)
    
    Utils.Log("^2=================================", "INFO")
    Utils.Log("^2  BAN SYSTEM v" .. Config.Version, "INFO")
    Utils.Log("^2  Système de bannissement modulaire", "INFO")
    Utils.Log("^2=================================", "INFO")
    Utils.Log("", "INFO")
    
    -- Afficher les modules chargés
    Utils.Log("^5Modules actifs:", "INFO")
    if Config.Modules.BanCore then
        Utils.Log("  ^2✓^0 BAN_CORE - Système de base", "INFO")
    end
    if Config.Modules.BanLogs then
        Utils.Log("  ^2✓^0 BAN_LOGS - Système de logs", "INFO")
    end
    if Config.Modules.BanHistory then
        Utils.Log("  ^2✓^0 BAN_HISTORY - Historique des bans", "INFO")
    end
    if Config.Modules.BanAppeals then
        Utils.Log("  ^2✓^0 BAN_APPEALS - Contestations (à venir)", "INFO")
    end
    if Config.Modules.BanWebhook then
        Utils.Log("  ^2✓^0 BAN_WEBHOOK - Webhooks Discord (à venir)", "INFO")
    end
    
    Utils.Log("", "INFO")
    Utils.Log("^2Système prêt!", "INFO")
end)
