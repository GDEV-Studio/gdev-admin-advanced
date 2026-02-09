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
