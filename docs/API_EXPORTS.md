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
