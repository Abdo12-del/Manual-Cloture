-- MySQL dump 10.13  Distrib 5.1.68, for Win32 (ia32)
--
-- Host: localhost    Database: ss2015
-- ------------------------------------------------------
-- Server version	5.1.68-community

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `userz`
--

DROP TABLE IF EXISTS `userz`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userz` (
  `idusers` int(11) NOT NULL AUTO_INCREMENT,
  `nomUser` varchar(100) NOT NULL,
  `passWord` varchar(100) NOT NULL DEFAULT '0000',
  `adrese` varchar(100) DEFAULT NULL,
  `tel` varchar(100) DEFAULT NULL,
  `mobile` varchar(100) DEFAULT NULL,
  `eMail` varchar(100) DEFAULT NULL,
  `Annuler` tinyint(1) DEFAULT NULL,
  `canAdmin` tinyint(1) DEFAULT NULL,
  `canSell` tinyint(1) DEFAULT NULL,
  `canBuy` tinyint(1) DEFAULT NULL,
  `Photo` blob,
  `canSellCont` tinyint(1) DEFAULT NULL,
  `canFacturer` tinyint(1) DEFAULT NULL,
  `idDoss` int(11) DEFAULT NULL,
  `dbname` varchar(45) DEFAULT NULL,
  `superAdmin` bit(1) DEFAULT NULL,
  `canRemise` bit(1) DEFAULT NULL,
  `canChangePrice` bit(1) DEFAULT NULL COMMENT 'pour contoire',
  PRIMARY KEY (`idusers`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userz`
--

LOCK TABLES `userz` WRITE;
/*!40000 ALTER TABLE `userz` DISABLE KEYS */;
INSERT INTO `userz` VALUES (1,'Administrateur','0000',NULL,NULL,NULL,NULL,0,1,1,1,NULL,1,1,1,'2015',1,1,1),(2,'Utilisareur 1','1111',NULL,NULL,NULL,NULL,0,0,0,0,NULL,1,0,1,'2015',0,0,0);
/*!40000 ALTER TABLE `userz` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categoris`
--

DROP TABLE IF EXISTS `categoris`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categoris` (
  `idCategori` int(11) NOT NULL AUTO_INCREMENT,
  `NomCat` varchar(45) DEFAULT NULL,
  `idDoss` int(11) DEFAULT NULL,
  `idusers` int(11) DEFAULT NULL,
  `photo` blob,
  `isCCC` bit(1) DEFAULT NULL,
  `cccValeur` decimal(18,6) DEFAULT NULL,
  `cccBonus` decimal(18,0) DEFAULT NULL,
  PRIMARY KEY (`idCategori`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categoris`
--

LOCK TABLES `categoris` WRITE;
/*!40000 ALTER TABLE `categoris` DISABLE KEYS */;
INSERT INTO `categoris` VALUES (1,'Toute',1,1,NULL,'',NULL,NULL);
/*!40000 ALTER TABLE `categoris` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dosse`
--

DROP TABLE IF EXISTS `dosse`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dosse` (
  `idDoss` int(11) NOT NULL AUTO_INCREMENT,
  `RaiSocial` varchar(100) NOT NULL,
  `ContactName` varchar(100) DEFAULT NULL,
  `adrese` varchar(150) DEFAULT NULL,
  `Tel` varchar(100) DEFAULT NULL,
  `Mobile` varchar(100) DEFAULT NULL,
  `eMail` varchar(100) DEFAULT NULL,
  `Annuler` bit(1) DEFAULT b'0',
  `Logo` mediumblob,
  `RC` varchar(45) DEFAULT NULL,
  `MF` varchar(45) DEFAULT NULL,
  `NIS` varchar(45) DEFAULT NULL,
  `ARTI` varchar(45) DEFAULT NULL,
  `CompBanc` varchar(100) DEFAULT NULL,
  `Capital` decimal(18,2) DEFAULT NULL,
  `idyears` int(11) DEFAULT NULL,
  `Activity` varchar(200) DEFAULT NULL,
  `RaiSocialAR` varchar(100) DEFAULT NULL,
  `adreseAR` varchar(200) DEFAULT NULL,
  `ActivityAR` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`idDoss`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dosse`
--

LOCK TABLES `dosse` WRITE;
/*!40000 ALTER TABLE `dosse` DISABLE KEYS */;
INSERT INTO `dosse` VALUES (1,'gamadev inc.','Boubaker','CITY 300 LOGT EL-OUED','032.14.22.03','0664.198.606','info@gamadev.com','\0',NULL,' ',' ',' ',' ',NULL,NULL,NULL,'SELLING COMPUTER SOFTWARE','شركة قاماديف','حي 300 سكن الوادي','بيع برامج الكمبيوتر');
/*!40000 ALTER TABLE `dosse` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2015-11-17  0:48:03
