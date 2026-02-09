# 🤝 Guide de Contribution

Merci de votre intérêt pour contribuer au système de bannissement modulaire !

## 📋 Comment Contribuer

### 1. Reporter un Bug

Avant de créer un rapport de bug :
- Vérifiez que le bug n'a pas déjà été reporté
- Assurez-vous d'utiliser la dernière version
- Testez avec une configuration minimale

**Template de rapport de bug :**
```markdown
**Description du bug**
Description claire et concise du problème.

**Étapes pour reproduire**
1. Aller à '...'
2. Cliquer sur '...'
3. Erreur apparaît

**Comportement attendu**
Ce qui devrait se passer.

**Screenshots/Logs**
Si applicable, ajoutez des captures ou logs.

**Environnement**
- Version du système: [ex: 2.0.0]
- Version FiveM: [ex: 6683]
- Version de la base de données: [MySQL 8.0 / MariaDB 10.5]
- Modules actifs: [BanCore, BanLogs, etc.]
```

### 2. Proposer une Fonctionnalité

**Template de proposition :**
```markdown
**Problème résolu**
Quelle problématique cette fonctionnalité résout-elle ?

**Solution proposée**
Décrivez votre solution.

**Alternatives considérées**
Autres solutions envisagées.

**Informations additionnelles**
Tout contexte ou screenshot utile.
```

### 3. Pull Requests

#### Workflow
1. Fork le projet
2. Créez votre branche (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

#### Conventions de Code

**Lua Style Guide :**
```lua
-- Indentation: 4 espaces
-- Noms de fonctions: camelCase
-- Noms de variables: camelCase
-- Constantes: UPPER_CASE
-- Commentaires: français ou anglais

-- ✅ BON
function myFunction(playerName)
    local MAX_ATTEMPTS = 3
    local currentAttempt = 0
    
    if playerName then
        -- Faire quelque chose
    end
end

-- ❌ MAUVAIS
function MyFunction(player_name)
local maxAttempts=3
if player_name then
-- Code sans indentation
end
end
```

**Structure des Modules :**
```lua
-- ================================
-- MODULE: NOM_MODULE
-- Description du module
-- ================================

if not Config.Modules.NomModule then return end

NomModule = {}

-- ================================
-- FONCTIONS
-- ================================

function NomModule.MaFonction()
    -- Code
end

-- ================================
-- HOOKS/ÉVÉNEMENTS
-- ================================

AddEventHandler('event', function()
    -- Code
end)

-- ================================
-- INITIALISATION
-- ================================

Utils.Log("^2Module NOM_MODULE chargé avec succès", "INFO")
```

#### Tests

Avant de soumettre une PR :
- [ ] Testez votre code en jeu
- [ ] Vérifiez qu'il n'y a pas d'erreurs dans la console
- [ ] Testez avec les modules activés/désactivés
- [ ] Vérifiez la compatibilité avec la config par défaut
- [ ] Documentez les nouvelles fonctionnalités

#### Commits

**Format des messages de commit :**
```
type(scope): description courte

Description détaillée si nécessaire.

Fixes #123
```

**Types :**
- `feat`: Nouvelle fonctionnalité
- `fix`: Correction de bug
- `docs`: Documentation
- `style`: Formatage
- `refactor`: Refactoring
- `test`: Tests
- `chore`: Maintenance

**Exemples :**
```
feat(logs): ajout du filtrage par période
fix(core): correction vérification identifier
docs(readme): mise à jour installation
refactor(utils): optimisation formatTime
```

## 🏗️ Architecture

### Structure du Projet
```
ban_system/
├── config/              # Configuration
│   ├── config.lua      # Config principale
│   └── locale.lua      # Traductions
├── server/             # Code serveur
│   ├── utils.lua       # Fonctions utilitaires
│   └── main.lua        # Point d'entrée
├── modules/            # Modules
│   ├── ban_core/       # Module de base
│   ├── ban_logs/       # Logs
│   ├── ban_history/    # Historique
│   └── ban_webhook/    # Webhooks (à venir)
├── fxmanifest.lua      # Manifest FiveM
├── install.sql         # Installation BDD
└── README.md           # Documentation
```

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

## 🎨 Bonnes Pratiques

### Sécurité
- Toujours valider les données utilisateur
- Utiliser des requêtes préparées (jamais de concaténation SQL)
- Vérifier les permissions avant chaque action
- Logger les actions sensibles

### Performance
- Éviter les boucles dans les callbacks
- Limiter les requêtes SQL
- Utiliser des index sur les tables
- Cacher les données fréquemment utilisées

### Compatibilité
- Tester avec différentes versions de FiveM
- Supporter MySQL et MariaDB
- Maintenir la rétrocompatibilité quand possible
- Documenter les breaking changes

## 📝 Documentation

Toute nouvelle fonctionnalité doit inclure :
- Documentation dans README.md
- Commentaires dans le code
- Exemples d'utilisation
- Notes de migration si nécessaire

## ⚖️ Licence

En contribuant, vous acceptez que vos contributions soient sous la même licence MIT que le projet.

## 💬 Questions

Des questions ? Ouvrez une issue avec le tag `question` ou rejoignez notre Discord.

## 🙏 Reconnaissance

Tous les contributeurs seront ajoutés dans le README.md.

Merci pour vos contributions ! 🎉
