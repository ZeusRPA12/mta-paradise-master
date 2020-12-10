-- phpMyAdmin SQL Dump
-- version 4.7.1
-- https://www.phpmyadmin.net/
--
-- Host: sql9.freemysqlhosting.net
-- Generation Time: Oct 16, 2019 at 02:01 AM
-- Server version: 5.5.58-0ubuntu0.14.04.1
-- PHP Version: 7.0.33-0ubuntu0.16.04.3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `sql9308562`
--

-- --------------------------------------------------------

--
-- Table structure for table `3dtext`
--

CREATE TABLE `3dtext` (
  `textID` int(10) UNSIGNED NOT NULL,
  `text` text NOT NULL,
  `x` float NOT NULL,
  `y` float NOT NULL,
  `z` float NOT NULL,
  `interior` tinyint(3) UNSIGNED NOT NULL,
  `dimension` int(10) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `banks`
--

CREATE TABLE `banks` (
  `bankID` int(10) UNSIGNED NOT NULL,
  `x` float NOT NULL,
  `y` float NOT NULL,
  `z` float NOT NULL,
  `rotation` float NOT NULL,
  `interior` tinyint(3) UNSIGNED NOT NULL,
  `dimension` int(10) UNSIGNED NOT NULL,
  `skin` int(10) NOT NULL DEFAULT '-1'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `bank_accounts`
--

CREATE TABLE `bank_accounts` (
  `accountID` int(10) UNSIGNED NOT NULL,
  `characterID` int(10) UNSIGNED NOT NULL,
  `balance` bigint(20) UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `bank_cards`
--

CREATE TABLE `bank_cards` (
  `cardID` int(10) UNSIGNED NOT NULL,
  `bankAccountID` int(10) UNSIGNED NOT NULL,
  `pin` int(10) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `characters`
--

CREATE TABLE `characters` (
  `characterID` int(10) UNSIGNED NOT NULL,
  `characterName` varchar(22) NOT NULL,
  `userID` int(10) UNSIGNED NOT NULL,
  `x` float NOT NULL,
  `y` float NOT NULL,
  `z` float NOT NULL,
  `interior` tinyint(3) UNSIGNED NOT NULL,
  `dimension` int(10) UNSIGNED NOT NULL,
  `skin` int(10) UNSIGNED NOT NULL,
  `rotation` float NOT NULL,
  `health` tinyint(3) UNSIGNED NOT NULL DEFAULT '100',
  `armor` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `money` bigint(20) UNSIGNED NOT NULL DEFAULT '100',
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `lastLogin` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `weapons` varchar(255) DEFAULT NULL,
  `job` varchar(20) DEFAULT NULL,
  `languages` text
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `character_to_factions`
--

CREATE TABLE `character_to_factions` (
  `characterID` int(10) UNSIGNED NOT NULL,
  `factionID` int(10) UNSIGNED NOT NULL,
  `factionLeader` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `factionRank` tinyint(3) UNSIGNED NOT NULL DEFAULT '1'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `factions`
--

CREATE TABLE `factions` (
  `factionID` int(10) UNSIGNED NOT NULL,
  `groupID` int(10) UNSIGNED NOT NULL,
  `factionType` tinyint(3) UNSIGNED NOT NULL,
  `factionTag` varchar(10) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `faction_ranks`
--

CREATE TABLE `faction_ranks` (
  `factionID` int(10) UNSIGNED NOT NULL,
  `factionRankID` int(10) UNSIGNED NOT NULL,
  `factionRankName` varchar(64) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `fuelpoints`
--

CREATE TABLE `fuelpoints` (
  `fuelpointID` int(10) UNSIGNED NOT NULL,
  `posX` float NOT NULL,
  `posY` float NOT NULL,
  `posZ` float NOT NULL,
  `name` varchar(5) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `interiors`
--

CREATE TABLE `interiors` (
  `interiorID` int(10) UNSIGNED NOT NULL,
  `outsideX` float NOT NULL,
  `outsideY` float NOT NULL,
  `outsideZ` float NOT NULL,
  `outsideInterior` tinyint(3) UNSIGNED NOT NULL,
  `outsideDimension` int(10) UNSIGNED NOT NULL,
  `insideX` float NOT NULL,
  `insideY` float NOT NULL,
  `insideZ` float NOT NULL,
  `insideInterior` tinyint(3) UNSIGNED NOT NULL,
  `interiorName` varchar(255) NOT NULL,
  `interiorType` tinyint(3) UNSIGNED NOT NULL,
  `interiorPrice` int(10) UNSIGNED NOT NULL,
  `characterID` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `locked` tinyint(3) NOT NULL DEFAULT '0',
  `dropoffX` float DEFAULT NULL,
  `dropoffY` float DEFAULT NULL,
  `dropoffZ` float DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `items`
--

CREATE TABLE `items` (
  `index` int(10) UNSIGNED NOT NULL,
  `owner` int(10) UNSIGNED NOT NULL,
  `item` int(10) UNSIGNED NOT NULL,
  `value` text NOT NULL,
  `name` text
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `maps`
--

CREATE TABLE `maps` (
  `mapID` int(10) UNSIGNED NOT NULL,
  `mapName` varchar(255) NOT NULL,
  `mapDimension` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `protected` tinyint(3) UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `map_objects`
--

CREATE TABLE `map_objects` (
  `objectID` int(10) UNSIGNED NOT NULL,
  `mapID` int(10) UNSIGNED NOT NULL,
  `model` int(10) UNSIGNED NOT NULL,
  `x` float NOT NULL,
  `y` float NOT NULL,
  `z` float NOT NULL,
  `rx` float NOT NULL,
  `ry` float NOT NULL,
  `rz` float NOT NULL,
  `interior` tinyint(3) UNSIGNED NOT NULL,
  `alpha` tinyint(3) UNSIGNED NOT NULL DEFAULT '255',
  `doublesided` tinyint(3) UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `phones`
--

CREATE TABLE `phones` (
  `phoneNumber` int(10) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `shopitems`
--

CREATE TABLE `shopitems` (
  `shopItemID` int(10) UNSIGNED NOT NULL,
  `shopID` int(10) UNSIGNED NOT NULL,
  `item` int(10) UNSIGNED NOT NULL,
  `value` text NOT NULL,
  `name` text,
  `description` text,
  `price` int(10) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `shops`
--

CREATE TABLE `shops` (
  `shopID` int(10) UNSIGNED NOT NULL,
  `x` float NOT NULL,
  `y` float NOT NULL,
  `z` float NOT NULL,
  `rotation` float NOT NULL,
  `interior` tinyint(3) UNSIGNED NOT NULL,
  `dimension` int(10) UNSIGNED NOT NULL,
  `configuration` varchar(45) NOT NULL,
  `skin` int(10) UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `teleports`
--

CREATE TABLE `teleports` (
  `teleportID` int(10) UNSIGNED NOT NULL,
  `aX` float NOT NULL,
  `aY` float NOT NULL,
  `aZ` float NOT NULL,
  `aInterior` tinyint(3) UNSIGNED NOT NULL,
  `aDimension` int(10) UNSIGNED NOT NULL,
  `bX` float NOT NULL,
  `bY` float NOT NULL,
  `bZ` float NOT NULL,
  `bInterior` tinyint(3) UNSIGNED NOT NULL,
  `bDimension` int(10) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `vehicles`
--

CREATE TABLE `vehicles` (
  `vehicleID` int(10) UNSIGNED NOT NULL,
  `model` int(10) UNSIGNED NOT NULL,
  `posX` float NOT NULL,
  `posY` float NOT NULL,
  `posZ` float NOT NULL,
  `rotX` float NOT NULL,
  `rotY` float NOT NULL,
  `rotZ` float NOT NULL,
  `interior` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `dimension` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `respawnPosX` float NOT NULL,
  `respawnPosY` float NOT NULL,
  `respawnPosZ` float NOT NULL,
  `respawnRotX` float NOT NULL,
  `respawnRotY` float NOT NULL,
  `respawnRotZ` float NOT NULL,
  `respawnInterior` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `respawnDimension` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `numberplate` varchar(8) NOT NULL,
  `health` int(10) UNSIGNED NOT NULL DEFAULT '1000',
  `color1` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `color2` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `characterID` int(11) NOT NULL DEFAULT '0',
  `locked` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `engineState` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `lightsState` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `tintedWindows` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `fuel` float UNSIGNED NOT NULL DEFAULT '100'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `wcf1_group`
--

CREATE TABLE `wcf1_group` (
  `groupID` int(10) UNSIGNED NOT NULL,
  `groupName` varchar(255) NOT NULL DEFAULT '',
  `canBeFactioned` tinyint(1) UNSIGNED NOT NULL DEFAULT '1'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `wcf1_group`
--

INSERT INTO `wcf1_group` (`groupID`, `groupName`, `canBeFactioned`) VALUES
(1, 'MTA Moderators', 0),
(2, 'MTA Administrators', 0),
(3, 'Developers', 0);

-- --------------------------------------------------------

--
-- Table structure for table `wcf1_user`
--

CREATE TABLE `wcf1_user` (
  `userID` int(10) UNSIGNED NOT NULL,
  `username` varchar(255) NOT NULL,
  `password` varchar(40) NOT NULL,
  `salt` varchar(40) NOT NULL,
  `banned` tinyint(1) UNSIGNED NOT NULL DEFAULT '0',
  `activationCode` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `banReason` mediumtext,
  `banUser` int(10) UNSIGNED DEFAULT NULL,
  `lastIP` varchar(15) DEFAULT NULL,
  `lastSerial` varchar(32) DEFAULT NULL,
  `userOptions` text
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `wcf1_user_to_groups`
--

CREATE TABLE `wcf1_user_to_groups` (
  `userID` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `groupID` int(10) UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `wcf1_user_to_groups`
--

INSERT INTO `wcf1_user_to_groups` (`userID`, `groupID`) VALUES
(1, 2),
(1, 3);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `3dtext`
--
ALTER TABLE `3dtext`
  ADD PRIMARY KEY (`textID`);

--
-- Indexes for table `banks`
--
ALTER TABLE `banks`
  ADD PRIMARY KEY (`bankID`);

--
-- Indexes for table `bank_accounts`
--
ALTER TABLE `bank_accounts`
  ADD PRIMARY KEY (`accountID`);

--
-- Indexes for table `bank_cards`
--
ALTER TABLE `bank_cards`
  ADD PRIMARY KEY (`cardID`);

--
-- Indexes for table `characters`
--
ALTER TABLE `characters`
  ADD PRIMARY KEY (`characterID`);

--
-- Indexes for table `character_to_factions`
--
ALTER TABLE `character_to_factions`
  ADD PRIMARY KEY (`characterID`,`factionID`);

--
-- Indexes for table `factions`
--
ALTER TABLE `factions`
  ADD PRIMARY KEY (`factionID`);

--
-- Indexes for table `faction_ranks`
--
ALTER TABLE `faction_ranks`
  ADD PRIMARY KEY (`factionID`,`factionRankID`);

--
-- Indexes for table `fuelpoints`
--
ALTER TABLE `fuelpoints`
  ADD PRIMARY KEY (`fuelpointID`);

--
-- Indexes for table `interiors`
--
ALTER TABLE `interiors`
  ADD PRIMARY KEY (`interiorID`);

--
-- Indexes for table `items`
--
ALTER TABLE `items`
  ADD PRIMARY KEY (`index`);

--
-- Indexes for table `maps`
--
ALTER TABLE `maps`
  ADD PRIMARY KEY (`mapID`);

--
-- Indexes for table `map_objects`
--
ALTER TABLE `map_objects`
  ADD PRIMARY KEY (`objectID`);

--
-- Indexes for table `phones`
--
ALTER TABLE `phones`
  ADD PRIMARY KEY (`phoneNumber`);

--
-- Indexes for table `shopitems`
--
ALTER TABLE `shopitems`
  ADD PRIMARY KEY (`shopItemID`);

--
-- Indexes for table `shops`
--
ALTER TABLE `shops`
  ADD PRIMARY KEY (`shopID`);

--
-- Indexes for table `teleports`
--
ALTER TABLE `teleports`
  ADD PRIMARY KEY (`teleportID`);

--
-- Indexes for table `vehicles`
--
ALTER TABLE `vehicles`
  ADD PRIMARY KEY (`vehicleID`);

--
-- Indexes for table `wcf1_group`
--
ALTER TABLE `wcf1_group`
  ADD PRIMARY KEY (`groupID`);

--
-- Indexes for table `wcf1_user`
--
ALTER TABLE `wcf1_user`
  ADD PRIMARY KEY (`userID`);

--
-- Indexes for table `wcf1_user_to_groups`
--
ALTER TABLE `wcf1_user_to_groups`
  ADD PRIMARY KEY (`userID`,`groupID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `3dtext`
--
ALTER TABLE `3dtext`
  MODIFY `textID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `banks`
--
ALTER TABLE `banks`
  MODIFY `bankID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `bank_accounts`
--
ALTER TABLE `bank_accounts`
  MODIFY `accountID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=400000;
--
-- AUTO_INCREMENT for table `bank_cards`
--
ALTER TABLE `bank_cards`
  MODIFY `cardID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=200000;
--
-- AUTO_INCREMENT for table `characters`
--
ALTER TABLE `characters`
  MODIFY `characterID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `factions`
--
ALTER TABLE `factions`
  MODIFY `factionID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `fuelpoints`
--
ALTER TABLE `fuelpoints`
  MODIFY `fuelpointID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `interiors`
--
ALTER TABLE `interiors`
  MODIFY `interiorID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `items`
--
ALTER TABLE `items`
  MODIFY `index` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `maps`
--
ALTER TABLE `maps`
  MODIFY `mapID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `map_objects`
--
ALTER TABLE `map_objects`
  MODIFY `objectID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `phones`
--
ALTER TABLE `phones`
  MODIFY `phoneNumber` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=100000;
--
-- AUTO_INCREMENT for table `shopitems`
--
ALTER TABLE `shopitems`
  MODIFY `shopItemID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `shops`
--
ALTER TABLE `shops`
  MODIFY `shopID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `teleports`
--
ALTER TABLE `teleports`
  MODIFY `teleportID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `vehicles`
--
ALTER TABLE `vehicles`
  MODIFY `vehicleID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `wcf1_group`
--
ALTER TABLE `wcf1_group`
  MODIFY `groupID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `wcf1_user`
--
ALTER TABLE `wcf1_user`
  MODIFY `userID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
