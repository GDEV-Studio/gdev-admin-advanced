Config = Config or {}

-- ================================
-- CONFIGURATION GÉNÉRALE
-- ================================
Config.Locale = 'fr'
Config.Version = '2.0.0'

-- ================================
-- SUPPORT & LIENS
-- ================================
Config.Support = {
    DiscordInvite = "https://discord.gg/wUmt3jzERh",
    ContactText = "Pour contester, rejoignez le Discord :"
}

-- ================================
-- MESSAGES DE BAN
-- ================================
Config.BanReason = {
    default   = "Vous avez été banni du serveur",
    permanent = "Vous êtes banni définitivement du serveur",
    temporary = "Vous êtes banni temporairement du serveur"
}

-- ================================
-- AFFICHAGE DU BAN
-- ================================
Config.BanScreen = {
    UseFrame = true,  -- Afficher un cadre autour du message
    ShowIdentifier = false  -- Afficher l'identifier dans le message de ban (debug)
}

-- ================================
-- PERMISSIONS ACE
-- ================================
Config.AcePerms = {
    Ban     = "command.ban",
    Tempban = "command.tempban",
    Unban   = "command.unban",
    BanList = "command.banlist",
    BanHistory = "command.banhistory"
}

-- ================================
-- BASE DE DONNÉES
-- ================================
Config.Database = {
    TableName = "bans",
    LogsTableName = "ban_logs",
    HistoryTableName = "ban_history"
}

-- ================================
-- DEBUG & DÉVELOPPEMENT
-- ================================
Config.Debug = {
    Enabled = true,
    PrintIdentifiers = true,
    PrintQueries = false,
    PrintLogs = true
}

-- ================================
-- MODULES ACTIFS
-- ================================
Config.Modules = {
    BanCore = true,      -- Module de base (obligatoire)
    BanLogs = true,      -- Logs détaillés
    BanHistory = true,   -- Historique des bans
    BanAppeals = false,  -- Système de contestation (à venir)
    BanWebhook = false   -- Webhooks Discord (à venir)
}

-- ================================
-- CONFIGURATION DES LOGS
-- ================================
Config.Logs = {
    Enabled = true,
    SaveToDatabase = true,
    PrintToConsole = true,
    
    -- Types de logs à enregistrer
    Types = {
        BAN = true,
        TEMPBAN = true,
        UNBAN = true,
        BAN_CHECK = false,  -- Log chaque vérification (peut être verbose)
        BAN_EXPIRE = true,
        COMMAND_USAGE = true
    },
    
    -- Rétention des logs (en jours, 0 = illimité)
    RetentionDays = 90
}

-- ================================
-- CONFIGURATION DE L'HISTORIQUE
-- ================================
Config.History = {
    Enabled = true,
    SaveToDatabase = true,
    MaxEntriesPerPlayer = 50,  -- 0 = illimité
    
    -- Informations à sauvegarder
    SavePlayerName = true,
    SavePlayerIP = false,  -- Attention RGPD
    SaveAdditionalIdentifiers = true
}

-- ================================
-- WEBHOOKS DISCORD (À VENIR)
-- ================================
Config.Webhook = {
    Enabled = false,
    URL = "",
    Username = "Ban System",
    Avatar = "",
    
    -- Couleurs des embeds
    Colors = {
        Ban = 15158332,      -- Rouge
        Tempban = 16776960,  -- Jaune
        Unban = 3066993      -- Vert
    }
}

-- ================================
-- IDENTIFIANTS
-- ================================
Config.Identifiers = {
    Priority = {
        "license",  -- FiveM License (prioritaire)
        "steam",    -- Steam
        "discord",  -- Discord
        "xbl",      -- Xbox Live
        "live"      -- Microsoft Live
    },
    
    -- Identifier de secours si aucun n'est trouvé
    AllowIP = false  -- Autoriser l'utilisation de l'IP comme identifier (non recommandé)
}

-- ================================
-- ANTI-SPAM COMMANDES
-- ================================
Config.AntiSpam = {
    Enabled = true,
    CooldownSeconds = 5,  -- Délai entre chaque commande
    MaxWarnings = 3       -- Nombre d'avertissements avant blocage temporaire
}
