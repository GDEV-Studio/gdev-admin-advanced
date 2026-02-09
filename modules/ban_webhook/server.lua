-- ================================
-- MODULE: BAN_WEBHOOK (À VENIR)
-- Intégration Discord via Webhooks
-- ================================

if not Config.Modules.BanWebhook then return end

BanWebhook = {}

-- ================================
-- ENVOYER UN WEBHOOK
-- ================================

function BanWebhook.Send(data)
    if not Config.Webhook.Enabled or not Config.Webhook.URL or Config.Webhook.URL == "" then
        return
    end
    
    local embed = {
        {
            ["title"] = data.title,
            ["description"] = data.description,
            ["color"] = data.color,
            ["fields"] = data.fields or {},
            ["footer"] = {
                ["text"] = "Ban System v" .. Config.Version,
                ["icon_url"] = Config.Webhook.Avatar
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }
    
    PerformHttpRequest(Config.Webhook.URL, function(err, text, headers)
        if err ~= 200 then
            Utils.Debug("Erreur webhook: " .. err, "error")
        end
    end, 'POST', json.encode({
        username = Config.Webhook.Username,
        avatar_url = Config.Webhook.Avatar,
        embeds = embed
    }), {['Content-Type'] = 'application/json'})
end

-- ================================
-- FORMATAGE DES EMBEDS
-- ================================

function BanWebhook.FormatBanEmbed(data)
    return {
        title = "🔨 Nouveau Bannissement",
        description = string.format("**%s** a été banni du serveur", data.playerName),
        color = Config.Webhook.Colors.Ban,
        fields = {
            {
                name = "Joueur",
                value = string.format("%s\n`%s`", data.playerName, data.identifier),
                inline = true
            },
            {
                name = "Admin",
                value = data.adminName,
                inline = true
            },
            {
                name = "Type",
                value = "Permanent",
                inline = true
            },
            {
                name = "Raison",
                value = data.reason,
                inline = false
            },
            {
                name = "Date",
                value = data.banDate,
                inline = true
            }
        }
    }
end

function BanWebhook.FormatTempBanEmbed(data)
    return {
        title = "⏰ Bannissement Temporaire",
        description = string.format("**%s** a été banni temporairement", data.playerName),
        color = Config.Webhook.Colors.Tempban,
        fields = {
            {
                name = "Joueur",
                value = string.format("%s\n`%s`", data.playerName, data.identifier),
                inline = true
            },
            {
                name = "Admin",
                value = data.adminName,
                inline = true
            },
            {
                name = "Durée",
                value = Utils.FormatDuration(data.duration),
                inline = true
            },
            {
                name = "Raison",
                value = data.reason,
                inline = false
            },
            {
                name = "Date",
                value = data.banDate,
                inline = true
            },
            {
                name = "Expiration",
                value = os.date("%d/%m/%Y %H:%M:%S", data.expireTime),
                inline = true
            }
        }
    }
end

function BanWebhook.FormatUnbanEmbed(data)
    return {
        title = "✅ Débannissement",
        description = string.format("**%s** a été débanni", data.playerName or "Joueur"),
        color = Config.Webhook.Colors.Unban,
        fields = {
            {
                name = "Identifier",
                value = string.format("`%s`", data.identifier),
                inline = false
            },
            {
                name = "Admin",
                value = data.adminName,
                inline = true
            },
            {
                name = "Raison",
                value = data.reason or "Débannissement manuel",
                inline = false
            }
        }
    }
end

-- ================================
-- HOOKS SUR LES ÉVÉNEMENTS
-- ================================

AddEventHandler('banSystem:playerBanned', function(data)
    BanWebhook.Send(BanWebhook.FormatBanEmbed(data))
end)

AddEventHandler('banSystem:playerTempBanned', function(data)
    BanWebhook.Send(BanWebhook.FormatTempBanEmbed(data))
end)

AddEventHandler('banSystem:playerUnbanned', function(data)
    BanWebhook.Send(BanWebhook.FormatUnbanEmbed(data))
end)

-- ================================
-- INITIALISATION
-- ================================

if Config.Webhook.Enabled and Config.Webhook.URL ~= "" then
    Utils.Log("^2Module BAN_WEBHOOK chargé avec succès", "INFO")
    
    -- Test du webhook
    BanWebhook.Send({
        title = "🟢 Système de Bannissement",
        description = "Le système de bannissement est maintenant actif",
        color = 3066993,
        fields = {
            {
                name = "Version",
                value = Config.Version,
                inline = true
            },
            {
                name = "Modules",
                value = "BanCore, BanLogs, BanHistory, BanWebhook",
                inline = true
            }
        }
    })
else
    Utils.Log("^3Module BAN_WEBHOOK chargé mais désactivé (pas d'URL configurée)", "WARNING")
end
