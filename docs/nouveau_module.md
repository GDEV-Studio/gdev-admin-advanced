### Créer un Nouveau Module

1. **Créer le dossier**
```bash
mkdir modules/mon_module
```

2. **Créer server.lua**
```lua
-- ================================
-- MODULE: MON_MODULE
-- Description
-- ================================

if not Config.Modules.MonModule then return end

MonModule = {}

-- Vos fonctions ici

Utils.Log("^2Module MON_MODULE chargé avec succès", "INFO")
```

3. **Ajouter dans fxmanifest.lua**
```lua
modules = {
    'ban_core',
    'ban_logs',
    'ban_history',
    'mon_module'  -- Nouveau module
}
```

4. **Ajouter dans config.lua**
```lua
Config.Modules = {
    BanCore = true,
    BanLogs = true,
    BanHistory = true,
    MonModule = false  -- Désactivé par défaut
}
```

5. **Documenter**
Ajoutez la documentation dans README.md