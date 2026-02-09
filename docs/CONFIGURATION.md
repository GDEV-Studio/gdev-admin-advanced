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
