fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Yusu_sauvage'
description 'Système de bannissement modulaire avancé avec logs détaillés, historique complet et gestion multi-identifiants. Supporte les bans permanents/temporaires, webhooks Discord et exports API'
info 'Pour toutes informations & configurations, consultez le dossier "docs" ou contactez-moi sur Discord Yusu_sauvage'
version '2.0.1'

-- Configuration
shared_scripts {
    'config/*.lua'
}

-- Serveur
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/utils.lua',
    'modules/**/server.lua',
    'server/main.lua'
}

-- Modules disponibles
modules = {
    'ban_core',      -- Système de ban de base
    'ban_logs',      -- Système de logs
    'ban_history',   -- Historique des bans
    'ban_appeals',   -- Système de contestation (futur)
    'ban_webhook'    -- Webhooks Discord (futur)
}
