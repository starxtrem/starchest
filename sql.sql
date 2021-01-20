-- --------------------------------------------------------
-- Hôte :                        127.0.0.1
-- Version du serveur:           8.0.21 - MySQL Community Server - GPL
-- SE du serveur:                Win64
-- HeidiSQL Version:             11.0.0.5919
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Listage de la structure de la base pour essentialmode
CREATE DATABASE IF NOT EXISTS `essentialmode` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `essentialmode`;

-- Listage de la structure de la table essentialmode. starchest
CREATE TABLE IF NOT EXISTS `starchest` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `item` varchar(100) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `count` int NOT NULL DEFAULT '0',
  `lieu` varchar(250) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `name` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `item_lieu` (`item`,`lieu`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Listage des données de la table essentialmode.starchest : ~143 rows (environ)
DELETE FROM `starchest`;
/*!40000 ALTER TABLE `starchest` DISABLE KEYS */;
/*!40000 ALTER TABLE `starchest` ENABLE KEYS */;

-- Listage de la structure de la table essentialmode. starchest_2
CREATE TABLE IF NOT EXISTS `starchest_2` (
  `id` int NOT NULL AUTO_INCREMENT,
  `money` int NOT NULL,
  `black` int NOT NULL,
  `lieu` varchar(250) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `loadout` longtext CHARACTER SET latin1 COLLATE latin1_swedish_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `lieu` (`lieu`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Listage des données de la table essentialmode.starchest_2 : ~13 rows (environ)
DELETE FROM `starchest_2`;
/*!40000 ALTER TABLE `starchest_2` DISABLE KEYS */;
/*!40000 ALTER TABLE `starchest_2` ENABLE KEYS */;

-- Listage de la structure de la table essentialmode. starchest_access
CREATE TABLE IF NOT EXISTS `starchest_access` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `owner` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `lieu` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '0',
  `label` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `x` varchar(100) DEFAULT NULL,
  `y` varchar(100) DEFAULT NULL,
  `z` varchar(100) DEFAULT NULL,
  `granted` int DEFAULT '0',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Listage des données de la table essentialmode.starchest_access : ~90 rows (environ)
DELETE FROM `starchest_access`;
/*!40000 ALTER TABLE `starchest_access` DISABLE KEYS */;
/*!40000 ALTER TABLE `starchest_access` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;


INSERT INTO `items` (name, label, weight) VALUES
	('coffreauto','coffre entreprise', 2)
;