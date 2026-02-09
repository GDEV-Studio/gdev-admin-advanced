-- ================================
-- FICHIER UTILITAIRE
-- Fonctions réutilisables pour tous les modules
-- ================================

Utils = {}

-- ================================
-- DEBUG & LOGGING
-- ================================

function Utils.Debug(message, type)
    if not Config.Debug.Enabled then return end
    
    local prefix = "^3[DEBUG]^0"
    if type == "error" then
        prefix = "^1[ERROR]^0"
    elseif type == "success" then
        prefix = "^2[SUCCESS]^0"
    elseif type == "warning" then
        prefix = "^3[WARNING]^0"
    end
    
    print(string.format("%s %s", prefix, message))
end

function Utils.Log(message, logType)
    logType = logType or "INFO"
    
    if Config.Debug.PrintLogs then
        local colors = {
            BAN = "^1",
            TEMPBAN = "^3",
            UNBAN = "^2",
            INFO = "^5",
            ERROR = "^1",
            WARNING = "^3"
        }
        
        local color = colors[logType] or "^0"
        print(string.format("%s[%s]^0 %s", color, logType, message))
    end
end

-- ================================
-- IDENTIFIANTS
-- ================================

function Utils.GetPrimaryIdentifier(src)
    local identifiers = GetPlayerIdentifiers(src)
    
    if Config.Debug.PrintIdentifiers then
        Utils.Debug("Identifiants trouvés pour le joueur " .. src .. ":")
        for _, id in pairs(identifiers) do
            print("  - " .. id)
        end
    end
    
    -- Parcourir les priorités définies dans la config
    for _, idType in ipairs(Config.Identifiers.Priority) do
        for _, id in pairs(identifiers) do
            if string.match(id, "^" .. idType .. ":") then
                Utils.Debug("Identifier utilisé: " .. id)
                return id
            end
        end
    end
    
    -- Fallback sur IP si autorisé (non recommandé)
    if Config.Identifiers.AllowIP then
        for _, id in pairs(identifiers) do
            if string.match(id, "^ip:") then
                Utils.Debug("Identifier IP utilisé (fallback): " .. id, "warning")
                return id
            end
        end
    end
    
    return nil
end

function Utils.GetAllIdentifiers(src)
    return GetPlayerIdentifiers(src)
end

function Utils.GetIdentifierType(identifier)
    if not identifier then return nil end
    return identifier:match("^([^:]+):")
end

-- ================================
-- FORMATAGE DE TEMPS
-- ================================

function Utils.FormatTime(seconds)
    -- Validation
    if not seconds or seconds < 0 then
        seconds = 0
    end
    
    local days = math.floor(seconds / 86400)
    seconds = seconds % 86400
    local hours = math.floor(seconds / 3600)
    seconds = seconds % 3600
    local minutes = math.floor(seconds / 60)
    seconds = seconds % 60
    
    return string.format("%d jour(s) %02d:%02d:%02d", days, hours, minutes, seconds)
end

function Utils.FormatDuration(hours)
    if hours < 24 then
        return string.format("%d heure(s)", hours)
    else
        local days = math.floor(hours / 24)
        return string.format("%d jour(s)", days)
    end
end

function Utils.GetCurrentDate()
    return os.date("%d/%m/%Y %H:%M:%S")
end

function Utils.GetTimestamp()
    return os.time()
end

-- ================================
-- VALIDATION
-- ================================

function Utils.IsValidIdentifier(identifier)
    if not identifier or type(identifier) ~= "string" then
        return false
    end
    
    -- Vérifier le format identifier:value
    return identifier:match("^[a-z]+:.+") ~= nil
end

function Utils.IsValidDuration(duration)
    return type(duration) == "number" and duration > 0
end

function Utils.IsValidPlayerId(playerId)
    return playerId and GetPlayerName(playerId) ~= nil
end

-- ================================
-- PERMISSIONS
-- ================================

function Utils.HasPermission(source, permission)
    if source == 0 then return true end -- Console a toutes les permissions
    return IsPlayerAceAllowed(source, permission)
end

function Utils.GetPlayerName(source)
    if source == 0 then
        return "Console"
    end
    return GetPlayerName(source) or "Inconnu"
end

-- ================================
-- BASE DE DONNÉES
-- ================================

function Utils.GetTableName(tableType)
    if tableType == "bans" then
        return Config.Database.TableName
    elseif tableType == "logs" then
        return Config.Database.LogsTableName
    elseif tableType == "history" then
        return Config.Database.HistoryTableName
    end
    return Config.Database.TableName
end

function Utils.EscapeSQL(str)
    if not str then return "" end
    return str:gsub("'", "''")
end

-- ================================
-- MESSAGES
-- ================================

function Utils.BuildBanMessage(banInfo, timeLeftFormatted)
    local discord = (Config.Support and Config.Support.DiscordInvite) or ""
    local contact = (Config.Support and Config.Support.ContactText) or "Discord :"
    
    -- Avec cadre
    if Config.BanScreen and Config.BanScreen.UseFrame then
        if banInfo.permanent then
            local msg = [[


|  📌 Raison       : %s
|  👮 Banni par    : %s
|  📅 Date du ban  : %s
|
|  💬 %s
|  🔗 %s
]]
            if Config.BanScreen.ShowIdentifier and banInfo.identifier then
                msg = msg .. string.format("|\n|  🔑 Identifier  : %s\n", banInfo.identifier)
            end
            
            return string.format(msg,
                tostring(banInfo.reason or "Inconnue"),
                tostring(banInfo.bannedBy or "Console"),
                tostring(banInfo.banDate or "Inconnu"),
                contact,
                discord
            )
        else
            local msg = [[


|  📌 Raison        : %s
|  👮 Banni par     : %s
|  📅 Date du ban   : %s
|  ⏳ Temps restant : %s
|
|  💬 %s
|  🔗 %s
]]
            if Config.BanScreen.ShowIdentifier and banInfo.identifier then
                msg = msg .. string.format("|\n|  🔑 Identifier  : %s\n", banInfo.identifier)
            end
            
            return string.format(msg,
                tostring(banInfo.reason or "Inconnue"),
                tostring(banInfo.bannedBy or "Console"),
                tostring(banInfo.banDate or "Inconnu"),
                tostring(timeLeftFormatted or "Inconnu"),
                contact,
                discord
            )
        end
    end
    
    -- Sans cadre
    if banInfo.permanent then
        return string.format([[


📌 Raison       : %s
👮 Banni par    : %s
📅 Date du ban  : %s

💬 %s
🔗 %s
]],
            tostring(banInfo.reason or "Inconnue"),
            tostring(banInfo.bannedBy or "Console"),
            tostring(banInfo.banDate or "Inconnu"),
            contact,
            discord
        )
    else
        return string.format([[


📌 Raison        : %s
👮 Banni par     : %s
📅 Date du ban   : %s
⏳ Temps restant : %s

💬 %s
🔗 %s
]],
            tostring(banInfo.reason or "Inconnue"),
            tostring(banInfo.bannedBy or "Console"),
            tostring(banInfo.banDate or "Inconnu"),
            tostring(timeLeftFormatted or "Inconnu"),
            contact,
            discord
        )
    end
end

function Utils.SendChatMessage(source, message, type)
    if source == 0 then
        print(message)
    else
        local color = "^0"
        if type == "error" then
            color = "^1"
        elseif type == "success" then
            color = "^2"
        elseif type == "warning" then
            color = "^3"
        end
        
        TriggerClientEvent('chat:addMessage', source, {
            args = {color .. _U('system'), message}
        })
    end
end

-- ================================
-- ANTI-SPAM
-- ================================

Utils.CommandCooldowns = {}

function Utils.CheckCommandCooldown(source, command)
    if not Config.AntiSpam.Enabled then return true end
    if source == 0 then return true end -- Console pas de cooldown
    
    local identifier = Utils.GetPrimaryIdentifier(source)
    if not identifier then return true end
    
    local key = identifier .. "_" .. command
    local now = os.time()
    
    if Utils.CommandCooldowns[key] then
        local timeDiff = now - Utils.CommandCooldowns[key]
        if timeDiff < Config.AntiSpam.CooldownSeconds then
            return false, Config.AntiSpam.CooldownSeconds - timeDiff
        end
    end
    
    Utils.CommandCooldowns[key] = now
    return true
end

-- ================================
-- EXPORT DES FONCTIONS
-- ================================

return Utils
