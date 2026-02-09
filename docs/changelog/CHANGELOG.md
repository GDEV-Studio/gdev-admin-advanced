# 📝 Changelog


## [2.0.0] - 09/02/2025

### 🎉 Nouvelle Architecture
- **Architecture modulaire complète** - Système divisé en modules indépendants
- **3 modules actifs** - BanCore, BanLogs, BanHistory
- **Configuration centralisée** - Toute la config dans un seul fichier
- **Système de traduction** - Support multilingue (FR/EN)

### ✨ Nouvelles Fonctionnalités

#### Module BAN_CORE
- Bannissement permanent et temporaire
- Vérification automatique à la connexion
- Suppression automatique des bans expirés
- Support multi-identifiants avec priorité configurable
- Anti-spam des commandes
- Messages de ban personnalisables avec/sans cadre
- Système de permissions ACE
- Commandes: `/ban`, `/tempban`, `/unban`, `/banlist`

#### Module BAN_LOGS
- Logs détaillés de toutes les actions
- Sauvegarde en base de données
- Logs console avec coloration syntaxique
- Système de rétention automatique (configurable)
- Filtrage avancé (action, joueur, admin, période)
- Nettoyage automatique des vieux logs
- Commande: `/banlogs [page] [action]`

#### Module BAN_HISTORY
- Historique complet par joueur
- Statistiques détaillées (total bans/tempbans/unbans)
- Sauvegarde de tous les identifiants du joueur
- Limite configurable d'entrées par joueur
- Nettoyage automatique des vieilles entrées
- Commandes: `/banhistory [identifier]`, `/banstats [identifier]`

#### Module BAN_WEBHOOK (Préparé)
- Structure prête pour webhooks Discord
- Embeds formatés pour bans/tempbans/unbans
- Configuration des couleurs
- À activer dans une future version

### 🛠️ Améliorations Techniques
- **Fichier utils.lua** - Fonctions réutilisables
- **Système d'événements** - Communication entre modules
- **Exports complets** - API pour autres ressources
- **Validation des données** - Sécurité renforcée
- **Documentation complète** - README détaillé
- **Installation SQL** - Script d'installation inclus

### 📊 Base de Données
- Table `bans` - Bans actifs avec index optimisés
- Table `ban_logs` - Logs de toutes les actions
- Table `ban_history` - Historique complet
- Index optimisés pour les performances

### 🎨 Personnalisation
- Configuration modulaire
- Messages personnalisables
- Locales FR/EN
- Écran de ban customisable
- Debug mode complet

### 🔐 Sécurité
- Validation stricte des identifiants
- Anti-spam configurable
- Permissions ACE granulaires
- Protection SQL injection
- Support RGPD (IP désactivable)

### 📡 API/Exports
```lua
- BanPlayer(playerId, reason, adminName)
- TempBanPlayer(playerId, duration, reason, adminName)
- UnbanPlayer(identifier, adminName)
- IsPlayerBanned(identifier, callback)
- GetBanList(page, limit, callback)
- GetPlayerHistory(identifier, callback)
- GetLogs(filters, callback)
```