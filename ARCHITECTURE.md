# 🏗️ Architecture du Système

Documentation technique de l'architecture modulaire du système de bannissement.

## 📊 Vue d'Ensemble

```
┌─────────────────────────────────────────────────────────┐
│                    BAN SYSTEM v2.0                       │
│                 Architecture Modulaire                    │
└─────────────────────────────────────────────────────────┘
                            │
            ┌───────────────┼───────────────┐
            │               │               │
      ┌─────▼─────┐   ┌────▼────┐   ┌─────▼─────┐
      │  CONFIG   │   │  SERVER │   │  MODULES  │
      └───────────┘   └─────────┘   └───────────┘
```

## 📂 Structure des Dossiers

```
ban_system/
│
├── 📁 config/                      # Configuration & Traductions
│   ├── config.lua                  # Configuration principale
│   └── locale.lua                  # Système de traduction (FR/EN)
│
├── 📁 server/                      # Code serveur central
│   ├── utils.lua                   # Fonctions utilitaires partagées
│   └── main.lua                    # Point d'entrée et exports
│
├── 📁 modules/                     # Modules fonctionnels
│   │
│   ├── 📁 ban_core/               # Module de base (OBLIGATOIRE)
│   │   └── server.lua             # Bannissement, vérification, commandes
│   │
│   ├── 📁 ban_logs/               # Module de logs
│   │   └── server.lua             # Enregistrement et consultation des logs
│   │
│   ├── 📁 ban_history/            # Module d'historique
│   │   └── server.lua             # Historique et statistiques par joueur
│   │
│   └── 📁 ban_webhook/            # Module webhooks (à venir)
│       └── server.lua             # Intégration Discord
│
├── 📄 fxmanifest.lua               # Manifest FiveM
├── 📄 install.sql                  # Installation base de données
├── 📄 README.md                    # Documentation utilisateur
├── 📄 CONTRIBUTING.md              # Guide de contribution
├── 📄 CHANGELOG.md                 # Historique des versions
├── 📄 TODO.md                      # Feuille de route
├── 📄 LICENSE                      # Licence MIT
├── 📄 .gitignore                   # Fichiers à ignorer
└── 📄 server.cfg.example           # Exemple de configuration serveur
```

## 🔄 Flux de Données

### 1. Initialisation au Démarrage

```
FiveM Server Start
        │
        ▼
   Load Manifest
        │
        ▼
   Load Config ─────────► Config Tables Created
        │                      │
        ▼                      │
   Load Locales ◄─────────────┘
        │
        ▼
   Load Utils ───────────► Utility Functions Ready
        │
        ▼
   Load Modules:
        ├─► BAN_CORE
        ├─► BAN_LOGS
        ├─► BAN_HISTORY
        └─► BAN_WEBHOOK (if enabled)
        │
        ▼
   Server Ready
```

### 2. Vérification à la Connexion

```
Player Connecting
        │
        ▼
   Get Identifier ────────► Utils.GetPrimaryIdentifier()
        │                           │
        │                           ▼
        │                   Priority Check:
        │                   1. license:
        │                   2. steam:
        │                   3. discord:
        │                   4. xbl:
        │                   5. live:
        │                           │
        ◄───────────────────────────┘
        │
        ▼
   BanCore.CheckBan(identifier)
        │
        ├─► Query Database
        │        │
        │        ▼
        │   Ban Found?
        │        │
        │        ├─► Yes: Permanent?
        │        │        │
        │        │        ├─► Yes: Kick with Message
        │        │        │
        │        │        └─► No: Check Expiration
        │        │                 │
        │        │                 ├─► Expired: Delete & Allow
        │        │                 │
        │        │                 └─► Active: Kick with Message
        │        │
        │        └─► No: Allow Connection
        │
        ▼
   Player Connected/Kicked
```

### 3. Processus de Bannissement

```
Admin Command: /ban [ID] [raison]
        │
        ▼
   Check Permissions ───────► IsPlayerAceAllowed()
        │
        ▼
   Check Anti-Spam ─────────► Utils.CheckCommandCooldown()
        │
        ▼
   Validate Arguments
        │
        ▼
   Get Target Identifier
        │
        ▼
   BanCore.AddBan(data)
        │
        ├─► Check if Already Banned
        │        │
        │        └─► Already Banned: Error
        │
        ├─► Insert into Database
        │        │
        │        └─► Success?
        │
        ├─► Trigger Events:
        │        ├─► 'banSystem:playerBanned'
        │        │        │
        │        │        ├─► BAN_LOGS Module
        │        │        │        └─► Log to DB
        │        │        │
        │        │        ├─► BAN_HISTORY Module
        │        │        │        └─► Add to History
        │        │        │
        │        │        └─► BAN_WEBHOOK Module
        │        │                 └─► Send Discord Webhook
        │        │
        │        └─► Kick Player
        │
        ▼
   Response to Admin
```

## 🗄️ Structure de la Base de Données

### Table: `bans`
```sql
┌───────────────┬──────────────┬─────────────────────┐
│ Column        │ Type         │ Description         │
├───────────────┼──────────────┼─────────────────────┤
│ id            │ INT(11)      │ PK Auto-increment   │
│ identifier    │ VARCHAR(100) │ Player identifier   │
│ reason        │ TEXT         │ Ban reason          │
│ banned_by     │ VARCHAR(100) │ Admin name          │
│ ban_date      │ VARCHAR(50)  │ Date string         │
│ permanent     │ TINYINT(1)   │ 0=temp, 1=perm      │
│ expire_time   │ INT(11)      │ Unix timestamp      │
│ created_at    │ TIMESTAMP    │ Auto timestamp      │
└───────────────┴──────────────┴─────────────────────┘
Indexes: identifier (UNIQUE), expire_time, permanent
```

### Table: `ban_logs`
```sql
┌───────────────────┬──────────────┬─────────────────────┐
│ Column            │ Type         │ Description         │
├───────────────────┼──────────────┼─────────────────────┤
│ id                │ INT(11)      │ PK Auto-increment   │
│ action            │ VARCHAR(50)  │ BAN/TEMPBAN/UNBAN   │
│ admin_identifier  │ VARCHAR(100) │ Admin identifier    │
│ admin_name        │ VARCHAR(100) │ Admin name          │
│ target_identifier │ VARCHAR(100) │ Target identifier   │
│ target_name       │ VARCHAR(100) │ Target name         │
│ reason            │ TEXT         │ Action reason       │
│ additional_data   │ TEXT         │ JSON extra data     │
│ timestamp         │ INT(11)      │ Unix timestamp      │
│ created_at        │ TIMESTAMP    │ Auto timestamp      │
└───────────────────┴──────────────┴─────────────────────┘
Indexes: action, target_identifier, admin_identifier, timestamp
```

### Table: `ban_history`
```sql
┌───────────────────┬──────────────┬─────────────────────┐
│ Column            │ Type         │ Description         │
├───────────────────┼──────────────┼─────────────────────┤
│ id                │ INT(11)      │ PK Auto-increment   │
│ identifier        │ VARCHAR(100) │ Player identifier   │
│ player_name       │ VARCHAR(100) │ Player name         │
│ action            │ VARCHAR(50)  │ BAN/TEMPBAN/UNBAN   │
│ reason            │ TEXT         │ Action reason       │
│ admin_identifier  │ VARCHAR(100) │ Admin identifier    │
│ admin_name        │ VARCHAR(100) │ Admin name          │
│ duration          │ INT(11)      │ Hours (if tempban)  │
│ ban_date          │ VARCHAR(50)  │ Date string         │
│ expire_time       │ INT(11)      │ Unix timestamp      │
│ all_identifiers   │ TEXT         │ JSON all IDs        │
│ timestamp         │ INT(11)      │ Unix timestamp      │
│ created_at        │ TIMESTAMP    │ Auto timestamp      │
└───────────────────┴──────────────┴─────────────────────┘
Indexes: identifier, action, timestamp
```

## 🔌 Système d'Événements

### Événements Déclenchés

```lua
-- Joueur banni
TriggerEvent('banSystem:playerBanned', {
    identifier = string,
    playerName = string,
    reason = string,
    adminIdentifier = string,
    adminName = string,
    banDate = string,
    playerId = number
})

-- Joueur tempban
TriggerEvent('banSystem:playerTempBanned', {
    identifier = string,
    playerName = string,
    reason = string,
    adminIdentifier = string,
    adminName = string,
    duration = number,
    expireTime = number,
    banDate = string,
    playerId = number
})

-- Joueur débanni
TriggerEvent('banSystem:playerUnbanned', {
    identifier = string,
    playerName = string,
    adminIdentifier = string,
    adminName = string,
    reason = string
})

-- Ban expiré
TriggerEvent('banSystem:banExpired', {
    identifier = string,
    expireTime = number
})

-- Vérification de ban
TriggerEvent('banSystem:banChecked', {
    identifier = string,
    playerName = string,
    isBanned = boolean,
    banType = string
})
```

### Écoute des Événements

```lua
-- Dans n'importe quel module
AddEventHandler('banSystem:playerBanned', function(data)
    -- Votre logique ici
    print("Joueur banni: " .. data.playerName)
end)
```

## 📡 API Exports

### Utilisation depuis une autre ressource

```lua
-- Bannir un joueur
local success = exports['ban_system']:BanPlayer(
    playerId,      -- number
    reason,        -- string
    adminName      -- string
)

-- Bannir temporairement
local success = exports['ban_system']:TempBanPlayer(
    playerId,      -- number
    duration,      -- number (heures)
    reason,        -- string
    adminName      -- string
)

-- Débannir
local success = exports['ban_system']:UnbanPlayer(
    identifier,    -- string
    adminName      -- string
)

-- Vérifier si banni (async)
exports['ban_system']:IsPlayerBanned(identifier, function(isBanned, banInfo)
    if isBanned then
        print("Banni pour: " .. banInfo.reason)
    end
end)

-- Obtenir la liste des bans
exports['ban_system']:GetBanList(page, limit, function(data)
    for _, ban in ipairs(data.bans) do
        print(ban.identifier .. " - " .. ban.reason)
    end
end)

-- Obtenir l'historique
exports['ban_system']:GetPlayerHistory(identifier, function(history)
    print("Total d'entrées: " .. #history)
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

## 🔐 Système de Permissions

### Hiérarchie ACE

```
Console (source = 0)
    └─► Tous les droits
        │
Group: admin
    ├─► command.ban
    ├─► command.tempban
    ├─► command.unban
    ├─► command.banlist
    ├─► command.banhistory
    └─► command.banlogs
        │
Group: moderator
    ├─► command.tempban
    ├─► command.banlist
    ├─► command.banhistory
    └─► command.banlogs
        │
Group: support
    ├─► command.banlist
    ├─► command.banhistory
    └─► command.banlogs (lecture seule)
```

## 🔧 Système de Configuration

### Ordre de Priorité

```
1. Config.lua (principal)
    └─► Modules actifs/inactifs
    └─► Paramètres généraux
    └─► Identifiants prioritaires
    └─► Anti-spam

2. Locale.lua (traductions)
    └─► Messages système
    └─► Messages d'erreur
    └─► Formats de temps

3. Utils.lua (fonctions)
    └─► Validation
    └─► Formatage
    └─► Sécurité
```

## 🚀 Performance

### Optimisations Appliquées

1. **Index SQL** - Toutes les colonnes fréquemment recherchées
2. **Callbacks asynchrones** - Pas de blocage du thread principal
3. **Cache anti-spam** - Mémorisation des cooldowns
4. **Nettoyage automatique** - Suppression des données expirées
5. **Requêtes préparées** - Protection SQL injection + performance

### Charge Estimée

```
Connexion joueur:    ~5-10ms
Commande ban:        ~15-20ms
Commande banlist:    ~20-30ms (selon pagination)
Commande banhistory: ~25-35ms
Logs automatiques:   ~5ms (asynchrone)
```

## 📈 Scalabilité

Le système supporte:
- ✅ 1-1000 joueurs simultanés
- ✅ Millions d'entrées en base de données
- ✅ Multi-serveurs (avec BDD centralisée)
- ✅ Extension via modules personnalisés

## 🔮 Extensibilité

### Créer un Module Personnalisé

```lua
-- modules/mon_module/server.lua
if not Config.Modules.MonModule then return end

MonModule = {}

-- S'abonner aux événements
AddEventHandler('banSystem:playerBanned', function(data)
    -- Votre logique
end)

-- Exposer des fonctions
function MonModule.MaFonction()
    -- Code
end

-- Export optionnel
exports('MaFonctionExportee', MonModule.MaFonction)
```

---

**Version:** 2.0.0  
**Dernière mise à jour:** Février 2025  
**Maintenu par:** La communauté Ban System
