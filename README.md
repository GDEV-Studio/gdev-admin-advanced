# 🛡️ Système de Bannissement Modulaire

Système de bannissement avancé et modulaire pour FiveM avec logs détaillés, historique complet et architecture extensible.

## 📋 Caractéristiques

### ✅ Fonctionnalités Actuelles

- **Module BAN_CORE** (Obligatoire)
  - Bannissement permanent et temporaire
  - Vérification automatique à la connexion
  - Suppression automatique des bans expirés
  - Support multi-identifiants (license, steam, discord, etc.)
  - Anti-spam des commandes
  - Messages de ban personnalisables

- **Module BAN_LOGS**
  - Logs détaillés de toutes les actions
  - Sauvegarde en base de données
  - Console logs avec coloration
  - Système de rétention automatique
  - Filtrage par action, joueur, admin
  - Commande `/banlogs` pour consulter

- **Module BAN_HISTORY**
  - Historique complet par joueur
  - Statistiques détaillées
  - Sauvegarde des identifiants multiples
  - Limite configurable d'entrées
  - Commandes `/banhistory` et `/banstats`

### 🔜 Modules Prévus

- **BAN_APPEALS** - Système de contestation
- **BAN_WEBHOOK** - Intégration Discord

## 📦 Installation

### 1. Base de données

Exécutez le fichier `install.sql` sur votre base de données MySQL/MariaDB :

```sql
source install.sql
```

### 2. Configuration du serveur

Ajoutez dans votre `server.cfg` :

```cfg
# Démarrer la ressource
ensure ban_system

# Permissions ACE pour les admins
add_ace group.admin command.ban allow
add_ace group.admin command.tempban allow
add_ace group.admin command.unban allow
add_ace group.admin command.banlist allow
add_ace group.admin command.banhistory allow
add_ace group.admin command.banlogs allow
```

### 3. Configuration

Modifiez `config/config.lua` selon vos besoins :

```lua
Config.Support = {
    DiscordInvite = "https://discord.gg/votre-serveur",
    ContactText = "Pour contester, rejoignez le Discord :"
}

Config.Modules = {
    BanCore = true,      -- Obligatoire
    BanLogs = true,      -- Recommandé
    BanHistory = true,   -- Recommandé
    BanAppeals = false,  -- À venir
    BanWebhook = false   -- À venir
}
```



## 📊 Structure des Données

### Table: bans

```sql
id              INT         - ID unique
identifier      VARCHAR     - Identifier du joueur
reason          TEXT        - Raison du ban
banned_by       VARCHAR     - Qui a banni
ban_date        VARCHAR     - Date du ban
permanent       TINYINT     - 0 ou 1
expire_time     INT         - Timestamp d'expiration (NULL si permanent)
```

### Table: ban_logs

```sql
id                  INT         - ID unique
action              VARCHAR     - Type d'action (BAN, TEMPBAN, UNBAN, etc.)
admin_identifier    VARCHAR     - Identifier de l'admin
admin_name          VARCHAR     - Nom de l'admin
target_identifier   VARCHAR     - Identifier de la cible
target_name         VARCHAR     - Nom de la cible
reason              TEXT        - Raison
additional_data     TEXT        - Données JSON supplémentaires
timestamp           INT         - Timestamp Unix
```

### Table: ban_history

```sql
id                  INT         - ID unique
identifier          VARCHAR     - Identifier du joueur
player_name         VARCHAR     - Nom du joueur
action              VARCHAR     - Type d'action
reason              TEXT        - Raison
admin_identifier    VARCHAR     - Identifier de l'admin
admin_name          VARCHAR     - Nom de l'admin
duration            INT         - Durée (en heures pour tempban)
ban_date            VARCHAR     - Date du ban
expire_time         INT         - Timestamp d'expiration
all_identifiers     TEXT        - JSON de tous les identifiants
timestamp           INT         - Timestamp Unix
```

## 🎨 Personnalisation

### Messages de Ban

Modifiez les messages dans `config/locale.lua` :

```lua
Locale['fr'] = {
    ['ban_usage'] = "Usage: /ban [ID] [raison]",
    ['ban_success'] = "%s a été banni définitivement. Raison: %s",
    -- ...
}
```

### Écran de Ban

Personnalisez l'affichage dans `config/config.lua` :

```lua
Config.BanScreen = {
    UseFrame = true,  -- Afficher un cadre
    ShowIdentifier = false  -- Afficher l'identifier (debug)
}
```

## 🐛 Debug

Activez le mode debug pour le développement :

```lua
Config.Debug = {
    Enabled = true,
    PrintIdentifiers = true,
    PrintQueries = false,
    PrintLogs = true
}
```

## 📝 Événements Déclenchés

Le système déclenche des événements pour les modules :

```lua
-- Joueur banni
TriggerEvent('banSystem:playerBanned', {
    identifier = "license:xxx",
    playerName = "John Doe",
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

## 🔐 Sécurité

- Les identifiants sont vérifiés avant toute action
- Anti-spam des commandes configurable
- Permissions ACE strictes
- Validation des données avant insertion SQL
- Support du RGPD (désactivation de l'IP)

## 🆕 Prochaines Fonctionnalités

- [ ] Module de contestation des bans
- [ ] Webhooks Discord avec embeds
- [ ] Interface web d'administration
- [ ] Système de notes sur les joueurs
- [ ] Export des bans en CSV/JSON
- [ ] Système de warnings avant ban
- [ ] Intégration avec d'autres systèmes (ESX, QBCore)

## 📞 Support

Pour obtenir de l'aide :
1. Vérifiez la configuration dans `config/config.lua`
2. Consultez les logs serveur (`F8` en jeu)
3. Activez le mode debug
4. Rejoignez notre Discord https://discord.gg/sUvfxwcEUr

## 📄 Licence

Ce projet est sous licence MIT.

## 👥 Contributeurs

- Yusu_sauvage (900527489695236107) - Développeur principal

---

**Version:** 2.0.0  
**Dernière mise à jour:** Février 2025
