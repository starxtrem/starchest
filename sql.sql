-- phpMyAdmin SQL Dump
-- version 4.9.2
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le :  Dim 12 juil. 2020 à 23:30
-- Version du serveur :  8.0.18
-- Version de PHP :  7.3.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données :  `osmoze`
--

-- --------------------------------------------------------

--
-- Structure de la table `starchest`
--

DROP TABLE IF EXISTS `starchest`;
CREATE TABLE IF NOT EXISTS `starchest` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `item` varchar(100) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `count` int(11) NOT NULL DEFAULT '0',
  `lieu` varchar(250) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `name` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `item_lieu` (`item`,`lieu`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `starchest_2`
--

DROP TABLE IF EXISTS `starchest_2`;
CREATE TABLE IF NOT EXISTS `starchest_2` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `money` int(11) NOT NULL,
  `black` int(11) NOT NULL,
  `lieu` varchar(250) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `loadout` longtext CHARACTER SET latin1 COLLATE latin1_swedish_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `lieu` (`lieu`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `starchest_access`
--

DROP TABLE IF EXISTS `starchest_access`;
CREATE TABLE IF NOT EXISTS `starchest_access` (
  `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `owner` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `lieu` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `label` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
