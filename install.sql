-- ================================
-- INSTALLATION BASE DE DONNÉES
-- Système de bannissement modulaire
-- ================================

-- ================================
-- TABLE: bans
-- Stockage des bans actifs
-- ================================
CREATE TABLE IF NOT EXISTS `bans` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(100) NOT NULL,
    `reason` TEXT NOT NULL,
    `banned_by` VARCHAR(100) NOT NULL DEFAULT 'Console',
    `ban_date` VARCHAR(50) NOT NULL,
    `permanent` TINYINT(1) NOT NULL DEFAULT 0,
    `expire_time` INT(11) DEFAULT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `identifier` (`identifier`),
    KEY `expire_time` (`expire_time`),
    KEY `permanent` (`permanent`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================================
-- TABLE: ban_logs
-- Logs de toutes les actions
-- ================================
CREATE TABLE IF NOT EXISTS `ban_logs` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `action` VARCHAR(50) NOT NULL,
    `admin_identifier` VARCHAR(100) DEFAULT NULL,
    `admin_name` VARCHAR(100) NOT NULL,
    `target_identifier` VARCHAR(100) NOT NULL,
    `target_name` VARCHAR(100) DEFAULT NULL,
    `reason` TEXT DEFAULT NULL,
    `additional_data` TEXT DEFAULT NULL,
    `timestamp` INT(11) NOT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `action` (`action`),
    KEY `target_identifier` (`target_identifier`),
    KEY `admin_identifier` (`admin_identifier`),
    KEY `timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================================
-- TABLE: ban_history
-- Historique complet des bans
-- ================================
CREATE TABLE IF NOT EXISTS `ban_history` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(100) NOT NULL,
    `player_name` VARCHAR(100) DEFAULT NULL,
    `action` VARCHAR(50) NOT NULL,
    `reason` TEXT DEFAULT NULL,
    `admin_identifier` VARCHAR(100) DEFAULT NULL,
    `admin_name` VARCHAR(100) NOT NULL,
    `duration` INT(11) DEFAULT 0,
    `ban_date` VARCHAR(50) DEFAULT NULL,
    `expire_time` INT(11) DEFAULT NULL,
    `all_identifiers` TEXT DEFAULT NULL,
    `timestamp` INT(11) NOT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `identifier` (`identifier`),
    KEY `action` (`action`),
    KEY `timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================================
-- INDEX SUPPLÉMENTAIRES POUR PERFORMANCES
-- ================================
ALTER TABLE `bans` ADD INDEX IF NOT EXISTS `idx_identifier_permanent` (`identifier`, `permanent`);
ALTER TABLE `ban_logs` ADD INDEX IF NOT EXISTS `idx_target_action` (`target_identifier`, `action`);
ALTER TABLE `ban_history` ADD INDEX IF NOT EXISTS `idx_identifier_timestamp` (`identifier`, `timestamp`);

-- ================================
-- NOTES D'INSTALLATION
-- ================================
-- 1. Exécutez ce script SQL sur votre base de données
-- 2. Configurez le fichier config/config.lua avec vos paramètres
-- 3. Ajoutez les permissions ACE dans server.cfg:
--    add_ace group.admin command.ban allow
--    add_ace group.admin command.tempban allow
--    add_ace group.admin command.unban allow
--    add_ace group.admin command.banlist allow
--    add_ace group.admin command.banhistory allow
-- 4. Démarrez la ressource: ensure ban_system
-- ================================
