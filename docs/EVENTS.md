## 📝 Événements Déclenchés

Le système déclenche des événements pour les modules :

```lua
-- Joueur banni
TriggerEvent('banSystem:playerBanned', {
    identifier = "license:xxx",
    playerName = "Yusu Sauvage",
    reason = "Cheat",
    adminIdentifier = "license:yyy",
    adminName = "Admin",
    banDate = "01/01/2025",
    playerId = 1
})

-- Joueur tempban
TriggerEvent('banSystem:playerTempBanned', data)

-- Joueur débanni
TriggerEvent('banSystem:playerUnbanned', data)

-- Ban expiré
TriggerEvent('banSystem:banExpired', data)

-- Vérification de ban
TriggerEvent('banSystem:banChecked', data)
```
