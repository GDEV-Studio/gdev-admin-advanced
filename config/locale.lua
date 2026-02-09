Locale = Locale or {}

Locale['fr'] = {
    -- Commandes
    ['ban_usage'] = "Usage: /ban [ID] [raison]",
    ['tempban_usage'] = "Usage: /tempban [ID] [durée en heures] [raison]",
    ['unban_usage'] = "Usage: /unban [identifier]",
    ['banlist_usage'] = "Usage: /banlist [page]",
    ['banhistory_usage'] = "Usage: /banhistory [identifier]",
    
    -- Succès
    ['ban_success'] = "%s a été banni définitivement. Raison: %s",
    ['tempban_success'] = "%s a été banni temporairement pour %s. Raison: %s",
    ['unban_success'] = "%s a été débanni avec succès",
    ['ban_expired'] = "Ban expiré et supprimé pour: %s",
    
    -- Erreurs
    ['no_permission'] = "Vous n'avez pas la permission d'utiliser cette commande",
    ['player_not_found'] = "Joueur introuvable",
    ['invalid_duration'] = "Durée invalide",
    ['no_ban_found'] = "Aucun ban trouvé pour %s",
    ['identifier_error'] = "Erreur: Impossible de récupérer l'identifiant",
    ['already_banned'] = "Ce joueur est déjà banni",
    
    -- Messages système
    ['checking_status'] = "Vérification de votre statut...",
    ['loading'] = "Chargement...",
    ['system'] = "SYSTÈME",
    
    -- Logs
    ['log_ban'] = "[BAN] %s a banni %s (%s) - Raison: %s",
    ['log_tempban'] = "[TEMPBAN] %s a banni temporairement %s (%s) pour %s - Raison: %s",
    ['log_unban'] = "[UNBAN] %s a débanni %s",
    ['log_ban_check'] = "[CHECK] Vérification du ban pour %s (%s)",
    ['log_ban_expire'] = "[EXPIRE] Ban expiré automatiquement pour %s",
    
    -- Formatage temps
    ['time_format'] = "%d jour(s) %02d:%02d:%02d",
    ['hours'] = "heure(s)",
    ['days'] = "jour(s)",
    ['minutes'] = "minute(s)",
    ['seconds'] = "seconde(s)"
}

Locale['en'] = {
    -- Commands
    ['ban_usage'] = "Usage: /ban [ID] [reason]",
    ['tempban_usage'] = "Usage: /tempban [ID] [duration in hours] [reason]",
    ['unban_usage'] = "Usage: /unban [identifier]",
    ['banlist_usage'] = "Usage: /banlist [page]",
    ['banhistory_usage'] = "Usage: /banhistory [identifier]",
    
    -- Success
    ['ban_success'] = "%s has been permanently banned. Reason: %s",
    ['tempban_success'] = "%s has been temporarily banned for %s. Reason: %s",
    ['unban_success'] = "%s has been successfully unbanned",
    ['ban_expired'] = "Ban expired and removed for: %s",
    
    -- Errors
    ['no_permission'] = "You don't have permission to use this command",
    ['player_not_found'] = "Player not found",
    ['invalid_duration'] = "Invalid duration",
    ['no_ban_found'] = "No ban found for %s",
    ['identifier_error'] = "Error: Unable to retrieve identifier",
    ['already_banned'] = "This player is already banned",
    
    -- System messages
    ['checking_status'] = "Checking your status...",
    ['loading'] = "Loading...",
    ['system'] = "SYSTEM",
    
    -- Logs
    ['log_ban'] = "[BAN] %s banned %s (%s) - Reason: %s",
    ['log_tempban'] = "[TEMPBAN] %s temporarily banned %s (%s) for %s - Reason: %s",
    ['log_unban'] = "[UNBAN] %s unbanned %s",
    ['log_ban_check'] = "[CHECK] Checking ban for %s (%s)",
    ['log_ban_expire'] = "[EXPIRE] Ban automatically expired for %s",
    
    -- Time formatting
    ['time_format'] = "%d day(s) %02d:%02d:%02d",
    ['hours'] = "hour(s)",
    ['days'] = "day(s)",
    ['minutes'] = "minute(s)",
    ['seconds'] = "second(s)"
}

-- Fonction helper pour récupérer une traduction
function _U(key, ...)
    local locale = Config.Locale or 'fr'
    if Locale[locale] and Locale[locale][key] then
        local args = {...}
        local success, result = pcall(string.format, Locale[locale][key], ...)
        if success then
            return result
        else
            -- En cas d'erreur de formatage, retourner la clé
            print("^1[ERROR] Erreur de traduction pour la clé: " .. key .. "^0")
            return key
        end
    end
    return key
end
