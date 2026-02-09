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
