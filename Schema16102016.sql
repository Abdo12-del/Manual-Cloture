
--
-- Table structure for table `activitys`
--

DROP TABLE IF EXISTS `activitys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `activitys` (
  `idactivity` int(11) NOT NULL AUTO_INCREMENT,
  `Nom` varchar(65) DEFAULT NULL,
  `iddoss` int(11) NOT NULL,
  `Observ` longtext,
  PRIMARY KEY (`idactivity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `appoption`
--

DROP TABLE IF EXISTS `appoption`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `appoption` (
  `NomOption` varchar(45) NOT NULL,
  `ValeurOption` varchar(45) DEFAULT NULL,
  `DesignAR` varchar(45) DEFAULT NULL,
  `DesignFR` varchar(45) DEFAULT NULL,
  `idDoss` int(11) NOT NULL,
  PRIMARY KEY (`NomOption`,`idDoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `articlesliste`
--

DROP TABLE IF EXISTS `articlesliste`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `articlesliste` (
  `RefArt` varchar(50) NOT NULL,
  `NomArt` varchar(100) NOT NULL,
  `RefColis` varchar(100) DEFAULT NULL,
  `QteColis` decimal(18,6) DEFAULT '0.000000',
  `QTE` decimal(18,6) DEFAULT '0.000000',
  `AlarmQte` decimal(18,6) DEFAULT NULL,
  `Marge` decimal(18,6) DEFAULT NULL,
  `PrixVD` decimal(18,6) DEFAULT '0.000000',
  `PrixVG` decimal(18,6) DEFAULT '0.000000',
  `PrixColisD` decimal(18,6) DEFAULT '0.000000',
  `PrixColisG` decimal(18,6) DEFAULT NULL,
  `idCat` int(11) DEFAULT NULL,
  `idModel` int(11) DEFAULT NULL,
  `photo` blob,
  `TVA` decimal(18,6) DEFAULT NULL,
  `expired` bit(1) DEFAULT b'0',
  `idDoss` int(11) NOT NULL,
  `Annuler` bit(1) DEFAULT b'0',
  `PrixInitial` decimal(18,6) DEFAULT NULL,
  `PrixAchat` decimal(18,6) DEFAULT NULL,
  `qpoid` bit(1) DEFAULT b'0' COMMENT 'pour la question de quantite (contoire)',
  `qprix` bit(1) DEFAULT b'0',
  `qColis` bit(1) DEFAULT b'0' COMMENT 'si la prix est pour la Colis ou un seul piece.',
  `qFedalite` bit(1) DEFAULT NULL,
  `Ninven` varchar(20) DEFAULT NULL,
  `isSelect` bit(1) DEFAULT b'0' COMMENT 'FIFO or Select to sell',
  `remise1` decimal(18,2) DEFAULT NULL,
  `remise2` decimal(18,2) DEFAULT NULL,
  `remise3` decimal(18,2) DEFAULT NULL,
  `remise4` decimal(18,2) DEFAULT NULL,
  `NomArtAR` varchar(100) DEFAULT NULL,
  `StopAlarm` bit(1) DEFAULT b'0',
  `marge2` decimal(18,2) DEFAULT NULL,
  `marge3` decimal(18,2) DEFAULT NULL,
  `marge4` decimal(18,2) DEFAULT NULL,
  `idunite` varchar(10) DEFAULT NULL,
  `PeriodPerimer` int(11) DEFAULT NULL,
  `PeriodAlarmDays` int(11) DEFAULT NULL,
  `QteInUnit` double DEFAULT NULL,
  `idUnitConverter` int(11) DEFAULT NULL,
  PRIMARY KEY (`RefArt`,`idDoss`),
  UNIQUE KEY `Ninven_UNIQUE` (`Ninven`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `articlesphotos`
--

DROP TABLE IF EXISTS `articlesphotos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `articlesphotos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Path` varchar(255) DEFAULT NULL,
  `Observ` varchar(255) DEFAULT NULL,
  `RefArt` varchar(45) DEFAULT NULL,
  `iddoss` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bonachats`
--

DROP TABLE IF EXISTS `bonachats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bonachats` (
  `idBonAcha` varchar(20) NOT NULL,
  `DateBon` datetime DEFAULT NULL,
  `Total` decimal(18,6) DEFAULT NULL,
  `TypeVers` bit(1) DEFAULT NULL,
  `Fournisseur` int(11) DEFAULT NULL,
  `Observ` varchar(100) DEFAULT NULL,
  `idDoss` int(11) NOT NULL,
  `idusers` int(11) DEFAULT NULL,
  `idyears` int(11) NOT NULL,
  `Nbon` varchar(45) DEFAULT NULL,
  `modepai` varchar(45) DEFAULT NULL,
  `Npayeur` varchar(65) DEFAULT NULL,
  `MontPaye` decimal(18,6) DEFAULT '0.000000',
  `MRemise` decimal(18,6) DEFAULT '0.000000',
  `NbonDat` date DEFAULT NULL,
  `idCompte` int(11) DEFAULT NULL,
  `RentingPrice` decimal(18,6) DEFAULT NULL,
  `CalcUnit` double DEFAULT NULL,
  `TotPoint` double DEFAULT NULL,
  `ProjectID` int(11) DEFAULT NULL,
  `NumCheq` varchar(45) DEFAULT NULL,
  `idModPay` int(11) DEFAULT NULL,
  PRIMARY KEY (`idBonAcha`,`idyears`,`idDoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `boncommand`
--

DROP TABLE IF EXISTS `boncommand`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `boncommand` (
  `idBCmd` varchar(6) NOT NULL,
  `DateComand` datetime DEFAULT NULL,
  `Livrer` bit(1) DEFAULT NULL,
  `Fournisseur` int(11) DEFAULT NULL,
  `Observ` varchar(100) DEFAULT NULL,
  `idDoss` int(11) NOT NULL,
  `idusers` int(11) DEFAULT NULL,
  PRIMARY KEY (`idBCmd`,`idDoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `boncont`
--

DROP TABLE IF EXISTS `boncont`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `boncont` (
  `idbonCont` varchar(20) NOT NULL,
  `idDoss` int(11) NOT NULL,
  `idyears` int(11) NOT NULL,
  `idusers` int(11) DEFAULT NULL,
  `dat` datetime DEFAULT NULL,
  `MRemise` decimal(18,2) DEFAULT NULL,
  `Mpayer` decimal(18,2) DEFAULT NULL,
  `MRends` decimal(18,2) DEFAULT NULL,
  `idCCC` varchar(45) DEFAULT NULL,
  `NomCli` varchar(100) DEFAULT NULL,
  `Adrese` varchar(120) DEFAULT NULL,
  `NCarfelah` varchar(45) DEFAULT NULL,
  `DatCarfelah` datetime DEFAULT NULL,
  `Tel` varchar(45) DEFAULT NULL,
  `DestAdrese` varchar(120) DEFAULT NULL,
  `Transporter` varchar(55) DEFAULT NULL,
  `IMM` varchar(45) DEFAULT NULL,
  `deleted` bit(1) DEFAULT b'0',
  `idCompte` int(11) DEFAULT NULL,
  `Total` decimal(18,6) DEFAULT NULL,
  `MachineName` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`idbonCont`,`idDoss`,`idyears`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bonretachat`
--

DROP TABLE IF EXISTS `bonretachat`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bonretachat` (
  `idRetA` varchar(10) NOT NULL,
  `idpers` int(11) DEFAULT NULL,
  `dat` datetime DEFAULT NULL,
  `total` decimal(18,6) DEFAULT NULL,
  `Observ` text,
  `idBonAcha` varchar(20) DEFAULT NULL,
  `iddoss` int(11) NOT NULL,
  `idusers` int(11) DEFAULT NULL,
  `MontantRet` decimal(18,6) DEFAULT NULL,
  `idCompte` int(11) DEFAULT NULL,
  `ProjectID` int(11) DEFAULT NULL,
  PRIMARY KEY (`idRetA`,`iddoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bonretvent`
--

DROP TABLE IF EXISTS `bonretvent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bonretvent` (
  `idRet` varchar(10) NOT NULL,
  `idpers` int(11) DEFAULT NULL,
  `dat` datetime DEFAULT NULL,
  `total` decimal(18,6) DEFAULT NULL,
  `Observ` varchar(200) DEFAULT NULL,
  `idBonLiv` varchar(45) DEFAULT NULL,
  `iddoss` int(11) NOT NULL,
  `idusers` int(11) DEFAULT NULL,
  `MontantRet` decimal(18,6) DEFAULT NULL,
  `idCompte` int(11) DEFAULT NULL,
  `ProjectID` int(11) DEFAULT NULL,
  PRIMARY KEY (`idRet`,`iddoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bonservice`
--

DROP TABLE IF EXISTS `bonservice`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bonservice` (
  `idBonServ` varchar(10) NOT NULL,
  `iddoss` int(11) NOT NULL,
  `idDepance` int(11) DEFAULT NULL,
  `idFour` int(11) DEFAULT NULL,
  `idModPay` int(11) DEFAULT NULL,
  `idusers` int(11) DEFAULT NULL,
  `idyears` int(11) NOT NULL,
  `dat` datetime DEFAULT NULL,
  `Total` double DEFAULT NULL,
  `Observ` longtext,
  `Paiement` double DEFAULT NULL,
  PRIMARY KEY (`idBonServ`,`iddoss`,`idyears`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bonsliv`
--

DROP TABLE IF EXISTS `bonsliv`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bonsliv` (
  `idBonLiv` varchar(20) NOT NULL,
  `DateBL` datetime DEFAULT NULL,
  `Total` decimal(18,6) DEFAULT NULL,
  `TypeVers` bit(1) DEFAULT NULL,
  `Client` int(11) DEFAULT NULL,
  `IDFact` varchar(20) DEFAULT NULL,
  `Observ` varchar(100) DEFAULT NULL,
  `idDoss` int(11) NOT NULL,
  `idusers` int(11) DEFAULT NULL,
  `idyears` int(11) NOT NULL,
  `nomCstmer` varchar(45) DEFAULT NULL,
  `telCstmer` varchar(45) DEFAULT NULL,
  `adreseCstmer` varchar(45) DEFAULT NULL,
  `RC` varchar(45) DEFAULT NULL,
  `MF` varchar(45) DEFAULT NULL,
  `ARTI` varchar(45) DEFAULT NULL,
  `NIS` varchar(45) DEFAULT NULL,
  `modepai` varchar(45) DEFAULT NULL,
  `MontRegl` decimal(18,6) DEFAULT NULL,
  `MRemise` decimal(18,6) DEFAULT NULL COMMENT 'MRemise will be used olso in taksit selling for supporting to Total. positive number with minus.',
  `idTrans` int(11) DEFAULT NULL,
  `idComm` int(11) DEFAULT NULL,
  `Nserie` int(11) DEFAULT NULL,
  `tva` decimal(18,2) DEFAULT NULL,
  `Ncomd` varchar(14) DEFAULT NULL,
  `codBar` decimal(13,0) DEFAULT NULL,
  `idCompte` int(11) DEFAULT NULL,
  `MargePlus` decimal(10,0) NOT NULL DEFAULT '0',
  `isTAKSIT` bit(1) NOT NULL DEFAULT b'0',
  `MontantInitial` decimal(18,6) DEFAULT '0.000000',
  `Archive` bit(1) DEFAULT NULL,
  `Payed` bit(1) DEFAULT NULL,
  `idChild` varchar(20) DEFAULT NULL,
  `Cancelled` bit(1) DEFAULT NULL,
  `ProjectID` int(11) DEFAULT NULL,
  `NumCheq` varchar(145) DEFAULT NULL,
  `idRC` int(11) DEFAULT NULL,
  `idModPay` int(11) DEFAULT NULL,
  PRIMARY KEY (`idBonLiv`,`idDoss`,`idyears`),
  UNIQUE KEY `codBar_UNIQUE` (`codBar`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bontransfer`
--

DROP TABLE IF EXISTS `bontransfer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bontransfer` (
  `idBonT` int(11) NOT NULL AUTO_INCREMENT,
  `DateBon` date DEFAULT NULL,
  `StockDep` int(11) DEFAULT NULL,
  `StockBut` int(11) DEFAULT NULL,
  `Observ` varchar(100) DEFAULT NULL,
  `idDoss` int(11) NOT NULL,
  `idusers` int(11) DEFAULT NULL,
  `idyears` int(11) NOT NULL,
  PRIMARY KEY (`idBonT`,`idDoss`,`idyears`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
-- Table structure for table `ccc`
--

DROP TABLE IF EXISTS `ccc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ccc` (
  `idCCC` varchar(45) NOT NULL,
  `CCCmontant` decimal(18,2) DEFAULT NULL,
  `CCCpoints` int(11) DEFAULT NULL,
  `idDoss` int(11) NOT NULL,
  `cccNom` varchar(65) DEFAULT NULL,
  `ccNumber` int(11) DEFAULT NULL,
  PRIMARY KEY (`idCCC`,`idDoss`),
  UNIQUE KEY `cccNom_UNIQUE` (`cccNom`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cccdetail`
--

DROP TABLE IF EXISTS `cccdetail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cccdetail` (
  `idcccd` int(11) NOT NULL AUTO_INCREMENT,
  `idccc` varchar(45) DEFAULT NULL,
  `prize` decimal(10,2) DEFAULT NULL,
  `Observ` varchar(145) DEFAULT NULL,
  `idDoss` int(11) DEFAULT NULL,
  `payed` bit(1) DEFAULT b'0',
  `idCategori` int(11) DEFAULT NULL,
  `cccMontant` decimal(18,2) DEFAULT NULL,
  `idDiscountGame` int(11) DEFAULT NULL,
  PRIMARY KEY (`idcccd`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cccgame`
--

DROP TABLE IF EXISTS `cccgame`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cccgame` (
  `idGame` int(11) NOT NULL AUTO_INCREMENT,
  `idDoss` int(11) NOT NULL,
  `Rules` varchar(200) DEFAULT NULL,
  `PrizeCost` decimal(18,0) DEFAULT NULL,
  `Activated` bit(1) DEFAULT b'0',
  `deleted` bit(1) DEFAULT b'0',
  `datExp` date DEFAULT NULL,
  PRIMARY KEY (`idGame`,`idDoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cccgtrace`
--

DROP TABLE IF EXISTS `cccgtrace`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cccgtrace` (
  `idTrace` int(11) NOT NULL AUTO_INCREMENT,
  `idGame` int(11) DEFAULT NULL,
  `idCat` int(11) DEFAULT NULL,
  `idCCC` varchar(45) DEFAULT NULL,
  `CurValue` int(11) DEFAULT NULL,
  `idDoss` int(11) DEFAULT NULL,
  `idusers` int(11) DEFAULT NULL,
  `active` bit(1) DEFAULT b'1',
  PRIMARY KEY (`idTrace`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `chequepaiement`
--

DROP TABLE IF EXISTS `chequepaiement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `chequepaiement` (
  `NumCheq` varchar(100) NOT NULL,
  `dat` datetime DEFAULT NULL,
  `datValid` datetime DEFAULT NULL,
  `idPay` varchar(8) DEFAULT NULL COMMENT 'payement table',
  `iddoss` int(11) DEFAULT NULL,
  `idyears` int(11) DEFAULT NULL,
  PRIMARY KEY (`NumCheq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `classification`
--

DROP TABLE IF EXISTS `classification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `classification` (
  `idClass` int(11) NOT NULL AUTO_INCREMENT,
  `Nom` varchar(45) DEFAULT NULL,
  `Observ` varchar(205) DEFAULT NULL,
  PRIMARY KEY (`idClass`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `codbar`
--

DROP TABLE IF EXISTS `codbar`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `codbar` (
  `idcodBar` varchar(20) NOT NULL,
  `RefArt` varchar(45) DEFAULT NULL,
  `idDoss` int(11) NOT NULL,
  `Observ` varchar(254) DEFAULT NULL,
  `groupage` double DEFAULT NULL,
  PRIMARY KEY (`idcodBar`,`idDoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `commbon`
--

DROP TABLE IF EXISTS `commbon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `commbon` (
  `idCB` varchar(20) NOT NULL,
  `idDoss` int(11) NOT NULL,
  `idComm` int(11) DEFAULT NULL,
  `DateCB` datetime DEFAULT NULL,
  `TotalCB` decimal(18,6) DEFAULT NULL,
  `MontRegl` decimal(18,6) DEFAULT NULL,
  `MRemise` decimal(18,6) DEFAULT NULL,
  `IDFact` varchar(20) DEFAULT NULL,
  `Observ` varchar(100) DEFAULT NULL,
  `idusers` int(11) DEFAULT NULL,
  `modepai` varchar(45) DEFAULT NULL,
  `idTrans` int(11) DEFAULT NULL,
  PRIMARY KEY (`idCB`,`idDoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `commdetail`
--

DROP TABLE IF EXISTS `commdetail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `commdetail` (
  `idCD` int(11) NOT NULL AUTO_INCREMENT,
  `idCB` varchar(20) DEFAULT NULL,
  `DatCD` datetime DEFAULT NULL,
  `refArt` varchar(45) DEFAULT NULL,
  `nomArt` varchar(145) DEFAULT NULL,
  `Qte` decimal(18,6) DEFAULT NULL,
  `Prix` decimal(18,6) DEFAULT NULL,
  `remise` decimal(18,6) DEFAULT NULL,
  `tva` decimal(18,6) DEFAULT NULL,
  `iddoss` int(11) NOT NULL DEFAULT '0',
  `idusers` int(11) DEFAULT NULL,
  PRIMARY KEY (`idCD`,`iddoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `commercial`
--

DROP TABLE IF EXISTS `commercial`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `commercial` (
  `idComm` int(11) NOT NULL AUTO_INCREMENT,
  `NomComm` varchar(55) DEFAULT NULL,
  `adrese` varchar(165) DEFAULT NULL,
  `Tel` varchar(30) DEFAULT NULL,
  `Mobile` varchar(30) DEFAULT NULL,
  `idDoss` int(11) NOT NULL,
  `idusers` int(11) DEFAULT NULL,
  `blocker` bit(1) DEFAULT NULL,
  `solde` decimal(18,6) DEFAULT NULL,
  `CreditInitial` decimal(18,6) DEFAULT NULL,
  PRIMARY KEY (`idComm`,`idDoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `comptes`
--

DROP TABLE IF EXISTS `comptes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `comptes` (
  `idCompte` int(11) NOT NULL AUTO_INCREMENT,
  `NomCompte` varchar(80) DEFAULT NULL,
  `Montant` decimal(18,6) DEFAULT NULL,
  `Observ` varchar(145) DEFAULT NULL,
  `idDoss` int(11) NOT NULL,
  `TypComp` int(11) DEFAULT NULL,
  `Annuler` bit(1) DEFAULT NULL,
  `MontantInitial` decimal(18,6) DEFAULT '0.000000',
  PRIMARY KEY (`idCompte`,`idDoss`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `consom`
--

DROP TABLE IF EXISTS `consom`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `consom` (
  `idConsom` char(25) NOT NULL,
  `ConsNom` varchar(45) DEFAULT NULL,
  `IMM` varchar(45) DEFAULT NULL,
  `IdDoss` int(11) NOT NULL,
  PRIMARY KEY (`idConsom`,`IdDoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dailycaisse`
--

DROP TABLE IF EXISTS `dailycaisse`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dailycaisse` (
  `TheDay` date NOT NULL,
  `idDoss` int(11) NOT NULL,
  `idusers` varchar(45) DEFAULT NULL,
  `MontantStart` decimal(18,6) DEFAULT NULL,
  `MontComp` decimal(18,6) DEFAULT NULL,
  `MontDep` decimal(18,6) DEFAULT NULL,
  `MontRegl` decimal(18,6) DEFAULT NULL,
  `MontPaie` decimal(18,6) DEFAULT NULL,
  `MontEntree` decimal(18,6) DEFAULT NULL,
  PRIMARY KEY (`TheDay`,`idDoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `depancetype`
--

DROP TABLE IF EXISTS `depancetype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `depancetype` (
  `idDepance` int(11) NOT NULL AUTO_INCREMENT,
  `iddoss` int(11) NOT NULL,
  `Nom` varchar(145) NOT NULL,
  `Observ` varchar(45) DEFAULT NULL,
  `idParent` int(11) DEFAULT NULL,
  `Color` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`idDepance`,`iddoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `depotbontrans`
--

DROP TABLE IF EXISTS `depotbontrans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `depotbontrans` (
  `idBonT` int(11) NOT NULL AUTO_INCREMENT,
  `DateBon` date DEFAULT NULL,
  `StockDep` int(11) DEFAULT NULL,
  `StockBut` int(11) DEFAULT NULL,
  `Observ` varchar(100) DEFAULT NULL,
  `idDoss` int(11) NOT NULL,
  `idusers` int(11) DEFAULT NULL,
  PRIMARY KEY (`idBonT`,`idDoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `depotproduit`
--

DROP TABLE IF EXISTS `depotproduit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `depotproduit` (
  `RefArt` varchar(50) NOT NULL,
  `idDepot` int(11) NOT NULL,
  `Qte` decimal(18,2) DEFAULT NULL,
  `idDoss` int(11) NOT NULL,
  `idusers` int(11) DEFAULT NULL,
  PRIMARY KEY (`RefArt`,`idDoss`,`idDepot`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `depots`
--

DROP TABLE IF EXISTS `depots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `depots` (
  `idDepot` int(11) NOT NULL AUTO_INCREMENT,
  `NomDepot` varchar(45) DEFAULT NULL,
  `adrese` varchar(100) DEFAULT NULL,
  `idDoss` int(11) NOT NULL,
  `idusers` int(11) DEFAULT NULL,
  PRIMARY KEY (`idDepot`,`idDoss`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `devis`
--

DROP TABLE IF EXISTS `devis`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `devis` (
  `idDevis` varchar(13) NOT NULL,
  `DateDevi` date DEFAULT NULL,
  `Total` decimal(18,2) DEFAULT NULL,
  `Client` int(11) DEFAULT NULL,
  `Observ` varchar(100) DEFAULT NULL,
  `idDoss` int(11) NOT NULL,
  `idusers` int(11) DEFAULT NULL,
  PRIMARY KEY (`idDevis`,`idDoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `discountgame`
--

DROP TABLE IF EXISTS `discountgame`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `discountgame` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(45) NOT NULL,
  `CreatedAt` datetime NOT NULL,
  `UpdatedAt` datetime NOT NULL,
  `DeletedAt` datetime DEFAULT NULL,
  `Status` tinyint(4) NOT NULL,
  `idDoss` int(11) NOT NULL,
  `StartDay` date NOT NULL,
  `EndDay` date NOT NULL,
  `Ceilling` double NOT NULL,
  `Prize` double NOT NULL,
  `Observ` text,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
  `HeaderPath` longtext,
  PRIMARY KEY (`idDoss`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `employer`
--

DROP TABLE IF EXISTS `employer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `employer` (
  `idEmp` int(11) NOT NULL AUTO_INCREMENT,
  `NomEmp` varchar(30) DEFAULT NULL,
  `Salaire` decimal(7,2) DEFAULT NULL,
  `Adrese` varchar(145) DEFAULT NULL,
  `phone` varchar(32) DEFAULT NULL,
  `iddoss` int(11) NOT NULL,
  `TypPay` int(11) DEFAULT NULL,
  `dat` datetime DEFAULT NULL COMMENT 'date for payments begining.',
  `datEmployer` datetime DEFAULT NULL COMMENT 'date for employing begining',
  `autoPay` bit(1) DEFAULT NULL,
  `solde` decimal(18,2) DEFAULT NULL,
  `deleted` bit(1) DEFAULT NULL,
  `CalcUnit` double DEFAULT NULL,
  `CalcUnitValue` double DEFAULT NULL,
  PRIMARY KEY (`idEmp`,`iddoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `employercomp`
--

DROP TABLE IF EXISTS `employercomp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `employercomp` (
  `idEmpComp` int(11) NOT NULL AUTO_INCREMENT,
  `idEmp` int(11) NOT NULL,
  `Salaire` decimal(18,2) NOT NULL DEFAULT '0.00',
  `dat` datetime NOT NULL,
  `CreateAt` datetime NOT NULL,
  `Observ` varchar(145) DEFAULT NULL,
  `iddoss` int(11) NOT NULL,
  `idusers` int(11) NOT NULL,
  `deleted` bit(1) DEFAULT NULL,
  PRIMARY KEY (`idEmpComp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `employerpaytyp`
--

DROP TABLE IF EXISTS `employerpaytyp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `employerpaytyp` (
  `TypPay` int(11) NOT NULL AUTO_INCREMENT,
  `Nom` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`TypPay`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `etatachat`
--

DROP TABLE IF EXISTS `etatachat`;
/*!50001 DROP VIEW IF EXISTS `etatachat`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `etatachat` (
  `DateEntree` tinyint NOT NULL,
  `RefArt` tinyint NOT NULL,
  `qteEnt` tinyint NOT NULL,
  `MoyPrixAchat` tinyint NOT NULL,
  `idDoss` tinyint NOT NULL,
  `idyears` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `etatstock`
--

DROP TABLE IF EXISTS `etatstock`;
/*!50001 DROP VIEW IF EXISTS `etatstock`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `etatstock` (
  `RefArt` tinyint NOT NULL,
  `NomArt` tinyint NOT NULL,
  `RefColis` tinyint NOT NULL,
  `QteColis` tinyint NOT NULL,
  `QTE` tinyint NOT NULL,
  `AlarmQte` tinyint NOT NULL,
  `Marge` tinyint NOT NULL,
  `PrixVD` tinyint NOT NULL,
  `PrixVG` tinyint NOT NULL,
  `PrixColisD` tinyint NOT NULL,
  `PrixColisG` tinyint NOT NULL,
  `idCat` tinyint NOT NULL,
  `idModel` tinyint NOT NULL,
  `photo` tinyint NOT NULL,
  `TVA` tinyint NOT NULL,
  `expired` tinyint NOT NULL,
  `idDoss` tinyint NOT NULL,
  `Annuler` tinyint NOT NULL,
  `PrixInitial` tinyint NOT NULL,
  `PrixAchat` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `etatvente`
--

DROP TABLE IF EXISTS `etatvente`;
/*!50001 DROP VIEW IF EXISTS `etatvente`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `etatvente` (
  `DateSortie` tinyint NOT NULL,
  `RefArt` tinyint NOT NULL,
  `qteSor` tinyint NOT NULL,
  `idDoss` tinyint NOT NULL,
  `idyears` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `factpro`
--

DROP TABLE IF EXISTS `factpro`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `factpro` (
  `idFactPro` varchar(6) NOT NULL,
  `DatePro` date DEFAULT NULL,
  `Total` decimal(18,2) DEFAULT NULL,
  `TVA` int(11) DEFAULT NULL,
  `Client` int(11) DEFAULT NULL,
  `Observ` varchar(100) DEFAULT NULL,
  `idFact` varchar(20) DEFAULT NULL,
  `idDoss` int(11) NOT NULL,
  `idusers` int(11) DEFAULT NULL,
  `idyears` int(11) DEFAULT NULL,
  `ModPay` varchar(45) DEFAULT NULL,
  `idRC` int(11) DEFAULT NULL,
  `idModPay` int(11) DEFAULT NULL,
  PRIMARY KEY (`idFactPro`,`idDoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `factudetail`
--

DROP TABLE IF EXISTS `factudetail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `factudetail` (
  `idfactDet` int(11) NOT NULL AUTO_INCREMENT,
  `idFact` varchar(20) NOT NULL,
  `nomArt` varchar(100) NOT NULL,
  `RefArt` varchar(50) NOT NULL,
  `RefColis` varchar(45) DEFAULT NULL,
  `Qte` decimal(18,6) DEFAULT '0.000000',
  `Prix` decimal(18,6) DEFAULT '0.000000',
  `remise` decimal(18,2) DEFAULT NULL,
  `tva` decimal(18,2) DEFAULT NULL,
  `idusers` int(11) DEFAULT NULL,
  `idDoss` int(11) NOT NULL,
  `idDevis` varchar(13) DEFAULT NULL,
  PRIMARY KEY (`idfactDet`,`idDoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `factures`
--

DROP TABLE IF EXISTS `factures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `factures` (
  `idFact` varchar(20) NOT NULL,
  `DateFact` datetime DEFAULT NULL,
  `Total` decimal(18,2) DEFAULT NULL,
  `TVA` int(11) DEFAULT NULL,
  `Client` int(11) DEFAULT NULL,
  `ModPaiement` varchar(20) DEFAULT NULL,
  `Observ` varchar(255) DEFAULT NULL,
  `idDoss` int(11) NOT NULL,
  `idusers` int(11) DEFAULT NULL,
  `idyears` int(11) NOT NULL,
  `Nserie` int(11) DEFAULT NULL,
  `Ncomd` varchar(255) DEFAULT NULL,
  `nCheque` varchar(255) DEFAULT NULL,
  `idBonLiv` varchar(20) DEFAULT NULL,
  `Contrat` varchar(50) DEFAULT NULL,
  `Periode` varchar(60) DEFAULT NULL,
  `Attache` varchar(45) DEFAULT NULL,
  `rGarantie` decimal(18,2) DEFAULT NULL,
  `idRC` int(11) DEFAULT NULL,
  `idModPay` int(11) DEFAULT NULL,
  `idProject` int(11) DEFAULT NULL,
  PRIMARY KEY (`idFact`,`idyears`,`idDoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `fav`
--

DROP TABLE IF EXISTS `fav`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fav` (
  `idfav` int(11) NOT NULL AUTO_INCREMENT,
  `Nomfav` varchar(45) DEFAULT NULL,
  `img` text,
  `iddoss` int(11) NOT NULL,
  PRIMARY KEY (`idfav`,`iddoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `favliste`
--

DROP TABLE IF EXISTS `favliste`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `favliste` (
  `idfavliste` int(11) NOT NULL AUTO_INCREMENT,
  `prod1` varchar(145) DEFAULT NULL,
  `prod2` varchar(145) DEFAULT NULL,
  `prod3` varchar(145) DEFAULT NULL,
  `prod4` varchar(145) DEFAULT NULL,
  `prod5` varchar(145) DEFAULT NULL,
  `idfav` int(11) DEFAULT NULL,
  `iddoss` int(11) NOT NULL,
  `Color1` varchar(18) DEFAULT NULL,
  `Color2` varchar(18) DEFAULT NULL,
  `Color3` varchar(18) DEFAULT NULL,
  `Color4` varchar(18) DEFAULT NULL,
  `Color5` varchar(18) DEFAULT NULL,
  `qte1` decimal(18,2) DEFAULT NULL,
  `qte2` decimal(18,2) DEFAULT NULL,
  `qte3` decimal(18,2) DEFAULT NULL,
  `qte4` decimal(18,2) DEFAULT NULL,
  `qte5` decimal(18,2) DEFAULT NULL,
  `ref1` varchar(45) DEFAULT NULL,
  `ref2` varchar(45) DEFAULT NULL,
  `ref3` varchar(45) DEFAULT NULL,
  `ref4` varchar(45) DEFAULT NULL,
  `ref5` varchar(45) DEFAULT NULL,
  `prod6` varchar(145) DEFAULT NULL,
  `Color6` varchar(18) DEFAULT NULL,
  `qte6` decimal(18,2) DEFAULT NULL,
  `ref6` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`idfavliste`,`iddoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flexy`
--

DROP TABLE IF EXISTS `flexy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flexy` (
  `idFLEXY` varchar(20) NOT NULL,
  `RefArt` varchar(45) DEFAULT NULL,
  `idDoss` int(11) NOT NULL,
  `RefArt2` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`idFLEXY`,`idDoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iknowwtudid`
--

DROP TABLE IF EXISTS `iknowwtudid`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iknowwtudid` (
  `id` int(11) NOT NULL,
  `iddoss` int(11) DEFAULT NULL,
  `IDSender` varchar(45) DEFAULT NULL,
  `OwnerTable` varchar(45) DEFAULT NULL,
  `idusers` int(11) DEFAULT NULL,
  `Statue` enum('Add','Edit','Delete') DEFAULT NULL,
  `OldValue` longtext,
  `NewValue` longtext,
  `Name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `job`
--

DROP TABLE IF EXISTS `job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job` (
  `idjob` int(11) NOT NULL AUTO_INCREMENT,
  `Nom` varchar(45) NOT NULL,
  `datpaie` date DEFAULT NULL,
  `iddoss` int(11) NOT NULL,
  `Payday` int(11) NOT NULL,
  PRIMARY KEY (`idjob`,`iddoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `journcaisse`
--

DROP TABLE IF EXISTS `journcaisse`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `journcaisse` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `DateJour` datetime DEFAULT NULL,
  `MEntre` decimal(18,2) DEFAULT NULL,
  `MSortie` decimal(18,2) DEFAULT NULL,
  `TypeOps` varchar(12) DEFAULT NULL,
  `Observation` varchar(45) DEFAULT NULL,
  `idDoss` int(11) NOT NULL,
  `idusers` int(11) DEFAULT NULL,
  `idyears` int(11) NOT NULL,
  `idSess` int(11) DEFAULT NULL,
  `idEmp` int(11) DEFAULT NULL,
  `idCompte` int(11) DEFAULT NULL,
  `deleted` bit(1) DEFAULT NULL,
  `idEmp1` int(11) DEFAULT NULL COMMENT 'for gemp',
  `ProjectID` int(11) DEFAULT NULL,
  `idDepance` int(11) DEFAULT NULL,
  `idBonServ` varchar(10) DEFAULT NULL,
  `valid` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`,`idyears`,`idDoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `journentree`
--

DROP TABLE IF EXISTS `journentree`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `journentree` (
  `idEntree` int(11) NOT NULL AUTO_INCREMENT,
  `DateEntree` datetime DEFAULT NULL,
  `RefArt` varchar(50) DEFAULT NULL,
  `QteCmd` decimal(18,4) DEFAULT NULL,
  `QteLiv` decimal(18,4) DEFAULT NULL,
  `PrixUnit` decimal(18,6) DEFAULT NULL,
  `idBCmd` varchar(6) DEFAULT NULL,
  `idBonAcha` varchar(20) DEFAULT NULL,
  `idDoss` int(11) NOT NULL,
  `idusers` int(11) DEFAULT NULL,
  `datExp` date DEFAULT NULL,
  `datAlarm` date DEFAULT NULL,
  `QteReste` decimal(18,4) DEFAULT NULL,
  `idyears` int(11) NOT NULL,
  `tva` decimal(18,2) DEFAULT NULL,
  `design` varchar(145) DEFAULT NULL,
  `remise` decimal(18,6) DEFAULT NULL,
  `Observ` varchar(250) DEFAULT NULL,
  `idStockes` int(11) DEFAULT NULL,
  `idDepot` int(11) DEFAULT NULL,
  `nomArtAR` varchar(145) DEFAULT NULL,
  `isService` tinyint(1) DEFAULT '0',
  `PrixVenteEntree` double DEFAULT NULL,
  PRIMARY KEY (`idEntree`,`idyears`,`idDoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `journretacha`
--

DROP TABLE IF EXISTS `journretacha`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `journretacha` (
  `idj` int(11) NOT NULL AUTO_INCREMENT,
  `idRetA` varchar(10) NOT NULL,
  `RefArt` varchar(45) NOT NULL,
  `NomArt` varchar(145) DEFAULT NULL,
  `Qte` decimal(18,6) NOT NULL,
  `Prix` decimal(18,6) DEFAULT NULL,
  `remise` decimal(18,6) DEFAULT NULL,
  `tva` decimal(18,6) DEFAULT NULL,
  `iddoss` int(11) NOT NULL,
  `idusers` int(11) DEFAULT NULL,
  `idEntree` int(11) NOT NULL,
  `NomArtAR` varchar(145) DEFAULT NULL,
  `iddepot` int(11) DEFAULT NULL,
  PRIMARY KEY (`idj`,`iddoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `journretvente`
--

DROP TABLE IF EXISTS `journretvente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `journretvente` (
  `idj` int(11) NOT NULL AUTO_INCREMENT,
  `idRet` varchar(10) DEFAULT NULL,
  `refArt` varchar(45) DEFAULT NULL,
  `nomArt` varchar(145) DEFAULT NULL,
  `Qte` decimal(18,6) DEFAULT NULL,
  `Prix` decimal(18,6) DEFAULT NULL,
  `remise` decimal(18,6) DEFAULT NULL,
  `tva` decimal(18,6) DEFAULT NULL,
  `iddoss` int(11) NOT NULL,
  `idusers` int(11) DEFAULT NULL,
  `idEntree` int(11) DEFAULT NULL,
  `nomArtAR` varchar(145) DEFAULT NULL,
  `idSortie` int(11) DEFAULT NULL,
  `iddepot` int(11) DEFAULT NULL,
  PRIMARY KEY (`idj`,`iddoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `journsortie`
--

DROP TABLE IF EXISTS `journsortie`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `journsortie` (
  `idSortie` int(11) NOT NULL AUTO_INCREMENT,
  `DateSortie` datetime DEFAULT NULL,
  `RefArt` varchar(50) DEFAULT NULL,
  `RefColis` varchar(45) DEFAULT NULL,
  `Qte` decimal(18,6) DEFAULT NULL,
  `Prix` decimal(18,6) DEFAULT NULL,
  `Client` int(11) DEFAULT NULL,
  `idBL` varchar(20) DEFAULT NULL,
  `idFact` varchar(20) DEFAULT NULL,
  `idFactPro` varchar(6) DEFAULT NULL,
  `idDevi` int(11) DEFAULT NULL,
  `idDoss` int(11) NOT NULL,
  `idusers` int(11) DEFAULT NULL,
  `idyears` int(11) NOT NULL,
  `tva` decimal(18,2) DEFAULT NULL,
  `design` varchar(145) DEFAULT NULL,
  `remise` decimal(18,2) DEFAULT NULL,
  `idbonCont` varchar(20) DEFAULT NULL,
  `PrixF` decimal(18,6) DEFAULT NULL,
  `PrixAchat` decimal(18,6) DEFAULT NULL,
  `idEntree` int(11) DEFAULT NULL,
  `CCC` varchar(45) DEFAULT NULL,
  `wgroop` varchar(145) DEFAULT NULL,
  `qFedalite` bit(1) DEFAULT NULL,
  `ccNumber` int(11) DEFAULT NULL,
  `idConsom` char(25) DEFAULT NULL,
  `Observ` varchar(200) DEFAULT NULL,
  `idTrace` int(11) DEFAULT NULL,
  `idCCC` varchar(45) DEFAULT NULL,
  `idCat` int(11) DEFAULT NULL,
  `deleted` bit(1) DEFAULT b'0',
  `nomArtAR` varchar(145) DEFAULT NULL,
  `idDepot` int(11) DEFAULT NULL,
  `livrer` bit(1) DEFAULT NULL,
  `idcccd` int(11) DEFAULT NULL,
  `didFiFO` tinyint(1) DEFAULT '0',
  `isDiver` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`idSortie`,`idDoss`,`idyears`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `journsortiefifo`
--

DROP TABLE IF EXISTS `journsortiefifo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `journsortiefifo` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `idSortie` int(11) NOT NULL,
  `idEntree` int(11) DEFAULT NULL,
  `idDoss` int(11) NOT NULL,
  `Qte` double NOT NULL,
  `dat` datetime NOT NULL,
  `QteRetour` double DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `journtransfert`
--

DROP TABLE IF EXISTS `journtransfert`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `journtransfert` (
  `idJoun` int(11) NOT NULL AUTO_INCREMENT,
  `IDBonT` int(11) DEFAULT NULL,
  `DateJourn` datetime DEFAULT NULL,
  `RefArt` varchar(50) DEFAULT NULL,
  `Qte` decimal(18,2) DEFAULT NULL,
  `idDoss` int(11) NOT NULL,
  `idusers` int(11) DEFAULT NULL,
  PRIMARY KEY (`idJoun`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `listeachat`
--

DROP TABLE IF EXISTS `listeachat`;
/*!50001 DROP VIEW IF EXISTS `listeachat`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `listeachat` (
  `idBonAcha` tinyint NOT NULL,
  `DateBon` tinyint NOT NULL,
  `Fournisseur` tinyint NOT NULL,
  `raiSocial` tinyint NOT NULL,
  `TotalTTC` tinyint NOT NULL,
  `MontPaye` tinyint NOT NULL,
  `iddoss` tinyint NOT NULL,
  `idyears` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `listebonachat`
--

DROP TABLE IF EXISTS `listebonachat`;
/*!50001 DROP VIEW IF EXISTS `listebonachat`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `listebonachat` (
  `idBonAcha` tinyint NOT NULL,
  `DateBon` tinyint NOT NULL,
  `Fournisseur` tinyint NOT NULL,
  `idPers` tinyint NOT NULL,
  `raiSocial` tinyint NOT NULL,
  `TotalTTC` tinyint NOT NULL,
  `MontPaye` tinyint NOT NULL,
  `iddoss` tinyint NOT NULL,
  `idyears` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `listebonvent`
--

DROP TABLE IF EXISTS `listebonvent`;
/*!50001 DROP VIEW IF EXISTS `listebonvent`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `listebonvent` (
  `idBonLiv` tinyint NOT NULL,
  `DateBL` tinyint NOT NULL,
  `raiSocial` tinyint NOT NULL,
  `idc` tinyint NOT NULL,
  `TotalBon` tinyint NOT NULL,
  `MontRegl` tinyint NOT NULL,
  `idDoss` tinyint NOT NULL,
  `idyears` tinyint NOT NULL,
  `IDFact` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `models`
--

DROP TABLE IF EXISTS `models`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `models` (
  `idModels` int(11) NOT NULL AUTO_INCREMENT,
  `NomModel` varchar(45) DEFAULT NULL,
  `idDoss` int(11) DEFAULT NULL,
  `idusers` int(11) DEFAULT NULL,
  `idCategori` int(11) DEFAULT NULL,
  PRIMARY KEY (`idModels`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `modepayment`
--

DROP TABLE IF EXISTS `modepayment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `modepayment` (
  `idModPay` int(11) NOT NULL,
  `NomMod` varchar(45) DEFAULT NULL,
  `HavePeriodLimit` tinyint(1) DEFAULT NULL,
  `PeriodLimitInDays` int(11) DEFAULT NULL,
  `Observ` varchar(245) DEFAULT NULL,
  `TaxPercent` double DEFAULT NULL,
  `TaxConst` double DEFAULT NULL,
  PRIMARY KEY (`idModPay`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payements`
--

DROP TABLE IF EXISTS `payements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payements` (
  `idPay` varchar(8) NOT NULL COMMENT ' Like = PAI00001',
  `dat` datetime DEFAULT NULL,
  `idpers` int(11) DEFAULT NULL,
  `idDoss` int(11) NOT NULL,
  `idyears` int(11) NOT NULL,
  `idModPay` int(11) DEFAULT NULL,
  `Montant` double DEFAULT NULL,
  `Cancelled` tinyint(1) DEFAULT NULL,
  `datValid` datetime DEFAULT NULL,
  `isValid` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`idPay`,`idyears`,`idDoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `personnez`
--

DROP TABLE IF EXISTS `personnez`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `personnez` (
  `idPers` int(11) NOT NULL AUTO_INCREMENT,
  `raiSocial` varchar(100) NOT NULL,
  `contactName` varchar(100) DEFAULT NULL,
  `tel` varchar(100) DEFAULT NULL,
  `mobile` varchar(100) DEFAULT NULL,
  `eMail` varchar(100) DEFAULT NULL,
  `idType` int(2) DEFAULT NULL,
  `idClass` int(11) DEFAULT NULL,
  `CreditInitial` decimal(18,2) DEFAULT '0.00',
  `DetteInitial` decimal(18,2) DEFAULT '0.00',
  `RC` varchar(100) DEFAULT NULL,
  `MF` varchar(100) DEFAULT NULL,
  `NIS` varchar(100) DEFAULT NULL,
  `ARTI` varchar(100) DEFAULT NULL,
  `idDoss` int(11) NOT NULL,
  `idusers` int(11) DEFAULT NULL,
  `adrese` varchar(100) DEFAULT NULL,
  `blocker` bit(1) DEFAULT b'0',
  `maxCredit` decimal(18,2) DEFAULT '0.00',
  `CartIDENT` varchar(45) DEFAULT NULL,
  `datCartIDENT` date DEFAULT NULL,
  `NAgrement` varchar(45) DEFAULT NULL,
  `solde` decimal(18,6) DEFAULT NULL,
  `soldefx` decimal(18,6) DEFAULT NULL,
  `prixType` varchar(10) DEFAULT 'PRIX1',
  `IDJob` int(11) DEFAULT NULL,
  `CCP` varchar(45) DEFAULT NULL,
  `RentingPrice` decimal(18,6) DEFAULT NULL,
  `CalcUnit` double DEFAULT NULL,
  `Activity` varchar(255) DEFAULT NULL,
  `idWilaya` int(11) DEFAULT NULL,
  PRIMARY KEY (`idPers`,`idDoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `perstype`
--

DROP TABLE IF EXISTS `perstype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `perstype` (
  `idType` int(11) NOT NULL AUTO_INCREMENT,
  `persType` varchar(45) DEFAULT NULL,
  `Observ` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`idType`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pointage`
--

DROP TABLE IF EXISTS `pointage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pointage` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `iddoss` int(11) NOT NULL,
  `Note` double DEFAULT '0',
  `dat` date DEFAULT NULL,
  `Observ` mediumtext,
  `AttachmentPath` longtext,
  `idBonAcha` varchar(20) DEFAULT NULL,
  `idEmp` int(11) DEFAULT NULL,
  `UnitCalc` double DEFAULT NULL,
  `UnitValue` double DEFAULT NULL,
  PRIMARY KEY (`id`,`iddoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `projects`
--

DROP TABLE IF EXISTS `projects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `projects` (
  `ProjectID` int(11) NOT NULL AUTO_INCREMENT,
  `ProjectName` varchar(45) DEFAULT NULL,
  `Observ` varchar(245) DEFAULT NULL,
  `iddoss` int(11) NOT NULL,
  PRIMARY KEY (`ProjectID`,`iddoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `promotion`
--

DROP TABLE IF EXISTS `promotion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `promotion` (
  `idPromotion` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Description` varchar(100) NOT NULL,
  `datde` date NOT NULL,
  `datau` date NOT NULL,
  `Products` longtext,
  `iddoss` int(11) NOT NULL,
  `idyear` int(11) NOT NULL,
  `Active` tinyint(1) DEFAULT NULL,
  `Remise` double DEFAULT NULL,
  `FixOrPercent` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`idPromotion`,`iddoss`,`idyear`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `registrecommerce`
--

DROP TABLE IF EXISTS `registrecommerce`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `registrecommerce` (
  `idRC` int(11) NOT NULL AUTO_INCREMENT,
  `RC` varchar(45) DEFAULT NULL,
  `iddoss` int(11) DEFAULT NULL,
  PRIMARY KEY (`idRC`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `services`
--

DROP TABLE IF EXISTS `services`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `services` (
  `idServices` varchar(8) NOT NULL,
  `Designation` varchar(100) DEFAULT NULL,
  `Montant` decimal(18,2) DEFAULT NULL,
  `Observ` varchar(100) DEFAULT NULL,
  `idDoss` int(11) DEFAULT NULL,
  `idusers` int(11) DEFAULT NULL,
  PRIMARY KEY (`idServices`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `servicesupplier`
--

DROP TABLE IF EXISTS `servicesupplier`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `servicesupplier` (
  `idSS` int(11) NOT NULL AUTO_INCREMENT,
  `Nom` varchar(65) DEFAULT NULL,
  `Address` mediumtext,
  `Tel` varchar(45) DEFAULT NULL,
  `Activity` int(11) DEFAULT NULL,
  `iddoss` int(11) NOT NULL,
  `idyears` int(11) NOT NULL,
  `idusers` int(11) DEFAULT NULL,
  `solde` double DEFAULT NULL,
  PRIMARY KEY (`idSS`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `soliste`
--

DROP TABLE IF EXISTS `soliste`;
/*!50001 DROP VIEW IF EXISTS `soliste`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `soliste` (
  `idPers` tinyint NOT NULL,
  `raiSocial` tinyint NOT NULL,
  `contactName` tinyint NOT NULL,
  `tel` tinyint NOT NULL,
  `mobile` tinyint NOT NULL,
  `eMail` tinyint NOT NULL,
  `idType` tinyint NOT NULL,
  `idClass` tinyint NOT NULL,
  `CreditInitial` tinyint NOT NULL,
  `DetteInitial` tinyint NOT NULL,
  `RC` tinyint NOT NULL,
  `MF` tinyint NOT NULL,
  `NIS` tinyint NOT NULL,
  `ARTI` tinyint NOT NULL,
  `idDoss` tinyint NOT NULL,
  `idusers` tinyint NOT NULL,
  `adrese` tinyint NOT NULL,
  `blocker` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `stockes`
--

DROP TABLE IF EXISTS `stockes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stockes` (
  `idStockes` int(11) NOT NULL AUTO_INCREMENT,
  `StockeName` varchar(45) DEFAULT NULL,
  `adrese` varchar(100) DEFAULT NULL,
  `idDoss` int(11) NOT NULL,
  `idusers` int(11) DEFAULT NULL,
  PRIMARY KEY (`idStockes`,`idDoss`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stockreal`
--

DROP TABLE IF EXISTS `stockreal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stockreal` (
  `RefArt` varchar(50) NOT NULL,
  `idStockes` int(11) DEFAULT NULL,
  `Qte` decimal(18,2) DEFAULT NULL,
  `idDoss` int(11) NOT NULL,
  `idusers` int(11) DEFAULT NULL,
  PRIMARY KEY (`RefArt`,`idDoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `taksitdetail`
--

DROP TABLE IF EXISTS `taksitdetail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `taksitdetail` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idBonLiv` varchar(20) NOT NULL,
  `iddoss` int(11) NOT NULL,
  `Montant` decimal(18,6) NOT NULL,
  `dat` date NOT NULL,
  `NumCheq` varchar(45) DEFAULT NULL,
  `Observ` varchar(145) DEFAULT NULL,
  `payer` bit(1) NOT NULL DEFAULT b'0',
  `datpay` date NOT NULL,
  `ParentID` int(11) DEFAULT NULL,
  `Cancelled` bit(1) DEFAULT NULL,
  `TotalToSplit` decimal(18,6) DEFAULT NULL,
  `SplitLetter` varchar(1) DEFAULT NULL,
  `idCompte` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transporter`
--

DROP TABLE IF EXISTS `transporter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transporter` (
  `idTrans` int(11) NOT NULL AUTO_INCREMENT,
  `idDoss` int(11) DEFAULT NULL,
  `TransNom` varchar(60) DEFAULT NULL,
  `TransTel` varchar(45) DEFAULT NULL,
  `TransIMM` varchar(45) DEFAULT NULL,
  `TransAdrese` varchar(60) DEFAULT NULL,
  `supp` bit(1) DEFAULT NULL,
  PRIMARY KEY (`idTrans`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `trushes`
--

DROP TABLE IF EXISTS `trushes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trushes` (
  `idTrush` int(11) NOT NULL AUTO_INCREMENT,
  `idDoss` int(11) NOT NULL,
  `RefArt` varchar(50) DEFAULT NULL,
  `NomArt` varchar(100) DEFAULT NULL,
  `QteTrush` decimal(18,6) DEFAULT NULL,
  `idEntree` int(11) DEFAULT NULL,
  `Observ` varchar(200) DEFAULT NULL,
  `datTrush` datetime DEFAULT NULL,
  `idDepot` int(11) DEFAULT NULL,
  PRIMARY KEY (`idTrush`,`idDoss`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tsession`
--

DROP TABLE IF EXISTS `tsession`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tsession` (
  `idSess` int(11) NOT NULL,
  `idDoss` int(11) DEFAULT NULL,
  `DateSessS` datetime DEFAULT NULL,
  `DateSessE` datetime DEFAULT NULL,
  `MontStart` decimal(18,6) DEFAULT NULL,
  `idusers` int(11) DEFAULT NULL,
  PRIMARY KEY (`idSess`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `typee`
--

DROP TABLE IF EXISTS `typee`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `typee` (
  `idtypee` int(11) NOT NULL AUTO_INCREMENT,
  `Nomtyp` varchar(45) DEFAULT NULL,
  `iddoss` int(11) DEFAULT NULL,
  `idCat` int(11) DEFAULT NULL,
  `idusers` int(11) DEFAULT NULL,
  `Observ` varchar(145) DEFAULT NULL,
  PRIMARY KEY (`idtypee`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `unitconverter`
--

DROP TABLE IF EXISTS `unitconverter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `unitconverter` (
  `idUnitConverter` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(20) DEFAULT NULL COMMENT 'Exemple: Kg to Tonne',
  `BaseUnit` double DEFAULT '1' COMMENT 'Exemple = 1',
  `BaseResult` double DEFAULT '1' COMMENT 'Exemple: 0.001',
  `DisplayName` varchar(45) DEFAULT NULL COMMENT 'Exemple(For printing) :Tonne',
  `iddoss` int(11) NOT NULL,
  PRIMARY KEY (`idUnitConverter`,`iddoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `unites`
--

DROP TABLE IF EXISTS `unites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `unites` (
  `idunite` varchar(15) NOT NULL,
  `uniteNam` varchar(45) DEFAULT NULL,
  `UniteAR` varchar(15) DEFAULT NULL,
  `idUnitConverter` int(11) DEFAULT NULL,
  PRIMARY KEY (`idunite`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usersdepots`
--

DROP TABLE IF EXISTS `usersdepots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usersdepots` (
  `idusers` int(11) NOT NULL,
  `iddepot` int(11) NOT NULL,
  `iddoss` int(11) NOT NULL,
  PRIMARY KEY (`idusers`,`iddepot`,`iddoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usersdoss`
--

DROP TABLE IF EXISTS `usersdoss`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usersdoss` (
  `idusers` int(11) NOT NULL,
  `iddoss` int(11) NOT NULL,
  `isReadOnly` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`idusers`,`iddoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
  `canArchive` bit(1) DEFAULT NULL,
  `passDeleteComp` varchar(255) DEFAULT NULL,
  `canDepance` tinyint(1) DEFAULT '0',
  `canEditProductName` bit(1) DEFAULT b'0',
  PRIMARY KEY (`idusers`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `ventedetail`
--

DROP TABLE IF EXISTS `ventedetail`;
/*!50001 DROP VIEW IF EXISTS `ventedetail`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `ventedetail` (
  `idPers` tinyint NOT NULL,
  `raiSocial` tinyint NOT NULL,
  `idBonLiv` tinyint NOT NULL,
  `DateBL` tinyint NOT NULL,
  `RefArt` tinyint NOT NULL,
  `NomArt` tinyint NOT NULL,
  `Qte` tinyint NOT NULL,
  `Prix` tinyint NOT NULL,
  `idDoss` tinyint NOT NULL,
  `idyears` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `ventretdetail`
--

DROP TABLE IF EXISTS `ventretdetail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ventretdetail` (
  `idj` int(11) NOT NULL AUTO_INCREMENT,
  `idRet` varchar(10) DEFAULT NULL,
  `refArt` varchar(45) DEFAULT NULL,
  `nomArt` varchar(145) DEFAULT NULL,
  `Qte` decimal(18,6) DEFAULT NULL,
  `Prix` decimal(18,6) DEFAULT NULL,
  `remise` decimal(18,6) DEFAULT NULL,
  `tva` decimal(18,6) DEFAULT NULL,
  `iddoss` int(11) DEFAULT NULL,
  `idusers` int(11) DEFAULT NULL,
  PRIMARY KEY (`idj`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wilaya`
--

DROP TABLE IF EXISTS `wilaya`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wilaya` (
  `idWilaya` int(11) NOT NULL,
  `NomWilaya` varchar(45) DEFAULT NULL,
  `NomWilayaAR` varchar(45) DEFAULT NULL,
  `Observ` varchar(255) DEFAULT NULL,
  `Distance` double DEFAULT NULL,
  `iddoss` int(11) NOT NULL,
  PRIMARY KEY (`idWilaya`,`iddoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `yearz`
--

DROP TABLE IF EXISTS `yearz`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `yearz` (
  `idyears` int(11) NOT NULL,
  `idDoss` int(11) NOT NULL,
  PRIMARY KEY (`idyears`,`idDoss`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping routines for database 'ftecstockdb'
--
/*!50003 DROP FUNCTION IF EXISTS `GetCaisse` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE FUNCTION `GetCaisse`( idos INTEGER, dat1 datetime, dat2 Datetime) RETURNS decimal(18,6)
    DETERMINISTIC
BEGIN 
DECLARE Total DECIMAL(18,6);   

SELECT      Sum( Cast(ME as Decimal(18,6)) - Cast(MS as Decimal(18,6))) INTO Total  FROM            
                                                                                        (
                                        SELECT        bonachats.DateBon, 0 AS ME, bonachats.MontPaye AS MS      FROM            bonachats LEFT OUTER JOIN         personnez ON bonachats.idDoss = personnez.idDoss AND bonachats.Fournisseur = personnez.idPers                          WHERE        (bonachats.idDoss = idos) AND MontPaye <> 0                        												
                                        UNION ALL                       
                                        SELECT        bonsliv.DateBL, bonsliv.MontRegl AS ME, 0 AS MS  FROM            bonsliv LEFT OUTER JOIN                                               personnez personnez_1 ON bonsliv.idDoss = personnez_1.idDoss AND bonsliv.Client = personnez_1.idPers                     WHERE        (bonsliv.idDoss = idos) AND MontRegl <> 0 
                                        UNION ALL            
                                        SELECT        journcaisse.DateJour, journcaisse.MEntre AS ME, journcaisse.MSortie AS MS          FROM            journcaisse INNER JOIN                                         employer ON journcaisse.idDoss = employer.iddoss AND journcaisse.idEmp1 = employer.idEmp               WHERE        (journcaisse.idDoss = idos) AND journcaisse.DELETED = 0 
                                        UNION ALL            
                                        SELECT        DateJour, MEntre AS ME, MSortie AS MS  FROM            journcaisse journcaisse_1           WHERE        (idDoss = idos) AND (idEmp1 IS NULL)  AND MEntre = 0 OR MEntre is null 
                                        UNION ALL            
                                        SELECT       DateJour , MEntre AS ME, MSortie AS MS        FROM            journcaisse journcaisse_1           WHERE        (idDoss = idos) AND (idEmp1 IS NULL) AND MSortie = 0 OR MSortie is null 	        
                                        UNION ALL 			 
                                        	SELECT d1.datebon ,d2.ME-ifnull(d1.MS,0) as ME,0 as MS
                                            FROM (SELECT DATE( boncont.dat)as datebon ,0 as ME, Sum(MRemise) as MS FROM boncont WHERE boncont.iddoss = 1 group by DATE( boncont.dat) ) as d1 INNER JOIN
                                        	(SELECT      DATE( boncont.dat) as datebon, sum(qte*journsortie.Prix*(1-remise/100)*(1+tva/100)) AS ME,0 as MS, idcompte FROM            boncont INNER JOIN
                                        	journsortie ON boncont.idDoss = journsortie.idDoss AND boncont.idbonCont = journsortie.idbonCont WHERE boncont.iddoss = idos  group by DATE( boncont.dat))as d2 ON d1.datebon = d2.datebon 
                                        UNION ALL 
                                        SELECT        bonretvent.dat, 0 AS ME, bonretvent.MontantRet AS MS
                                        FROM            personnez RIGHT OUTER JOIN bonretvent ON personnez.idPers = bonretvent.idpers 
                                        WHERE        (bonretvent.iddoss = idos) AND (bonretvent.MontantRet <> 0) 
                                        UNION ALL 
                                        SELECT        bonretachat.dat, bonretachat.MontantRet AS ME, 0 AS MS
                                        FROM            personnez RIGHT OUTER JOIN bonretachat ON personnez.idPers = bonretachat.idpers 
                                        WHERE        (bonretachat.iddoss = idos) AND (bonretachat.MontantRet <> 0) 
                                        UNION ALL                       
                                        SELECT       CONVERT( taksitdetail.datpay , DATETIME), taksitdetail.Montant AS ME, 0 AS MS
                                        FROM            taksitdetail INNER JOIN
                                                                 bonsliv ON taksitdetail.idBonLiv = bonsliv.idBonLiv AND taksitdetail.iddoss = bonsliv.idDoss INNER JOIN
                                                                 personnez ON bonsliv.Client = personnez.idPers
                                        WHERE        (taksitdetail.payer = 1) AND (taksitdetail.iddoss = idos) 
                                        ) MoneyMovement WHERE  (DateBon >= dat1) AND (DateBon < dat2)   ORDER BY DateBon; 
	Return Total;
	END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `GetInitialMontant` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   FUNCTION `GetInitialMontant`(dos INTEGER,TheToday datetime,idComp integer) RETURNS decimal(18,6)
BEGIN

                                    DECLARE aCaisseIn DECIMAL(18,6);

                                    DECLARE aVersementIn DECIMAL(18,6);

                                    DECLARE aCompIn DECIMAL(18,6);

                                    DECLARE aRetAchatIn DECIMAL(18,6);

                                    

                                    DECLARE bPaiementIn DECIMAL(18,6);

                                    DECLARE bRetVenteIn DECIMAL(18,6);

                                    DECLARE bDepanceIn DECIMAL(18,6);

                                    

                                    DECLARE aCompteInitial DECIMAL(18,6);

                                    IF idComp = 0 then

                                    SELECT SUM(ifnull(MEntre,0)) FROM journcaisse WHERE iddoss = dos AND datejour < TheToday INTO aCaisseIn;

                                    SELECT SUM(ifnull(MontRegl,0)) FROM bonsliv WHERE iddoss = dos AND dateBL < TheToday INTO aVersementIn;

                                    SELECT SUM(ifnull(Total,0)) FROM boncont WHERE iddoss = dos AND dat < TheToday INTO aCompIN;

                                    SELECT SUM(ifnull(MontantRet,0)) FROM bonretachat where iddoss = dos AND dat < TheToday INTO aRetAchatIn;

                                    

                                    SELECT SUM(ifnull(MontPaye,0)) FROM bonachats WHERE iddoss = dos AND dateBon < TheToday INTO bPaiementIn;

                                    SELECT SUM(ifnull(MontantRet,0)) FROM bonRetVent WHERE iddoss = dos AND dat < TheToday INTO bRetVenteIn;

                                    SELECT SUM(ifnull(MSortie,0)) FROM journcaisse WHERE iddoss = dos AND datejour < TheToday INTO bDepanceIn;

                                    SELECT SUM(ifnull(MontantInitial,0)) FROM comptes WHERE iddoss = dos INTO aCompteInitial;

                                    

                                    ELSE 

                                    

                                    SELECT SUM(ifnull(MEntre,0)) FROM journcaisse WHERE idCompte = idComp AND iddoss = dos AND datejour < TheToday INTO aCaisseIn;

                                    SELECT SUM(ifnull(MontRegl,0)) FROM bonsliv WHERE  idCompte = idComp AND iddoss = dos AND dateBL < TheToday INTO aVersementIn;

                                    SELECT SUM(ifnull(Total,0)) FROM boncont WHERE  idCompte = idComp AND iddoss = dos AND dat < TheToday INTO aCompIN;

                                    SELECT SUM(ifnull(MontantRet,0)) FROM bonretachat where  idCompte = idComp AND iddoss = dos AND dat < TheToday INTO aRetAchatIn;

                                    

                                    SELECT SUM(ifnull(MontPaye,0)) FROM bonachats WHERE  idCompte = idComp AND iddoss = dos AND dateBon < TheToday INTO bPaiementIn;

                                    SELECT SUM(ifnull(MontantRet,0)) FROM bonRetVent WHERE  idCompte = idComp AND iddoss = dos AND dat < TheToday INTO bRetVenteIn;

                                    SELECT SUM(ifnull(MSortie,0)) FROM journcaisse WHERE  idCompte = idComp AND iddoss = dos AND datejour < TheToday INTO bDepanceIn;

                                    SELECT SUM(ifnull(MontantInitial,0)) FROM comptes WHERE  idCompte = idComp AND iddoss = dos  INTO aCompteInitial;

                                    

                                    END IF;

                                    RETURN ifnull( aCompteInitial,0)+ifnull( aCaisseIn,0)+ifnull( aVersementIn,0)+ifnull( aCompIn,0)+ifnull( aRetAchatIn,0)-ifnull( bPaiementIn,0)-ifnull( bRetVenteIn,0)-ifnull( bDepanceIn,0);

                                    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `GetMaxAchat` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   FUNCTION `GetMaxAchat`(idos INT,iyear INT ,iuser INT) RETURNS varchar(9) CHARSET utf8
BEGIN DECLARE maMax INT; Select Cast(SUBSTRING(Max(BonAchats.idBonAcha),7) AS UNSIGNED INTEGER) AS MaxIDAchat FROM BonAchats WHERE BonAchats.idBonAcha like 'Achat_%' AND BonAchats.idDoss = idos INTO maMax; RETURN ifnull(maMax,0); END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `GetMaxBL` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   FUNCTION `GetMaxBL`(idos INT,iyear INT) RETURNS int(11)
BEGIN DECLARE maMax INT; Select Cast(SUBSTRING(Max(bonsliv.idbonliv),3) AS UNSIGNED INTEGER) AS MaxIDBL FROM bonsliv WHERE bonsliv.idbonliv like 'BL%' AND bonsliv.idDoss = idos INTO maMax; RETURN ifnull(maMax,0); END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `GetMaxPaim` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   FUNCTION `GetMaxPaim`(idos INT,iyear INT ) RETURNS varchar(9) CHARSET utf8
BEGIN DECLARE maMax INT; Select Cast(SUBSTRING(Max(BonAchats.idBonAcha),5) AS UNSIGNED INTEGER) AS MaxIDAchat FROM BonAchats WHERE BonAchats.idBonAcha like 'PAIE%' AND BonAchats.idDoss = idos INTO maMax; RETURN ifnull(maMax,0); END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `GetMaxRefArt` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   FUNCTION `GetMaxRefArt`(idos INT) RETURNS int(11)
BEGIN
DECLARE maMax INT;
Select Cast(SUBSTRING(Max(articlesliste.RefArt),4) AS UNSIGNED INTEGER) AS MaxIDAchat
FROM articlesliste
WHERE articlesliste.RefArt like 'ART%' AND articlesliste.idDoss = idos INTO maMax;

RETURN ifnull(maMax,0);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `GetMaxREGL` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   FUNCTION `GetMaxREGL`(idos INT,iyear INT) RETURNS int(11)
BEGIN DECLARE maMax INT; Select Cast(SUBSTRING(Max(bonsliv.idbonliv),5) AS UNSIGNED INTEGER) AS MaxIDBL FROM bonsliv WHERE bonsliv.idbonliv like 'REGL%' AND bonsliv.idDoss = idos INTO maMax; RETURN ifnull(maMax,0); END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `GetPAchFromLastVent` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   FUNCTION `GetPAchFromLastVent`(refart nvarchar(30),idos int, datt datetime) RETURNS decimal(18,6)
BEGIN
DECLARE prixA decimal;
DECLARE esid int;

Select ifnull(Max(journsortie.idSortie),0) as sortid
FROM journsortie
WHERE (journsortie.RefArt = refart) AND (journsortie.idDoss = idos) 
				  AND (journsortie.DateSortie < datt) INTO esid;

Select ifnull(journsortie.PrixAchat,0) as OldPrixAchat
FROM journsortie
WHERE (journsortie.idSortie = esid) INTO prixA;

RETURN prixA;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `GetPrixAchat` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   FUNCTION `GetPrixAchat`(refart nvarchar(30),idoss int ) RETURNS decimal(10,0)
BEGIN
DECLARE prixA decimal;

SELECT    if(IFNULL(articlesliste.PrixAchat,0)=0,
				if(IFnull(articlesliste.PrixInitial,0)=0,0,articlesliste.PrixInitial),
					articlesliste.PrixAchat) AS PRIIX
FROM    articlesliste
WHERE    (articlesliste.RefArt = refart)AND (articlesliste.idDoss = idoss) INTO prixA;


RETURN prixA;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `GetQteByDates` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   FUNCTION `GetQteByDates`(dos INTEGER,ProdCode varchar(50), d1 datetime, d2 Datetime) RETURNS decimal(10,4)
    DETERMINISTIC
BEGIN
 DECLARE Total DECIMAL(18,4); -- entrée    
 DECLARE QTEe DECIMAL(18,4); -- entrée      		+
                            DECLARE QTEs DECIMAL(18,4); -- sortie			-
                            DECLARE QTEre DECIMAL(18,4);-- retour entree	-
                            DECLARE QTErs DECIMAL(18,4);-- retour sortie	+
                         
                            DECLARE QTEtx DECIMAL(18,4);-- Trush			-
                            DECLARE rTrue integer;
                            SELECT Sum(QteLiv) FROM journentree WHERE iddoss = dos  AND RefArt = ProdCode AND DateEntree >= d1 AND DateEntree < d2 and idBonAcha is not null  INTO QTEe;
                            SELECT Sum(Qte) FROM journsortie    WHERE iddoss = dos AND RefArt = ProdCode AND DateSortie >= d1 AND DateSortie < d2 INTO QTEs;
                            SELECT Sum(Qte) FROM journretacha inner join `bonretachat` on journretacha.idRetA = `bonretachat`.idRetA and journretacha.iddoss = `bonretachat`.iddoss WHERE `bonretachat`.iddoss = dos  AND RefArt = ProdCode AND dat >= d1 AND dat < d2 INTO QTEre;
                            SELECT Sum(Qte) FROM journretvente inner join `bonretvent` on journretvente.idRet = `bonretvent`.idRet and journretvente.iddoss = `bonretvent`.iddoss WHERE `bonretvent`.iddoss = dos AND RefArt = ProdCode AND dat >= d1 AND dat < d2 INTO QTErs;
                            SELECT SUM(QteTrush) FROM trushes 	WHERE iddoss = dos AND RefArt = ProdCode AND datTrush >= d1 AND datTrush < d2 INTO QTEtx;
                          SET Total =ifnull(QTEe,0)-ifnull(QTEs,0)-ifnull(QTEre,0)+ifnull(QTErs,0)-ifnull(QTEtx,0);
                           Return (Total);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `GetQteIn` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   FUNCTION `GetQteIn`(dos INTEGER,ProdCode varchar(50), d1 datetime, d2 Datetime) RETURNS decimal(10,4)
    DETERMINISTIC
BEGIN 
                            DECLARE Total DECIMAL(18,4); -- entrée    
							DECLARE QTEe DECIMAL(18,4); -- entrée      		+
                            
                            DECLARE QTEre DECIMAL(18,4);-- retour entree	-
                            
                         
                           
                            SELECT Sum(QteLiv) FROM journentree WHERE iddoss = dos  AND RefArt = ProdCode AND DateEntree >= d1 AND DateEntree < d2 and idBonAcha is not null  INTO QTEe;
                            
                            SELECT Sum(Qte) FROM journretacha inner join `bonretachat` on journretacha.idRetA = `bonretachat`.idRetA and journretacha.iddoss = `bonretachat`.iddoss WHERE `bonretachat`.iddoss = dos  AND RefArt = ProdCode AND dat >= d1 AND dat < d2 INTO QTEre;
                            

                            SET Total =ifnull(QTEe,0)-ifnull(QTEre,0);
                            Return (Total);
                            END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `GetQteOut` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   FUNCTION `GetQteOut`(dos INTEGER,ProdCode varchar(50), d1 datetime, d2 Datetime) RETURNS decimal(10,4)
    DETERMINISTIC
BEGIN
							DECLARE Total DECIMAL(18,4); -- entrée    
						
                            DECLARE QTEs DECIMAL(18,4); -- sortie			-
                        
                            DECLARE QTErs DECIMAL(18,4);-- retour sortie	+
                         
                            DECLARE QTEtx DECIMAL(18,4);-- Trush			-
                        
                        
                            SELECT Sum(Qte) FROM journsortie    WHERE iddoss = dos AND RefArt = ProdCode AND DateSortie >= d1 AND DateSortie < d2 INTO QTEs;
                            
                            SELECT Sum(Qte) FROM journretvente inner join `bonretvent` on journretvente.idRet = `bonretvent`.idRet and journretvente.iddoss = `bonretvent`.iddoss WHERE `bonretvent`.iddoss = dos AND RefArt = ProdCode AND dat >= d1 AND dat < d2 INTO QTErs;
                            SELECT SUM(QteTrush) FROM trushes 	WHERE iddoss = dos AND RefArt = ProdCode AND datTrush >= d1 AND datTrush < d2 INTO QTEtx;
                            SET Total =ifnull(QTEs,0)-ifnull(QTErs,0)+ifnull(QTEtx,0);
                            Return (Total);
                            END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `GetQteState` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   FUNCTION `GetQteState`(Art varchar(22),idoss int) RETURNS decimal(10,0)
BEGIN
DECLARE QTEa DECIMAL;
DECLARE QTEb DECIMAL;
DECLARE QTEi DECIMAL;
Select IFNULL(Sum(QteLiv),0) from `journentree` where `journentree`.RefArt = Art AND `journentree`.idDoss = idoss INTO QTEa;
Select IFNULL(Sum(Qte),0) from `journsortie` where `journsortie`.RefArt = Art  AND `journsortie`.idDoss = idoss INTO QTEb;
Select IFNULL(QTE,0) FROM `articlesliste` WHERE `articlesliste`.RefArt = Art  AND `articlesliste`.idDoss = idoss INTO QTEi;
RETURN QTEa+QTEi-QTEb;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `SetDat` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   FUNCTION `SetDat`() RETURNS date
    NO SQL
    DETERMINISTIC
BEGIN
    RETURN @SetDat;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CheckTotalRetour` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   PROCEDURE `CheckTotalRetour`(idsort INTEGER,idos INTEGER)
BEGIN DECLARE idbonRet VARCHAR(20); DECLARE tot DECIMAL; SELECT Max(idRet) FROM journretvente where idsortie  = idsort and iddoss = idos into idbonRet; SELECT sum((prix*qte*(1-remise/100))*(1+tva/100)) from journretvente where idret = idbonRet and iddoss = idos into tot; UPDATE bonretvent set total = tot where idret = idbonRet and iddoss = idos; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `DepotChanged` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   PROCEDURE `DepotChanged`(idBonTr integer,OldDepotTo integer,OldDepotFrom integer,NEWDepotTo integer,NEWDepotFrom integer)
BEGIN

                                    

                                    DECLARE idos integer;

                                    DECLARE iRefArt varchar(50);

                                    DECLARE iQte decimal;

                                    

                                    DECLARE done INT DEFAULT FALSE;  

                                    DECLARE curs1 CURSOR FOR SELECT idDoss,RefArt,Qte FROM `journtransfert` WHERE idBonT = idBonTr;  

                                    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;  

                                    OPEN curs1; 

                                    

                                    read_loop: LOOP FETCH curs1 INTO idos,iRefArt,iQte;  

                                    IF done THEN LEAVE read_loop; 

                                    END IF; 

                                    

                                    if OldDepotFrom <> NEWDepotFrom then 

									CALL UpdateQteInDepot(idos,OldDepotFrom,iRefArt);  
								    CALL UpdateQteInDepot(idos,NEWDepotFrom,iRefArt);   

                                    end if;

                                    

                                    if OldDepotTo <> NEWDepotTo then 

                                    CALL UpdateQteInDepot(idos,OldDepotTo,iRefArt);  
								    CALL UpdateQteInDepot(idos,NEWDepotTo,iRefArt); 

                                    end if;

                                    

                                    END LOOP; 

                                    CLOSE curs1; 

                                    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `EmployerSolde` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   PROCEDURE `EmployerSolde`(EmpID INT, ddos INT)
BEGIN 
DECLARE xSalaire DECIMAL; 
DECLARE xPayment DECIMAL; 
DECLARE xPointage DECIMAL;

SELECT sum(Salaire) FROM employercomp where idemp = EmpID AND iddoss = ddos and deleted = 0 INTO xSalaire; 
SELECT Sum(MSortie) FROM journcaisse  where idemp1 = EmpID AND iddoss = ddos and deleted = 0 INTO xPayment;
SELECT Sum(Note  * UnitValue / UnitCalc) FROM pointage  where idemp = EmpID AND iddoss = ddos INTO xPointage;
 
Update employer SET solde = ifnull(xSalaire,0)+ ifnull(xPointage,0) - ifnull(xPayment,0) where idEmp = EmpID AND iddoss = ddos ; 

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `FIFOMovement` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   PROCEDURE `FIFOMovement`(RefArtt vARCHAR(20),idos INTEGER)
BEGIN SELECT * FROM ( (SELECT DateSortie AS dat, RefArt, design, nomArtAR, 0 AS Qe, Qte AS Qs, - Qte AS Qr, Prix, IFNULL(idFact, IFNULL(idBL, idbonCont)) AS idOpen, Observ FROM            journsortie WHERE refart = RefArtt AND iddoss = idos ) UNION ALL (SELECT        trushes.datTrush AS dat, trushes.RefArt, trushes.NomArt AS design, trushes.NomArt AS NomArtAR, 0 AS Qe, trushes.QteTrush AS Qs, - trushes.QteTrush AS Qr, journentree.PrixUnit AS Prix,Cast(idTrush as char(10)) as idOpen, trushes.Observ FROM            trushes LEFT OUTER JOIN                          journentree ON trushes.idEntree = journentree.idEntree WHERE trushes.RefArt = RefArtt AND trushes.iddoss = idos) UNION ALL (SELECT        bonretvent.dat as dat  , journretvente.refArt, journretvente.nomArt as design , journretvente.nomArtAR, journretvente.Qte AS Qe, 0 AS Qs, journretvente.Qte AS Qr, journretvente.Prix, journretvente.idRet AS idOpen,                          bonretvent.Observ FROM            journretvente INNER JOIN                          bonretvent ON journretvente.idRet = bonretvent.idRet WHERE journretvente.refArt = RefArtt AND journretvente.iddoss = idos)) as ProductMovement ORDER By dat;END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetMovement` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   PROCEDURE `GetMovement`(RefArtt vARCHAR(20),idos INTEGER)
BEGIN
SET @Qt=0;
	
SELECT * ,@Qt:=@Qt+QE-QS as STOCK FROM (
(Select 
    journentree.RefArt,Ninven, Convert(dateentree,DATE) as DE, qteliv as QE,null as DS,0 as QS,'EN' as TY,observ,Convert(dateentree,DATETIME) Dorder
From
    journentree INNEr join articlesliste on articlesliste.refart = journentree.refart 
and articlesliste.iddoss = journentree.iddoss
WHERE journentree.refart = RefArtt  AND journentree.iddoss = idos and qteliv <>0)
UNION ALL
(Select 
    journsortie.RefArt,Ninven, null, 0 ,Convert(datesortie,DATE),journsortie.qte,   'SO' as TY,observ,Convert(datesortie,DATETIME)
From
    journsortie INNEr join articlesliste on articlesliste.refart = journsortie.refart 
and articlesliste.iddoss = journsortie.iddoss
WHERE journsortie.refart = RefArtt AND journsortie.iddoss = idos and journsortie.qte <>0)
UNION ALL
(Select 
    trushes.RefArt,Ninven, null, 0 ,Convert(datTrush,DATE),qtetrush,   'TR' as TY,Observ,Convert(datTrush,DATETIME)
From
    trushes INNEr join articlesliste on articlesliste.refart = trushes.refart 
and articlesliste.iddoss = trushes.iddoss
WHERE trushes.refart = RefArtt AND trushes.iddoss = idos and trushes.qtetrush <>0)

Order by Dorder) as movement ;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `MoneyMovement` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   PROCEDURE `MoneyMovement`(idos INTEGER,dat1 datetime,dat2 datetime )
BEGIN  SELECT       DateBon ,  Cast(ME as Decimal(18,2)) as ME,  Cast(MS as Decimal(18,2)) as MS, TYP, Nom, Observ, idusers, IDF, IDC, idEmp,opnID ,idcompte  FROM            
                                                                                        (
                                        SELECT        bonachats.DateBon, 0 AS ME, bonachats.MontPaye AS MS, 'PAIEMENT POUR FOURNISSEUR' AS TYP, personnez.raiSocial AS Nom, bonachats.Observ, bonachats.idusers, personnez.idPers AS IDF, NULL AS IDC, NULL                                                     AS idEmp, idBonAcha as OpnID ,idcompte                            FROM            bonachats LEFT OUTER JOIN                                                   personnez ON bonachats.idDoss = personnez.idDoss AND bonachats.Fournisseur = personnez.idPers                          WHERE        (bonachats.idDoss = idos) AND MontPaye <> 0                        												
                                        UNION ALL                       
                                        SELECT        bonsliv.DateBL, bonsliv.MontRegl AS ME, 0 AS MS, 'Réglement' AS TYP, personnez_1.raiSocial AS Nom, bonsliv.Observ, bonsliv.idusers, NULL AS IDF, personnez_1.idPers AS IDC, NULL                                               AS idEmp,idBonliv as OpnID, idcompte                     FROM            bonsliv LEFT OUTER JOIN                                               personnez personnez_1 ON bonsliv.idDoss = personnez_1.idDoss AND bonsliv.Client = personnez_1.idPers                     WHERE        (bonsliv.idDoss = idos) AND MontRegl <> 0 
                                        UNION ALL            
                                        SELECT        journcaisse.DateJour, journcaisse.MEntre AS ME, journcaisse.MSortie AS MS, 'EMPLOYER' AS TYP, employer.NomEmp AS Nom, journcaisse.Observation, journcaisse.idusers, NULL AS IDF, NULL                                            AS IDC, employer.idEmp, CAST(id as char(12)) as OpnID,idcompte                   FROM            journcaisse INNER JOIN                                         employer ON journcaisse.idDoss = employer.iddoss AND journcaisse.idEmp1 = employer.idEmp               WHERE        (journcaisse.idDoss = idos) AND journcaisse.DELETED = 0 
                                        UNION ALL            
                                        SELECT        DateJour, MEntre AS ME, MSortie AS MS, 'DEPANCES' AS TYP, ifnull(Observation,'DEPANCES') AS Expr1, Observation, idusers, NULL AS Expr2, NULL AS Expr3, NULL AS Expr4, CAST(id as char(12)) as OpnID, idcompte              FROM            journcaisse journcaisse_1           WHERE        (idDoss = idos) AND (idEmp1 IS NULL)  AND MEntre = 0 OR MEntre is null 
                                        UNION ALL            
                                        SELECT       DateJour , MEntre AS ME, MSortie AS MS, 'AUTRE ENTREE' AS TYP, ifnull(Observation,'Autre Entree') AS Expr1, Observation, idusers, NULL AS Expr2, NULL AS Expr3, NULL AS Expr4, CAST(id as char(12)) as OpnID, idcompte              FROM            journcaisse journcaisse_1           WHERE        (idDoss = idos) AND (idEmp1 IS NULL) AND MSortie = 0 OR MSortie is null 	
                                        
                                        UNION ALL 			 
                                        	SELECT d1.datebon ,d2.ME-d1.MS as ME,null as MS, 'VENTE CASH' as TYP,null as Nom,null as Observ,null as idusers,null as IDF,null as IDC,null as idEmp,null as OpnID, idcompte FROM (SELECT DATE( boncont.dat)as datebon ,null as ME, Sum(MRemise) as MS FROM boncont WHERE boncont.iddoss = 1 group by DATE( boncont.dat) ) as d1 INNER JOIN
                                        	(SELECT      DATE( boncont.dat) as datebon, sum(qte*journsortie.Prix*(1-remise/100)*(1+tva/100)) AS ME,null as MS, idcompte FROM            boncont INNER JOIN
                                        	journsortie ON boncont.idDoss = journsortie.idDoss AND boncont.idbonCont = journsortie.idbonCont WHERE boncont.iddoss = idos  group by DATE( boncont.dat))as d2 ON d1.datebon = d2.datebon 
                                        UNION ALL 
                                        SELECT        bonretvent.dat, 0 AS ME, bonretvent.MontantRet AS MS, 'RETOUR DE VENTE' AS TYP, personnez.raiSocial AS Nom, bonretvent.Observ, bonretvent.idusers,
                                        	NULL AS IDF, bonretvent.idpers, NULL AS idEmp,  bonretvent.idRet AS opnID, bonretvent.idCompte AS idcompte  
                                        FROM            personnez RIGHT OUTER JOIN bonretvent ON personnez.idPers = bonretvent.idpers 
                                        WHERE        (bonretvent.iddoss = idos) AND (bonretvent.MontantRet <> 0) 
                                        UNION ALL 
                                        SELECT        bonretachat.dat, bonretachat.MontantRet AS ME, 0 AS MS, 'RETOUR D''ACHÂT' AS TYP, personnez.raiSocial AS Nom, bonretachat.Observ, bonretachat.idusers,
                                        				NULL AS IDF, bonretachat.idpers, NULL AS idEmp,  bonretachat.idRetA AS opnID, bonretachat.idCompte AS idcompte  
                                        FROM            personnez RIGHT OUTER JOIN bonretachat ON personnez.idPers = bonretachat.idpers 
                                        WHERE        (bonretachat.iddoss = idos) AND (bonretachat.MontantRet <> 0) 
                                        UNION ALL                       
                                        SELECT       CONVERT( taksitdetail.datpay , DATETIME), taksitdetail.Montant AS ME, 0 AS MS, 'FACILITE' AS TYP, personnez.raiSocial AS Nom, bonsliv.Observ, bonsliv.idusers,NULL AS IDF,  personnez.idPers,null AS idEmp, bonsliv.idBonLiv, bonsliv.idCompte
                                        FROM            taksitdetail INNER JOIN
                                                                 bonsliv ON taksitdetail.idBonLiv = bonsliv.idBonLiv AND taksitdetail.iddoss = bonsliv.idDoss INNER JOIN
                                                                 personnez ON bonsliv.Client = personnez.idPers
                                        WHERE        (taksitdetail.payer = 1) AND (taksitdetail.iddoss = idos) 
                                         ) MoneyMovement WHERE  (DateBon >= dat1) AND (DateBon <= dat2)   ORDER BY DateBon; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `personnesDIFF` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   PROCEDURE `personnesDIFF`(idos integer,d1 datetime,d2 datetime)
BEGIN
                                    SELECT raiSocial,mobile, sum(totachat),sum(totvente) FROM(
                                    SELECT        personnez.raiSocial, personnez.mobile, SUM(bonachats.Total - bonachats.MontPaye) AS TotAchat, 0 as TotVente
                                    FROM            personnez LEFT OUTER JOIN
                                                             bonachats ON personnez.idDoss = bonachats.idDoss AND personnez.idPers = bonachats.Fournisseur
                                    WHERE        (DateBon BETWEEN d1 AND d2) AND (personnez.idDoss = idos)
                                    GROUP BY personnez.idPers 
                                    UNION
                                    SELECT        personnez.raiSocial, personnez.mobile,0 as TotAchat, SUM(bonsliv.Total - bonsliv.MontRegl) AS TotVente
                                    FROM            personnez LEFT OUTER JOIN
                                                             bonsliv ON personnez.idDoss = bonsliv.idDoss AND personnez.idPers = bonsliv.Client
                                    WHERE        (DateBL BETWEEN d1 AND d2) AND (personnez.idDoss = idos)
                                    GROUP BY personnez.idPers) as DataTable
                                    GROUP BY raiSocial;
                                    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PoidsParCategorie` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   PROCEDURE `PoidsParCategorie`(dos INTEGER,d1 datetime, d2 Datetime,Mindate Datetime)
BEGIN
SELECT 
                                    idCat,NomCat,
                                   ifnull( SUM(GETQTEBYDATES(articlesliste.iddoss,
                                            RefArt,
                                            Mindate,
                                            d1) * BaseResult / BaseUnit),0)*qteinUnit AS QteInitial,
                                   ifnull( SUM(GETQTEIN(articlesliste.iddoss,
                                            RefArt,
                                            d1,
                                            d2) * BaseResult / BaseUnit),0)*qteinUnit AS QteIn
                                            ,
                                   ifnull( SUM(GETQTEOUT(articlesliste.iddoss,
                                            RefArt,
                                            d1,
                                            d2) * BaseResult / BaseUnit),0)*qteinUnit AS QteOut
                                FROM
                                   articlesliste INNER JOIN categoris ON articlesliste.iddoss = categoris.idDoss AND categoris.idCategori = articlesliste.idCat
                                        INNER JOIN
                                    unitconverter ON articlesliste.idUnitConverter = unitconverter.idUnitConverter
                                    where articlesliste.iddoss=dos
                                GROUP BY idCat , unitconverter.idUnitConverter;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ProductMovement` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   PROCEDURE `ProductMovement`(RefArtt vARCHAR(20),idos INTEGER)
BEGIN SELECT * FROM ( 

                                        (SELECT        DateSortie AS dat, RefArt, design, nomArtAR, null AS Qe, Qte AS Qs, - Qte AS Qr, Prix, IFNULL(idFact, IFNULL(idBL, idbonCont)) AS idOpen, Observ , 'SO' AS typ 

                                        FROM            journsortie WHERE refart = RefArtt AND iddoss = idos ) UNION ALL 

                                        (SELECT        DateEntree AS dat, RefArt, design, nomArtAR, QteLiv AS Qe, null AS Qs, QteLiv AS Qr, (PrixUnit*(1-remise/100)*(1+tva/100)) as Prix, idBonAcha AS idOpen, Observ ,'EN' AS typ 

                                        FROM            journentree WHERE refart = RefArtt AND iddoss = idos AND idBonAcha is not null) UNION ALL 

                                        (SELECT        trushes.datTrush AS dat, trushes.RefArt, trushes.NomArt AS design, trushes.NomArt AS NomArtAR, null AS Qe, trushes.QteTrush AS Qs, - trushes.QteTrush AS Qr, journentree.PrixUnit AS Prix,Cast(idTrush as char(10)) as idOpen, trushes.Observ ,'TR' AS typ 

                                        FROM            trushes INNER JOIN                          journentree ON trushes.idEntree = journentree.idEntree WHERE trushes.RefArt = RefArtt AND trushes.iddoss = idos) UNION ALL 

                                        (SELECT        bonretvent.dat as dat  , journretvente.refArt, journretvente.nomArt as design , journretvente.nomArtAR, journretvente.Qte AS Qe, null AS Qs, journretvente.Qte AS Qr, journretvente.Prix, journretvente.idRet AS idOpen,         bonretvent.Observ ,'RV' AS typ 

                                        FROM            journretvente INNER JOIN bonretvent ON journretvente.idRet = bonretvent.idRet WHERE journretvente.refArt = RefArtt AND journretvente.iddoss = idos)   

                                        UNION ALL 

                                        (SELECT        bonretachat.dat as dat  , journretacha.refArt, journretacha.nomArt as design , journretacha.nomArtAR, null AS Qe, journretacha.Qte AS Qs, journretacha.Qte AS Qr, journretacha.Prix, journretacha.idRetA AS idOpen,         bonretachat.Observ ,'RE' AS typ 

                                        FROM            journretacha INNER JOIN bonretachat ON journretacha.idRetA = bonretachat.idRetA  WHERE journretacha.refArt = RefArtt AND journretacha.iddoss = idos)   

                                        ) 

                                        as ProductMovement ORDER By dat ; 

	                                    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ProductMovementDates` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   PROCEDURE `ProductMovementDates`(RefArtt vARCHAR(20),idos INTEGER, d1 datetime, d2 Datetime )
BEGIN SELECT * FROM ( 
                                        (SELECT        DateSortie AS dat, RefArt, design, nomArtAR, null AS Qe, Qte AS Qs, - Qte AS Qr, Prix, IFNULL(idFact, IFNULL(idBL, idbonCont)) AS idOpen, Observ , 'SO' AS typ 
                                        FROM            journsortie WHERE refart = RefArtt AND iddoss = idos AND DateSortie >= d1 AND DateSortie < d2 ) UNION ALL 
                                        (SELECT        DateEntree AS dat, RefArt, design, nomArtAR, QteLiv AS Qe, null AS Qs, QteLiv AS Qr, PrixUnit as Prix, idBonAcha AS idOpen, Observ ,'EN' AS typ 
                                        FROM            journentree WHERE refart = RefArtt AND iddoss = idos AND idBonAcha is not null  AND DateEntree >= d1 AND DateEntree < d2 ) UNION ALL 
                                        (SELECT        trushes.datTrush AS dat, trushes.RefArt, trushes.NomArt AS design, trushes.NomArt AS NomArtAR, null AS Qe, trushes.QteTrush AS Qs, - trushes.QteTrush AS Qr, journentree.PrixUnit AS Prix,Cast(idTrush as char(10)) as idOpen, trushes.Observ ,'TR' AS typ 
                                        FROM            trushes INNER JOIN                          journentree ON trushes.idEntree = journentree.idEntree 
                                        WHERE trushes.RefArt = RefArtt AND trushes.iddoss = idos  AND trushes.datTrush >= d1 AND trushes.datTrush < d2 ) UNION ALL 
                                        (SELECT        bonretvent.dat as dat  , journretvente.refArt, journretvente.nomArt as design , journretvente.nomArtAR, journretvente.Qte AS Qe, null AS Qs, journretvente.Qte AS Qr, journretvente.Prix, journretvente.idRet AS idOpen,         bonretvent.Observ ,'RV' AS typ 
                                        FROM            journretvente INNER JOIN bonretvent ON journretvente.idRet = bonretvent.idRet WHERE journretvente.refArt = RefArtt AND journretvente.iddoss = idos  AND bonretvent.dat >= d1 AND bonretvent.dat < d2)   
                                        UNION ALL 
                                        (SELECT        bonretachat.dat as dat  , journretacha.refArt, journretacha.nomArt as design , journretacha.nomArtAR, null AS Qe, journretacha.Qte AS Qs, journretacha.Qte AS Qr, journretacha.Prix, journretacha.idRetA AS idOpen,         bonretachat.Observ ,'RE' AS typ 
                                        FROM            journretacha INNER JOIN bonretachat ON journretacha.idRetA = bonretachat.idRetA  WHERE journretacha.refArt = RefArtt AND journretacha.iddoss = idos  AND bonretachat.dat >= d1 AND bonretachat.dat < d2)   
                                        ) 
                                        as ProductMovementDates ORDER By dat ; 
	                                    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SetCCCLastTotal` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   PROCEDURE `SetCCCLastTotal`(ddos INTEGER,cccd INTEGER,CCCID VARCHAR(45))
BEGIN declare cccdTotal decimal;

SELECT Sum(Qte*Prix) FROM journsortie WHERE cccd = idcccd and iddoss = ddos and qFedalite = 0 INTO cccdTotal;

        UPDATE CCC SET CCCmontant  = ifnull(cccdTotal,0) WHERE idCCC = CCCID; 

  UPDATE CCCdetail SET CCCmontant  = ifnull(cccdTotal,0) WHERE idcccd = cccd; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SetSolde` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   PROCEDURE `SetSolde`(idos INTEGER, idc INTEGER)
BEGIN  DECLARE soldex DECIMAL; DECLARE soldexret DECIMAL; DECLARE soldef DECIMAL; DECLARE soldeVAC DECIMAL; 

                            DECLARE soldefret DECIMAL; DECLARE xTyp INTEGER; 

                            SELECT idType FROM `personnez` WHERE (idDoss = idos) AND (idPers = idc) INTO xTyp; 

                            

                            IF xTyp = 1 OR xTyp = 3 then     

                            SELECT SUM(IFNULL(Total, 0) - IFNULL(MontRegl, 0)) AS Expr1 FROM bonsliv WHERE (idDoss = idos) AND (Client = idc) INTO soldex;

                            SELECT SUM(IFNULL(taksitdetail.Montant, 0)) AS Expr1 FROM bonsliv INNER JOIN taksitdetail ON bonsliv.idBonLiv = taksitdetail.idBonLiv WHERE  payer = 1 AND (bonsliv.Client = idc) AND (taksitdetail.iddoss = idos) INTO soldeVAC;

                            SELECT SUM(IFNULL(total, 0) -IFNULL(MontantRet, 0)) AS Expr1    FROM bonretvent WHERE (idDoss = idos) AND (idpers = idc) INTO soldexret; 

                            END IF;  

                            

                            IF xTyp = 2 OR xTyp = 3 then     SELECT SUM(IFNULL(Total, 0) - IFNULL(MontPaye, 0)) AS Expr1  	FROM bonachats WHERE (idDoss = idos) AND (Fournisseur = idc) INTO soldef;

                            SELECT SUM(IFNULL(total, 0) -IFNULL(MontantRet, 0)) AS Expr1    FROM bonretachat WHERE (idDoss = idos) AND (idpers = idc) INTO soldefret;

                             END IF;

                             

                             IF xTyp = 1 THEN UPDATE `personnez` SET `personnez`.solde = ifnull(soldex,0) -ifnull(soldeVAC,0) +     ifnull(`personnez`.CreditInitial,0) - ifnull(soldexret,0)	WHERE `personnez`.idPers = idc AND `personnez`.idDoss = idos;

                             END IF; 

                             

                             IF xTyp = 2 THEN UPDATE `personnez` SET `personnez`.soldefx = ifnull(soldef,0) + 	ifnull(`personnez`.DetteInitial,0) -ifnull(soldefret,0)	WHERE `personnez`.idPers = idc AND `personnez`.idDoss = idos; 

                             END IF;

                             

                             IF xTyp = 3 THEN UPDATE `personnez` SET `personnez`.solde = ifnull(soldex,0) - ifnull(soldeVAC,0) +	ifnull(`personnez`.CreditInitial,0) - ifnull(soldexret,0),`personnez`.soldefx =ifnull(soldef,0)

                             +ifnull(`personnez`.DetteInitial,0) - ifnull(soldefret,0)	WHERE `personnez`.idPers = idc AND `personnez`.idDoss = idos; 

                                    END IF; 

                            END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SetSolde1Comm` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   PROCEDURE `SetSolde1Comm`(idcom INTEGER,idos INTEGER)
BEGIN DECLARE soldex DECIMAL; SELECT SUM(IFNULL(TotalCB, 0) - IFNULL(MontRegl, 0)) AS Expr1   FROM `commbon` WHERE (idDoss = idos) AND (idComm = idcom) INTO soldex; UPDATE `commercial` SET `commercial`.solde = ifnull(soldex,0) WHERE `commercial`.idComm = idcom AND `commercial`.idDoss = idos; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SetSoldeAll` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   PROCEDURE `SetSoldeAll`()
BEGIN  

                                    DECLARE soldex DECIMAL;  

                                    DECLARE soldef DECIMAL;

                                    DECLARE soldexret DECIMAL; 

                                    DECLARE soldefret DECIMAL; 

                                    DECLARE soldeVAC DECIMAL; 

                                    DECLARE idc INTEGER; 

                                    DECLARE idos INTEGER; 

                                    DECLARE xTyp INTEGER;

                                    DECLARE done INT DEFAULT FALSE;  

                                    DECLARE curs1 CURSOR FOR SELECT idPers, idDoss,idType FROM `personnez`;  

                                    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;  

                                    OPEN curs1; 

                                    read_loop: LOOP FETCH curs1 INTO idc,idos,xTyp;  

                                    IF done THEN LEAVE read_loop; 

                                    END IF; 

                                    

                                    IF xTyp = 1 OR xTyp = 3 then     

                                    SELECT SUM(IFNULL(Total, 0) - IFNULL(MontRegl, 0)) AS Expr1 FROM bonsliv WHERE (idDoss = idos) AND (Client = idc) AND (idBonLiv NOT LIKE 'VAC%') INTO soldex;

                                    SELECT SUM(IFNULL(taksitdetail.Montant, 0)) AS Expr1 FROM bonsliv INNER JOIN taksitdetail ON bonsliv.idBonLiv = taksitdetail.idBonLiv WHERE  payer = 0 AND (bonsliv.Client = idc) AND (taksitdetail.iddoss = idos) INTO soldeVAC;

                                    SELECT SUM(IFNULL(total, 0) -IFNULL(MontantRet, 0)) AS Expr1    FROM bonretvent WHERE (idDoss = idos) AND (idpers = idc) INTO soldexret; 

                                    END IF;  

                                    

                                    IF xTyp = 2 OR xTyp = 3 then     SELECT SUM(IFNULL(Total, 0) - IFNULL(MontPaye, 0)) AS Expr1  	FROM bonachats WHERE (idDoss = idos) AND (Fournisseur = idc) INTO soldef;

                                    SELECT SUM(IFNULL(total, 0) -IFNULL(MontantRet, 0)) AS Expr1    FROM bonretachat WHERE (idDoss = idos) AND (idpers = idc) INTO soldefret;

                                     END IF;

                                     

                                     IF xTyp = 1 THEN UPDATE `personnez` SET `personnez`.solde = ifnull(soldex,0) +ifnull(soldeVAC,0) +     ifnull(`personnez`.CreditInitial,0) - ifnull(soldexret,0)	WHERE `personnez`.idPers = idc AND `personnez`.idDoss = idos;

                                     END IF; 

                                     

                                     IF xTyp = 2 THEN UPDATE `personnez` SET `personnez`.soldefx = ifnull(soldef,0) + 	ifnull(`personnez`.DetteInitial,0) -ifnull(soldefret,0)	WHERE `personnez`.idPers = idc AND `personnez`.idDoss = idos; 

                                     END IF;

                                     

                                     IF xTyp = 3 THEN UPDATE `personnez` SET `personnez`.solde = ifnull(soldex,0) + ifnull(soldeVAC,0) +	ifnull(`personnez`.CreditInitial,0) - ifnull(soldexret,0),`personnez`.soldefx =ifnull(soldef,0)

                                     +ifnull(`personnez`.DetteInitial,0) - ifnull(soldefret,0)	WHERE `personnez`.idPers = idc AND `personnez`.idDoss = idos; 

                                    END IF; 

                                     

                                    END LOOP; 

                                    CLOSE curs1; 

                                    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SetSoldeComm` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   PROCEDURE `SetSoldeComm`()
BEGIN DECLARE soldex DECIMAL;  DECLARE soldef DECIMAL;DECLARE idcom INTEGER; DECLARE idos INTEGER; DECLARE done INT DEFAULT FALSE;  DECLARE curs1 CURSOR FOR SELECT idcomm, idDoss FROM `commercial`;  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;OPEN curs1; read_loop: LOOP FETCH curs1 INTO idcom,idos;IF done THEN LEAVE read_loop; END IF;SELECT SUM(IFNULL(TotalCB, 0) - IFNULL(MontRegl, 0)) AS Expr1   FROM `commbon` WHERE (idDoss = idos) AND (idComm = idcom) INTO soldex;UPDATE `commercial` SET `commercial`.solde = ifnull(soldex,0) WHERE `commercial`.idComm = idcom AND `commercial`.idDoss = idos; END LOOP; CLOSE curs1; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SetSoldeServiceProvider` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   PROCEDURE `SetSoldeServiceProvider`(idos INTEGER,idssup INTEGER)
BEGIN DECLARE totalx DECIMAL; 
                            DECLARE idBLx varchar(10) ;
                             DECLARE idoos INTEGER; 
                             DECLARE done INT DEFAULT FALSE;
                             DECLARE curs1 CURSOR FOR SELECT idBonServ, idDoss FROM `bonservice` where idfour = idssup and iddoss = idos; 
                             DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE; 
                             OPEN curs1; read_loop: LOOP FETCH curs1 INTO idBLx,idoos; 
                             IF done THEN LEAVE read_loop; END IF;
SELECT 
    SUM(IFNULL(Msortie, 0)) AS Expr1
FROM
    `journcaisse`
WHERE
    (idDoss = idos) AND (idBonServ = idBLx) INTO totalx;
UPDATE `bonservice` 
SET 
    `bonservice`.Total = totalx
WHERE
    `bonservice`.idBonServ = idBLx
        AND `bonservice`.idDoss = idos; 
                             END LOOP;
                             CLOSE curs1;
                             
SELECT 
    SUM(IFNULL(Total, 0)) - SUM(IFNULL(Paiement, 0))
FROM
    `bonservice`
WHERE
    idFour = idssup AND iddoss = idos INTO totalx;
                             
UPDATE `servicesupplier` 
SET 
    Solde = totalx
WHERE
    idss = idssup AND iddoss = idos;
                                
                             END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SetTotalAchat` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   PROCEDURE `SetTotalAchat`()
BEGIN DECLARE totalx DECIMAL; DECLARE idBLx varchar(20) ; 
                                    DECLARE idos INTEGER; DECLARE done INT DEFAULT FALSE; 
                                    DECLARE curs1 CURSOR FOR SELECT idBonAcha, idDoss FROM `bonachats` Where idbonacha like 'ACHAT%'; 
                                    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE; 
                                    OPEN curs1; read_loop: LOOP FETCH curs1 INTO idBLx,idos; IF done THEN LEAVE read_loop; END IF; 
                                    SELECT        
                                    	SUM(IFNULL(qteliv, 0) * IFNULL(PrixUnit, 0)*(1-ifnull(remise/100,0))*(1+ifnull(tva/100,0))) AS Expr1 FROM        
                                        journentree WHERE        (idDoss = idos) AND (idBonAcha = idBLx) INTO totalx; 
                                    UPDATE `bonachats` SET `bonachats`.Total = totalx WHERE `bonachats`.idBonAcha = idBLx AND `bonachats`.idDoss = idos;
                                    END LOOP; 
                                    CLOSE curs1; 
                                    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SetTotalComptoire` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   PROCEDURE `SetTotalComptoire`()
BEGIN DECLARE idos INTEGER; DECLARE totalx DECIMAL;DECLARE idbon VARCHAR(20); DECLARE done INT DEFAULT FALSE;  DECLARE curs1 CURSOR FOR SELECT idbonCont, idDoss FROM `boncont`;  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;OPEN curs1;read_loop: LOOP FETCH curs1 INTO idbon,idos; IF done THEN LEAVE read_loop;END IF; SELECT SUM(IFNULL(qte, 0) * IFNULL(Prix, 0)*(1-ifnull(remise/100,0))*(1+ifnull(tva/100,0))) AS Expr1 FROM journsortie WHERE (idBL is NULL) AND (idDoss = idos) AND (journsortie.idbonCont = idbon) INTO totalx; UPDATE `boncont` SET `boncont`.Total = totalx-MRemise WHERE `boncont`.idBonCont = idbon AND `boncont`.idDoss = idos; END LOOP; CLOSE curs1; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SetTotals` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   PROCEDURE `SetTotals`()
BEGIN DECLARE totalx DECIMAL; DECLARE idBLx varchar(20) ; DECLARE idos INTEGER; DECLARE done INT DEFAULT FALSE; DECLARE curs1 CURSOR FOR SELECT idBonLiv, idDoss FROM `bonsliv`; 

                                    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE; 

                                    

                                    OPEN curs1; read_loop: LOOP FETCH curs1 INTO idBLx,idos; 

                                    IF done THEN LEAVE read_loop; END IF; 

                                    

                                    SELECT        SUM(IFNULL(qte, 0) * IFNULL(Prix, 0)*(1-ifnull(remise/100,0))*(1+ifnull(tva/100,0))) AS Expr1 FROM journsortie WHERE (idDoss = idos) AND (idBL = idBLx) INTO totalx; 

                                    

                                    UPDATE `bonsliv` SET `bonsliv`.Total = totalx*(1+`bonsliv`.MargePlus/100) - `bonsliv`.MRemise WHERE `bonsliv`.idBonLiv = idBLx AND `bonsliv`.idDoss = idos; END LOOP; CLOSE curs1; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SetTotCompOnly1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   PROCEDURE `SetTotCompOnly1`(idbon VARCHAR(20),idos INTEGER)
BEGIN 
                                    DECLARE totalx DECIMAL;
                                    DECLARE MpayerX DECIMAL;
                                     SELECT SUM(IFNULL(qte, 0) * IFNULL(Prix, 0)*(1-ifnull(remise/100,0))*(1+ifnull(tva/100,0))) AS Expr1
                                     FROM journsortie WHERE (idBL is NULL) AND (idDoss = idos) AND (journsortie.idbonCont = idbon) INTO totalx; 
                                   
                                    UPDATE `boncont` SET `boncont`.Total = totalx-MRemise WHERE `boncont`.idBonCont = idbon AND `boncont`.idDoss = idos; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateQteInDepot` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE   PROCEDURE `UpdateQteInDepot`(dos INTEGER,idDepo integer,ProdCode varchar(50))
BEGIN

                            DECLARE QTEe DECIMAL(18,4); -- entrée      		+

                            DECLARE QTEs DECIMAL(18,4); -- sortie			-

                            DECLARE QTEre DECIMAL(18,4);-- retour entree	-

                            DECLARE QTErs DECIMAL(18,4);-- retour sortie	+

                            DECLARE QTEtr DECIMAL(18,4);-- Transfer			-
                            DECLARE QTEtrIn DECIMAL(18,4);-- Transfer		+

                            DECLARE QTEtx DECIMAL(18,4);-- Trush			-

                            DECLARE rTrue integer;

                            SELECT Sum(QteLiv) FROM journentree WHERE iddoss = dos AND idDepot = idDepo AND RefArt = ProdCode and  idBonAcha is not null INTO QTEe;

                            SELECT Sum(Qte) FROM journsortie    WHERE iddoss = dos AND idDepot = idDepo AND RefArt = ProdCode INTO QTEs;

                            SELECT Sum(Qte) FROM journretacha   WHERE iddoss = dos AND idDepot = idDepo AND RefArt = ProdCode INTO QTEre;

                            SELECT Sum(Qte) FROM journretvente  WHERE iddoss = dos AND idDepot = idDepo AND RefArt = ProdCode INTO QTErs;

                            
                            SELECT SUM(journtransfert.Qte) AS Qte

                            FROM            journtransfert INNER JOIN

                                                     depotbontrans ON journtransfert.IDBonT = depotbontrans.idBonT AND journtransfert.idDoss = depotbontrans.idDoss

                            				WHERE journtransfert.iddoss = dos AND depotbontrans.StockDep = idDepo AND RefArt = ProdCode    INTO   QTEtr;  

                            
                            SELECT SUM(journtransfert.Qte) AS Qte
                            FROM            journtransfert INNER JOIN
                                                     depotbontrans ON journtransfert.IDBonT = depotbontrans.idBonT AND journtransfert.idDoss = depotbontrans.idDoss
                            				WHERE journtransfert.iddoss = dos AND depotbontrans.StockBut = idDepo AND RefArt = ProdCode    INTO   QTEtrIn;  
                            
                            SELECT SUM(QteTrush) FROM trushes 	WHERE iddoss = dos AND idDepot = idDepo AND RefArt = ProdCode INTO QTEtx;

                           
                           UPDATE `depotproduit` SET Qte = ifnull(QTEe,0)-ifnull(QTEs,0)-ifnull(QTEre,0)+ifnull(QTErs,0)+ifnull(QTEtrIn,0)-ifnull(QTEtr,0)-ifnull(QTEtx,0) WHERE iddepot = iddepo AND iddoss = dos and RefArt = ProdCode;

                           END ;;
DELIMITER ;

