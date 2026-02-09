## 🔧 Configuration Détaillée

### Modules

```lua
Config.Modules = {
    BanCore = true,      -- Module de base (obligatoire)
    BanLogs = true,      -- Logs détaillés
    BanHistory = true,   -- Historique des bans
    BanAppeals = false,  -- Système de contestation (à venir)
    BanWebhook = false   -- Webhooks Discord (à venir)
}
```

### Identifiants

```lua
Config.Identifiers = {
    Priority = {
        "license",  -- FiveM License (prioritaire)
        "steam",    -- Steam
        "discord",  -- Discord
        "xbl",      -- Xbox Live
        "live"      -- Microsoft Live
    },
    AllowIP = false  -- Utiliser l'IP en dernier recours (non recommandé)
}
```

### Logs

```lua
Config.Logs = {
    Enabled = true,
    SaveToDatabase = true,
    PrintToConsole = true,
    
    Types = {
        BAN = true,
        TEMPBAN = true,
        UNBAN = true,
        BAN_CHECK = false,  -- Peut être verbose
        BAN_EXPIRE = true,
        COMMAND_USAGE = true
    },
    
    RetentionDays = 90  -- 0 = illimité
}
```

### Historique

```lua
Config.History = {
    Enabled = true,
    SaveToDatabase = true,
    MaxEntriesPerPlayer = 50,  -- 0 = illimité
    SavePlayerName = true,
    SavePlayerIP = false,  -- Attention RGPD
    SaveAdditionalIdentifiers = true
}
```

### Anti-Spam

```lua
Config.AntiSpam = {
    Enabled = true,
    CooldownSeconds = 5,
    MaxWarnings = 3
}
```

## 📡 API / Exports

Utilisez ces exports depuis d'autres ressources :

```lua
-- Bannir un joueur
exports['ban_system']:BanPlayer(playerId, reason, adminName)

-- Bannir temporairement
exports['ban_system']:TempBanPlayer(playerId, duration, reason, adminName)

-- Débannir
exports['ban_system']:UnbanPlayer(identifier, adminName)

-- Vérifier si banni
exports['ban_system']:IsPlayerBanned(identifier, function(isBanned, banInfo)
    if isBanned then
        print("Le joueur est banni!")
    end
end)

-- Obtenir la liste des bans
exports['ban_system']:GetBanList(page, limit, function(data)
    print("Total de bans: " .. data.total)
end)

-- Obtenir l'historique d'un joueur
exports['ban_system']:GetPlayerHistory(identifier, function(history)
    print("Nombre d'entrées: " .. #history)
end)

-- Obtenir les logs
exports['ban_system']:GetLogs({
    action = "BAN",
    page = 1,
    limit = 50
}, function(data)
    print("Total de logs: " .. data.total)
end)
```