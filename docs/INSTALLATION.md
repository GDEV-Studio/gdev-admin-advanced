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

# ================================
# PERMISSIONS ACE - GROUPE ADMIN
# ================================
add_ace group.admin command.ban allow
add_ace group.admin command.tempban allow
add_ace group.admin command.unban allow
add_ace group.admin command.banlist allow
add_ace group.admin command.banhistory allow
add_ace group.admin command.banstats allow
add_ace group.admin command.banlogs allow

# ================================
# PERMISSIONS ACE - GROUPE MODERATOR
# (Optionnel - permissions limitées)
# ================================
add_ace group.moderator command.tempban allow
add_ace group.moderator command.banlist allow
add_ace group.moderator command.banhistory allow
add_ace group.moderator command.banlogs allow

# ================================
# PERMISSIONS ACE - GROUPE SUPPORT
# (Optionnel - lecture seule)
# ================================
add_ace group.support command.banlist allow
add_ace group.support command.banhistory allow
add_ace group.support command.banlogs allow

# ================================
# AJOUTER DES UTILISATEURS AUX GROUPES
# Remplacez "license:xxx" par le vrai identifier
# ================================

# Admins (tous les droits)
add_principal identifier.license:xxx group.admin

# Modérateurs (pas de ban permanent)
add_principal identifier.license:yyy group.moderator

# Support (lecture seule)
add_principal identifier.license:zzz group.support
```

> **💡 Astuce :** Pour obtenir votre identifier, connectez-vous au serveur puis tapez dans la console F8 :
> ```lua
> print(GetPlayerIdentifiers(GetPlayerServerId(PlayerId()))[1])
> ```

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

### 4. Vérifications importantes

- ✅ **oxmysql** doit être installé et configuré
- ✅ Le fichier `install.sql` doit être exécuté **avant** le premier démarrage
- ✅ Les identifiers supportés : `license`, `steam`, `discord`, `xbl`, `live`
- ✅ Configurez votre lien Discord dans `config/config.lua`
