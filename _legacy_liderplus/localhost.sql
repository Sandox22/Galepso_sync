-- phpMyAdmin SQL Dump
-- version 4.9.7
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Nov 28, 2022 at 08:00 AM
-- Server version: 5.7.23-23
-- PHP Version: 7.4.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;


CREATE DATABASE IF NOT EXISTS `liderplus` DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
USE `liderplus`;

-- --------------------------------------------------------

--
-- Table structure for table `chat`
--

DROP TABLE IF EXISTS `chat`;
CREATE TABLE `chat` (
  `id` int(10) UNSIGNED NOT NULL,
  `from` varchar(255) CHARACTER SET latin1 NOT NULL DEFAULT '',
  `to` varchar(255) CHARACTER SET latin1 NOT NULL DEFAULT '',
  `message` text,
  `sent` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `recd` int(10) UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `encuesta`
--

DROP TABLE IF EXISTS `encuesta`;
CREATE TABLE `encuesta` (
  `nid_encuesta` int(11) NOT NULL,
  `cpregunta` varchar(100) DEFAULT NULL,
  `lstatus` tinyint(1) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `tciudades`
--

DROP TABLE IF EXISTS `tciudades`;
CREATE TABLE `tciudades` (
  `cid_estado` varchar(2) DEFAULT NULL,
  `cid_ciudad` varchar(2) DEFAULT NULL,
  `cdescripci` varchar(20) DEFAULT NULL,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tclientes`
--

DROP TABLE IF EXISTS `tclientes`;
CREATE TABLE `tclientes` (
  `cid_clien` varchar(5) DEFAULT NULL,
  `cnombre_cl` varchar(100) DEFAULT NULL,
  `cdir_cli1` varchar(60) DEFAULT NULL,
  `cdir_cli2` varchar(60) DEFAULT NULL,
  `cid_ciudac` varchar(2) DEFAULT NULL,
  `cid_estadc` varchar(2) DEFAULT NULL,
  `cnombre_es` varchar(40) DEFAULT NULL,
  `dfecha_nes` datetime DEFAULT NULL,
  `ctele_cli` varchar(25) DEFAULT NULL,
  `ccelu_cli` varchar(25) DEFAULT NULL,
  `cfax_cli` varchar(25) DEFAULT NULL,
  `crif_cli` varchar(12) DEFAULT NULL,
  `cnit_cli` varchar(12) DEFAULT NULL,
  `dfecha_nac` datetime DEFAULT NULL,
  `cid_grucxc` varchar(2) DEFAULT NULL,
  `ndias_blo` smallint(6) DEFAULT NULL,
  `mobservaci` longtext,
  `nlimite_c` decimal(17,2) DEFAULT NULL,
  `nsaldo_a` decimal(17,2) DEFAULT NULL,
  `nmaximo_d` decimal(7,2) DEFAULT NULL,
  `nvencimien` smallint(6) DEFAULT NULL,
  `dfecha_inc` datetime DEFAULT NULL,
  `ce_mail` varchar(60) DEFAULT NULL,
  `cid_vende` varchar(5) DEFAULT NULL,
  `cweb` varchar(50) DEFAULT NULL,
  `cid_zona` varchar(2) DEFAULT NULL,
  `cid_tipocl` varchar(2) DEFAULT NULL,
  `cid_ruta` varchar(2) DEFAULT NULL,
  `cnombre_r` varchar(40) DEFAULT NULL,
  `cdir_r1` varchar(40) DEFAULT NULL,
  `cdir_r2` varchar(40) DEFAULT NULL,
  `cid_ciudar` varchar(2) DEFAULT NULL,
  `cid_estadr` varchar(2) DEFAULT NULL,
  `ctel_habr` varchar(25) DEFAULT NULL,
  `cfax_r` varchar(25) DEFAULT NULL,
  `ccelular_r` varchar(25) DEFAULT NULL,
  `dfecha_nr` date DEFAULT NULL,
  `mempresas` longtext,
  `ccategoria` varchar(3) DEFAULT NULL,
  `cactividad` varchar(20) DEFAULT NULL,
  `mcontactos` longtext,
  `cdir_env1` varchar(60) DEFAULT NULL,
  `cdir_env2` varchar(60) DEFAULT NULL,
  `ctele_env` varchar(25) DEFAULT NULL,
  `ccelu_env` varchar(25) DEFAULT NULL,
  `cfax_env` varchar(25) DEFAULT NULL,
  `cid_ciudae` varchar(2) DEFAULT NULL,
  `cid_estade` varchar(2) DEFAULT NULL,
  `lcontribu` bit(1) DEFAULT NULL,
  `cid_tipo_p` varchar(2) DEFAULT NULL,
  `lcliente_b` bit(1) DEFAULT NULL,
  `lactivo` bit(1) DEFAULT NULL,
  `ndescadic` decimal(7,2) DEFAULT NULL,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL,
  `cdirimag` longtext,
  `cid_tpr_cr` varchar(2) DEFAULT NULL,
  `ctipo` varchar(2) DEFAULT NULL,
  `nporc_ret` decimal(7,2) DEFAULT NULL,
  `nmonto_ret` decimal(17,2) DEFAULT NULL,
  `cid_grunc` varchar(2) DEFAULT NULL,
  `cid_grund` varchar(2) DEFAULT NULL,
  `cid_tiponc` varchar(2) DEFAULT NULL,
  `cid_tipond` varchar(2) DEFAULT NULL,
  `cid_cuennc` varchar(16) DEFAULT NULL,
  `cid_cuennd` varchar(16) DEFAULT NULL,
  `ndias_ret` smallint(6) DEFAULT NULL,
  `cnombre_de` varchar(40) DEFAULT NULL,
  `lcredito` bit(1) DEFAULT NULL,
  `linternet` bit(1) DEFAULT NULL,
  `cusuweb` varchar(20) DEFAULT NULL,
  `ccod_secre` varchar(20) DEFAULT NULL,
  `cpostal` varchar(4) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tcolores`
--

DROP TABLE IF EXISTS `tcolores`;
CREATE TABLE `tcolores` (
  `cid_color` varchar(3) DEFAULT NULL,
  `cdescripci` varchar(40) DEFAULT NULL,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tconfiguracion`
--

DROP TABLE IF EXISTS `tconfiguracion`;
CREATE TABLE `tconfiguracion` (
  `cid_vende` varchar(5) NOT NULL,
  `b` varchar(5) NOT NULL,
  `cid_pedido` int(10) UNSIGNED DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tcontroles`
--

DROP TABLE IF EXISTS `tcontroles`;
CREATE TABLE `tcontroles` (
  `niva` double NOT NULL,
  `cid_vende` varchar(5) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `tcotizaciones`
--

DROP TABLE IF EXISTS `tcotizaciones`;
CREATE TABLE `tcotizaciones` (
  `cid_cotiza` varchar(8) DEFAULT NULL,
  `cid_clien` varchar(5) DEFAULT NULL,
  `cnombre_cl` varchar(100) DEFAULT NULL,
  `npesototal` decimal(14,4) DEFAULT NULL,
  `nmonto_e` decimal(17,2) DEFAULT NULL,
  `nmonto_b` decimal(17,2) DEFAULT NULL,
  `crif_cli` varchar(12) DEFAULT NULL,
  `cid_vende` varchar(5) DEFAULT NULL,
  `dfecha` date DEFAULT NULL,
  `dfecha_ven` date DEFAULT NULL,
  `cid_pedido` varchar(8) DEFAULT NULL,
  `ctipo_pre` varchar(2) DEFAULT NULL,
  `mobservaci` longtext,
  `nmonto_c` decimal(17,2) DEFAULT NULL,
  `ndesc_por` decimal(7,2) DEFAULT NULL,
  `ndesc_bol` decimal(17,2) DEFAULT NULL,
  `nbase_iva` decimal(17,2) DEFAULT NULL,
  `ntasa_iva` decimal(7,2) DEFAULT NULL,
  `nsub_desc` decimal(17,2) DEFAULT NULL,
  `nmontoti` decimal(17,2) DEFAULT NULL,
  `nmontotal` decimal(17,2) DEFAULT NULL,
  `cid_status` varchar(3) DEFAULT NULL,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL,
  `nvolumen` decimal(11,3) DEFAULT NULL,
  `nmontodesc` decimal(17,2) DEFAULT NULL,
  `nmonto_eb` decimal(17,2) DEFAULT NULL,
  `nmontoiva` decimal(17,2) DEFAULT NULL,
  `_nullflags` varchar(1) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tcuentas_banco`
--

DROP TABLE IF EXISTS `tcuentas_banco`;
CREATE TABLE `tcuentas_banco` (
  `cid_cuen_b` varchar(5) DEFAULT NULL,
  `csucursal` varchar(40) DEFAULT NULL,
  `cid_banco` varchar(2) DEFAULT NULL,
  `cnro_cuen` varchar(20) DEFAULT NULL,
  `ldebito_b` bit(1) DEFAULT NULL,
  `ndebito_b` decimal(7,2) DEFAULT NULL,
  `ccuenta_cb` varchar(16) DEFAULT NULL,
  `ccuenta_cd` varchar(16) DEFAULT NULL,
  `cid_tipoc` varchar(2) DEFAULT NULL,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL,
  `nsaldo_act` decimal(17,2) DEFAULT NULL,
  `nsaldo_ini` decimal(17,2) DEFAULT NULL,
  `nsaldo_ic` decimal(17,2) DEFAULT NULL,
  `nsaldo_ac` decimal(17,2) DEFAULT NULL,
  `ccontacto` varchar(40) DEFAULT NULL,
  `nnumch_ini` bigint(20) DEFAULT NULL,
  `nnumch_fin` bigint(20) DEFAULT NULL,
  `lcompegr` bit(1) DEFAULT NULL,
  `ncompegr` int(11) DEFAULT NULL,
  `ncompnd` int(11) DEFAULT NULL,
  `lcompigr` bit(1) DEFAULT NULL,
  `ncompigr` int(11) DEFAULT NULL,
  `ncompnc` int(11) DEFAULT NULL,
  `nfactor` decimal(17,2) DEFAULT NULL,
  `npor_cr` decimal(7,2) DEFAULT NULL,
  `ccuenta_cr` varchar(16) DEFAULT NULL,
  `npor_db` decimal(7,2) DEFAULT NULL,
  `ccuenta_db` varchar(16) DEFAULT NULL,
  `npor_islr` decimal(7,2) DEFAULT NULL,
  `ccuenta_is` varchar(16) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tdetalles_cotizacion`
--

DROP TABLE IF EXISTS `tdetalles_cotizacion`;
CREATE TABLE `tdetalles_cotizacion` (
  `cid_cotiza` varchar(8) DEFAULT NULL,
  `cid_produc` varchar(20) DEFAULT NULL,
  `ncantidad` decimal(19,3) DEFAULT NULL,
  `nprecio` decimal(25,6) DEFAULT NULL,
  `nmonto` decimal(17,2) DEFAULT NULL,
  `nfacturado` decimal(17,2) DEFAULT NULL,
  `ndescuento` decimal(16,6) DEFAULT NULL,
  `mobservaci` longtext,
  `nlinea` int(11) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tdetalles_devolucion_venta`
--

DROP TABLE IF EXISTS `tdetalles_devolucion_venta`;
CREATE TABLE `tdetalles_devolucion_venta` (
  `CID_DEV_V` varchar(8) DEFAULT NULL,
  `CID_PRODUC` varchar(20) DEFAULT NULL,
  `NCANTIDAD` float(16,3) DEFAULT NULL,
  `NPRECIO` float(19,6) DEFAULT NULL,
  `NDEVUELTO` float(15,2) DEFAULT NULL,
  `NMONTO` float(19,6) DEFAULT NULL,
  `NDESCUENTO` float(10,6) DEFAULT NULL,
  `CID_ALMACE` varchar(2) DEFAULT NULL,
  `MOBSERVACI` mediumtext,
  `NCANTKG` float(16,3) DEFAULT NULL,
  `CLOTE` varchar(10) DEFAULT NULL,
  `DFECHA_VEN` date DEFAULT NULL,
  `NLINEA` int(11) DEFAULT NULL,
  `CID_VENDE` varchar(5) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tdetalles_pedido`
--

DROP TABLE IF EXISTS `tdetalles_pedido`;
CREATE TABLE `tdetalles_pedido` (
  `cid_pedido` varchar(8) DEFAULT NULL,
  `cid_produc` varchar(20) DEFAULT NULL,
  `ncantidad` decimal(19,3) DEFAULT NULL,
  `nentregado` decimal(17,2) DEFAULT NULL,
  `mobservaci` longtext,
  `nprecio` decimal(25,6) DEFAULT NULL,
  `nmonto` decimal(17,2) DEFAULT NULL,
  `ndescuento` decimal(8,2) DEFAULT NULL,
  `cid_docum` varchar(2) DEFAULT NULL,
  `cid_prefac` varchar(8) DEFAULT NULL,
  `nlinea` int(11) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tdetalles_recibo_ingreso`
--

DROP TABLE IF EXISTS `tdetalles_recibo_ingreso`;
CREATE TABLE `tdetalles_recibo_ingreso` (
  `CID_CLIEN` char(5) NOT NULL,
  `CID_DOCUM` char(8) DEFAULT NULL,
  `CID_GRUPO` char(2) DEFAULT NULL,
  `CID_TIPO_A` char(2) DEFAULT NULL,
  `CID_TIPO_D` char(2) DEFAULT NULL,
  `CREFERENCI` char(8) DEFAULT NULL,
  `CTIPO` char(1) DEFAULT NULL,
  `DFECHA` date DEFAULT NULL,
  `MOBSERVACI` text,
  `NMONTO_D` decimal(18,2) DEFAULT NULL,
  `NMONTO_H` decimal(18,2) DEFAULT NULL,
  `NSALDO` decimal(18,2) DEFAULT NULL,
  `CDOC_REF` char(8) DEFAULT NULL,
  `NFACTOR` decimal(20,10) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tdetalles_servicios`
--

DROP TABLE IF EXISTS `tdetalles_servicios`;
CREATE TABLE `tdetalles_servicios` (
  `idservicio` varchar(3) DEFAULT NULL,
  `tipousuario` varchar(2) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tdetalles_usuario`
--

DROP TABLE IF EXISTS `tdetalles_usuario`;
CREATE TABLE `tdetalles_usuario` (
  `clogin` varchar(10) NOT NULL,
  `cid_clien` varchar(5) NOT NULL,
  `ccargo` varchar(45) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tdetalles_vendedor_cuenta`
--

DROP TABLE IF EXISTS `tdetalles_vendedor_cuenta`;
CREATE TABLE `tdetalles_vendedor_cuenta` (
  `cid_vende` varchar(5) DEFAULT NULL,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tdevoluciones_venta`
--

DROP TABLE IF EXISTS `tdevoluciones_venta`;
CREATE TABLE `tdevoluciones_venta` (
  `CID_DEV_V` varchar(8) DEFAULT NULL,
  `CID_FACTU` varchar(8) DEFAULT NULL,
  `DFECHA` date DEFAULT NULL,
  `CID_CLIEN` varchar(5) DEFAULT NULL,
  `CNOMBRE_CL` varchar(100) DEFAULT NULL,
  `CRIF_CLI` varchar(12) DEFAULT NULL,
  `CID_VENDE` varchar(5) DEFAULT NULL,
  `NMONTO_E` float(19,6) DEFAULT NULL,
  `NMONTO_B` float(19,6) DEFAULT NULL,
  `NTASA_IVA` float(15,2) DEFAULT NULL,
  `NSUB_TOT` float(19,6) DEFAULT NULL,
  `NMONTO_T` float(19,6) DEFAULT NULL,
  `NMONTO_TI` float(19,6) DEFAULT NULL,
  `CID_STATUS` varchar(3) DEFAULT NULL,
  `MOBSERVACI` mediumtext,
  `CID_USUARI` varchar(8) DEFAULT NULL,
  `DFECHA_ACT` datetime DEFAULT NULL,
  `CID_GRUPO` varchar(2) DEFAULT NULL,
  `NBASE_IVA` float(19,6) DEFAULT NULL,
  `NPORDESC` float(5,2) DEFAULT NULL,
  `NDESCUENTO` float(15,2) DEFAULT NULL,
  `CID_ALMRET` varchar(2) DEFAULT NULL,
  `NDCTOBOLI` float(15,2) DEFAULT NULL,
  `LIMPRESO` bit(1) DEFAULT NULL,
  `CID_TIPO_D` varchar(2) DEFAULT NULL,
  `CNRO_CONTROL` varchar(8) DEFAULT NULL,
  `CSERIE` varchar(2) DEFAULT NULL,
  `CTIPO_DEV` varchar(1) DEFAULT NULL,
  `CID_CLIPRO` varchar(5) DEFAULT NULL,
  `CCOMPROB_F` varchar(12) DEFAULT NULL,
  `CMAQUINA_F` varchar(12) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tdocumentos_cxc`
--

DROP TABLE IF EXISTS `tdocumentos_cxc`;
CREATE TABLE `tdocumentos_cxc` (
  `cid_doccxc` varchar(8) DEFAULT NULL,
  `cid_tipo_d` varchar(2) DEFAULT NULL,
  `cid_clien` varchar(5) DEFAULT NULL,
  `dfecha` date DEFAULT NULL,
  `dfecha_ven` date DEFAULT NULL,
  `nsaldo` decimal(17,2) DEFAULT NULL,
  `cid_grucxc` varchar(2) DEFAULT NULL,
  `nmonto_d` decimal(17,2) DEFAULT NULL,
  `nmonto_h` decimal(17,2) DEFAULT NULL,
  `cid_vende` varchar(5) DEFAULT NULL,
  `cid_ven_a` varchar(5) DEFAULT NULL,
  `dfecha_a` date DEFAULT NULL,
  `nimpuesto` decimal(17,2) DEFAULT NULL,
  `cid_status` varchar(3) DEFAULT NULL,
  `lcobro` bit(1) DEFAULT NULL,
  `mobservaci` longtext,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL,
  `nbase` decimal(17,2) DEFAULT NULL,
  `ntasa_iva` decimal(7,2) DEFAULT NULL,
  `nfactor` decimal(21,6) DEFAULT NULL,
  `cnrofiscal` varchar(8) DEFAULT NULL,
  `cserie` varchar(2) DEFAULT NULL,
  `limpreso` bit(1) DEFAULT NULL,
  `dfecha_nue` date DEFAULT NULL,
  `dfecha_vie` date DEFAULT NULL,
  `cid_factug` varchar(8) DEFAULT NULL,
  `ccomprob_f` varchar(12) DEFAULT NULL,
  `cmaquina_f` varchar(12) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `testados`
--

DROP TABLE IF EXISTS `testados`;
CREATE TABLE `testados` (
  `cid_estado` varchar(2) DEFAULT NULL,
  `cdescripci` varchar(20) DEFAULT NULL,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `thistorial_gps`
--

DROP TABLE IF EXISTS `thistorial_gps`;
CREATE TABLE `thistorial_gps` (
  `cserial` varchar(50) DEFAULT NULL,
  `nlongitud` double DEFAULT NULL,
  `nlatitud` double DEFAULT NULL,
  `nprecision` double DEFAULT NULL,
  `nhora_gps` double DEFAULT NULL,
  `cproveedor` char(50) DEFAULT NULL,
  `lenviado` tinyint(1) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tlineas`
--

DROP TABLE IF EXISTS `tlineas`;
CREATE TABLE `tlineas` (
  `cid_linea` varchar(3) DEFAULT NULL,
  `cdescripci` varchar(40) DEFAULT NULL,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tnoticias`
--

DROP TABLE IF EXISTS `tnoticias`;
CREATE TABLE `tnoticias` (
  `id_noticia` varchar(5) NOT NULL,
  `titulo_noticia` tinytext,
  `contenido_noticia` text,
  `fecha` date NOT NULL,
  `status` varchar(1) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `topciones_encuesta`
--

DROP TABLE IF EXISTS `topciones_encuesta`;
CREATE TABLE `topciones_encuesta` (
  `nid_opcion` int(5) NOT NULL,
  `nid_encuesta` int(5) NOT NULL,
  `cdescripcion` varchar(100) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tpedidos`
--

DROP TABLE IF EXISTS `tpedidos`;
CREATE TABLE `tpedidos` (
  `cid_pedido` int(10) UNSIGNED NOT NULL,
  `cid_clien` char(5) DEFAULT NULL,
  `dfecha` datetime DEFAULT NULL,
  `cid_status` char(3) DEFAULT NULL,
  `mobservaci` mediumtext,
  `npesototal` double DEFAULT NULL,
  `cnombre_cl` char(100) DEFAULT NULL,
  `crif_cli` char(12) DEFAULT NULL,
  `cid_priori` char(1) DEFAULT NULL,
  `cid_usuari` char(8) DEFAULT NULL,
  `cid_vende` char(5) DEFAULT NULL,
  `creferenci` char(5) DEFAULT NULL,
  `nvolumen` int(11) DEFAULT NULL,
  `ctipo_pre` char(0) DEFAULT NULL,
  `nmonto_t` double DEFAULT NULL,
  `dfecha_e` date DEFAULT NULL,
  `corden_com` char(0) DEFAULT NULL,
  `cid_almace` char(20) DEFAULT NULL,
  `cid_transp` char(2) DEFAULT NULL,
  `cconductor` char(2) DEFAULT NULL,
  `ctelefono` char(30) DEFAULT NULL,
  `ccedula` char(30) DEFAULT NULL,
  `ccamion` char(15) DEFAULT NULL,
  `cplaca` char(20) DEFAULT NULL,
  `nmontoti` double DEFAULT NULL,
  `ntasa_iva` double DEFAULT NULL,
  `nbase_iva` double DEFAULT NULL,
  `nmonto_f` double DEFAULT NULL,
  `nmonto_b` double DEFAULT NULL,
  `nmonto_e` double DEFAULT NULL,
  `nmonto_eb` double DEFAULT NULL,
  `nmontoiva` double DEFAULT NULL,
  `nlatitud` double DEFAULT NULL,
  `nlongitud` double DEFAULT NULL,
  `nprecision` float DEFAULT NULL,
  `nhora_gps` double DEFAULT NULL,
  `cproveedor` varchar(50) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tproductos`
--

DROP TABLE IF EXISTS `tproductos`;
CREATE TABLE `tproductos` (
  `cid_produc` varchar(20) DEFAULT NULL,
  `cdescripci` varchar(40) DEFAULT NULL,
  `cdescrialt` varchar(40) DEFAULT NULL,
  `cempaque` varchar(8) DEFAULT NULL,
  `creferenci` varchar(40) DEFAULT NULL,
  `npeso` decimal(14,4) DEFAULT NULL,
  `cunidad_m` varchar(3) DEFAULT NULL,
  `nmedida_l` decimal(11,3) DEFAULT NULL,
  `nmedida_m` decimal(11,3) DEFAULT NULL,
  `nmedida_p` decimal(11,3) DEFAULT NULL,
  `dfecha_inc` date DEFAULT NULL,
  `cclasi1` varchar(3) DEFAULT NULL,
  `cclasi2` varchar(3) DEFAULT NULL,
  `cclasi3` varchar(3) DEFAULT NULL,
  `cclasi4` varchar(3) DEFAULT NULL,
  `nmaximo` decimal(19,3) DEFAULT NULL,
  `nminimo` decimal(19,3) DEFAULT NULL,
  `lapli_iva` bit(1) DEFAULT NULL,
  `nporc_iva` decimal(7,2) DEFAULT NULL,
  `gfoto` varchar(40) DEFAULT NULL,
  `lservicio` bit(1) DEFAULT NULL,
  `ngarantia` smallint(6) DEFAULT NULL,
  `mobservaci` longtext,
  `npuntos_v` int(11) DEFAULT NULL,
  `npuntos_c` int(11) DEFAULT NULL,
  `lserial` bit(1) DEFAULT NULL,
  `nmonto_c` decimal(17,2) DEFAULT NULL,
  `cid_alter` varchar(20) DEFAULT NULL,
  `nexisten` decimal(19,3) DEFAULT NULL,
  `ncompro` decimal(19,3) DEFAULT NULL,
  `napartado` decimal(19,3) DEFAULT NULL,
  `npedido` decimal(19,3) DEFAULT NULL,
  `npordes` decimal(19,3) DEFAULT NULL,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT CURRENT_TIMESTAMP,
  `lactivo` bit(1) DEFAULT NULL,
  `cid_gru_ar` varchar(3) DEFAULT NULL,
  `cid_cuenco` varchar(16) DEFAULT NULL,
  `cid_cuende` varchar(16) DEFAULT NULL,
  `cid_cuenve` varchar(16) DEFAULT NULL,
  `cid_cuenin` varchar(16) DEFAULT NULL,
  `ldual` bit(1) DEFAULT NULL,
  `ldecimales` bit(1) DEFAULT NULL,
  `cid_cuendc` varchar(16) DEFAULT NULL,
  `cid_prodkg` varchar(20) DEFAULT NULL,
  `ndescmax` decimal(8,2) DEFAULT NULL,
  `nmindias` int(11) DEFAULT NULL,
  `nmaxdias` int(11) DEFAULT NULL,
  `lprodvario` bit(1) DEFAULT NULL,
  `ltransito` int(11) DEFAULT NULL,
  `lrecienllegado` int(11) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tproductos_almacen`
--

DROP TABLE IF EXISTS `tproductos_almacen`;
CREATE TABLE `tproductos_almacen` (
  `cid_produc` varchar(20) NOT NULL,
  `cid_almace` varchar(2) NOT NULL,
  `nexisten` varchar(20) NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tproductos_equivalente`
--

DROP TABLE IF EXISTS `tproductos_equivalente`;
CREATE TABLE `tproductos_equivalente` (
  `cid_produc` varchar(20) DEFAULT NULL,
  `cid_equiva` varchar(20) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tproductos_precio`
--

DROP TABLE IF EXISTS `tproductos_precio`;
CREATE TABLE `tproductos_precio` (
  `cid_produc` char(20) DEFAULT NULL,
  `ctipo_pre` char(2) DEFAULT NULL,
  `nprecio` double DEFAULT NULL,
  `ctipo_ref` char(2) DEFAULT NULL,
  `nfactor` double DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `trecibos_ingreso`
--

DROP TABLE IF EXISTS `trecibos_ingreso`;
CREATE TABLE `trecibos_ingreso` (
  `CID_RECI_I` char(8) DEFAULT NULL,
  `DFECHA` date DEFAULT NULL,
  `CID_CLIEN` char(5) DEFAULT NULL,
  `CID_COBRA` char(5) DEFAULT NULL,
  `MOBSERVACI` text,
  `CID_STATUS` char(3) DEFAULT NULL,
  `NMONTO` decimal(18,2) DEFAULT NULL,
  `CID_USUARI` char(8) DEFAULT NULL,
  `DFECHA_ACT` datetime DEFAULT NULL,
  `CID_CAJA` char(2) DEFAULT NULL,
  `CNRO_FIS` char(8) DEFAULT NULL,
  `LIMPRESO` tinyint(4) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tservicios`
--

DROP TABLE IF EXISTS `tservicios`;
CREATE TABLE `tservicios` (
  `idservicio` varchar(3) NOT NULL,
  `id_serv_padre` varchar(5) DEFAULT NULL,
  `descripcion` varchar(40) DEFAULT NULL,
  `url` varchar(100) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tsublineas`
--

DROP TABLE IF EXISTS `tsublineas`;
CREATE TABLE `tsublineas` (
  `cid_sublin` varchar(3) NOT NULL,
  `cdescripci` varchar(40) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `ttallas`
--

DROP TABLE IF EXISTS `ttallas`;
CREATE TABLE `ttallas` (
  `cid_talla` varchar(3) DEFAULT NULL,
  `cdescripci` varchar(40) DEFAULT NULL,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `ttipos_documentocxc`
--

DROP TABLE IF EXISTS `ttipos_documentocxc`;
CREATE TABLE `ttipos_documentocxc` (
  `cid_tipod` varchar(2) DEFAULT NULL,
  `cdescripci` varchar(40) DEFAULT NULL,
  `lsuma` bit(1) DEFAULT NULL,
  `cabreviado` varchar(4) DEFAULT NULL,
  `ndias_ven` smallint(6) DEFAULT NULL,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL,
  `lventa` bit(1) DEFAULT NULL,
  `liva_reten` bit(1) DEFAULT NULL,
  `lnotacr` bit(1) DEFAULT NULL,
  `lfiscal` bit(1) DEFAULT NULL,
  `cid_cuenta` varchar(16) DEFAULT NULL,
  `cid_tipcan` varchar(2) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `ttipos_precio`
--

DROP TABLE IF EXISTS `ttipos_precio`;
CREATE TABLE `ttipos_precio` (
  `cid_tipo_p` varchar(2) DEFAULT NULL,
  `cdescripci` varchar(10) DEFAULT NULL,
  `nfactor` decimal(20,5) DEFAULT NULL,
  `ctipo_ref` varchar(2) DEFAULT NULL,
  `linclu_iva` bit(1) DEFAULT NULL,
  `ndecimal` tinyint(4) DEFAULT NULL,
  `lmuestra` bit(1) DEFAULT NULL,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL,
  `ldecena` bit(1) DEFAULT NULL,
  `lcentena` bit(1) DEFAULT NULL,
  `lunida_mil` bit(1) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `ttipos_usuario`
--

DROP TABLE IF EXISTS `ttipos_usuario`;
CREATE TABLE `ttipos_usuario` (
  `cid_tipousuario` varchar(2) NOT NULL,
  `cdescripci` varchar(20) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `ttipos_vendedor`
--

DROP TABLE IF EXISTS `ttipos_vendedor`;
CREATE TABLE `ttipos_vendedor` (
  `cid_tipove` varchar(2) DEFAULT NULL,
  `cdescripci` varchar(40) DEFAULT NULL,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tusuarios`
--

DROP TABLE IF EXISTS `tusuarios`;
CREATE TABLE `tusuarios` (
  `clogin` varchar(10) NOT NULL,
  `ccontrasena` varchar(10) DEFAULT NULL,
  `crif` varchar(12) DEFAULT NULL,
  `cnombres` varchar(40) DEFAULT NULL,
  `capellidos` varchar(40) DEFAULT NULL,
  `crazonsocial` varchar(100) DEFAULT NULL,
  `cid_tipo_usuario` varchar(2) DEFAULT NULL,
  `cstatus` varchar(1) DEFAULT NULL,
  `cid_vende` varchar(5) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tvendedores`
--

DROP TABLE IF EXISTS `tvendedores`;
CREATE TABLE `tvendedores` (
  `cid_vende` varchar(5) DEFAULT NULL,
  `cnombrev` varchar(40) DEFAULT NULL,
  `cdir_ven1` varchar(40) DEFAULT NULL,
  `cdir_ven2` varchar(40) DEFAULT NULL,
  `ctele_ven` varchar(25) DEFAULT NULL,
  `ccelu_ven` varchar(25) DEFAULT NULL,
  `cfax_ven` varchar(25) DEFAULT NULL,
  `crif_ven` varchar(12) DEFAULT NULL,
  `cnit_ven` varchar(12) DEFAULT NULL,
  `mobservaci` longtext,
  `dfecha_nac` date DEFAULT NULL,
  `dfecha_inc` date DEFAULT NULL,
  `ce_mail` varchar(50) DEFAULT NULL,
  `lactivo` bit(1) DEFAULT NULL,
  `npor_comc` decimal(7,2) DEFAULT NULL,
  `npor_comv` decimal(7,2) DEFAULT NULL,
  `cid_tipove` varchar(2) DEFAULT NULL,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL,
  `ncostomano` decimal(17,2) DEFAULT NULL,
  `ldescuento` bit(1) DEFAULT NULL,
  `ndescmax` decimal(8,2) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tvendedor_actividades`
--

DROP TABLE IF EXISTS `tvendedor_actividades`;
CREATE TABLE `tvendedor_actividades` (
  `cid_vende` varchar(5) DEFAULT NULL,
  `dfecha` date DEFAULT NULL,
  `dfecha_fin` date DEFAULT NULL,
  `cid_status` varchar(1) DEFAULT NULL,
  `cprioridad` varchar(1) DEFAULT NULL,
  `ctitulo` varchar(40) DEFAULT NULL,
  `mactividad` longtext,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL,
  `dfecha_f` date DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tvendedor_precio`
--

DROP TABLE IF EXISTS `tvendedor_precio`;
CREATE TABLE `tvendedor_precio` (
  `cid_vende` varchar(5) DEFAULT NULL,
  `cid_tipo_p` varchar(2) DEFAULT NULL,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL,
  `cnro_doc` varchar(2) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tvisitas_empresa`
--

DROP TABLE IF EXISTS `tvisitas_empresa`;
CREATE TABLE `tvisitas_empresa` (
  `cid_clien` varchar(5) DEFAULT NULL,
  `cid_vende` varchar(5) DEFAULT NULL,
  `dfecha_v` varchar(10) DEFAULT NULL,
  `mobservaci` varchar(200) DEFAULT NULL,
  `cid_status` varchar(1) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tvotos`
--

DROP TABLE IF EXISTS `tvotos`;
CREATE TABLE `tvotos` (
  `nid_encuesta` int(5) NOT NULL,
  `nid_opcion` int(5) NOT NULL,
  `cip` varchar(15) DEFAULT NULL,
  `dfecha_voto` varchar(10) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `chat`
--
ALTER TABLE `chat`
  ADD PRIMARY KEY (`id`),
  ADD KEY `to` (`to`),
  ADD KEY `from` (`from`);

--
-- Indexes for table `encuesta`
--
ALTER TABLE `encuesta`
  ADD PRIMARY KEY (`nid_encuesta`);

--
-- Indexes for table `tcontroles`
--
ALTER TABLE `tcontroles`
  ADD PRIMARY KEY (`niva`);

--
-- Indexes for table `tdetalles_usuario`
--
ALTER TABLE `tdetalles_usuario`
  ADD PRIMARY KEY (`clogin`,`cid_clien`);

--
-- Indexes for table `tnoticias`
--
ALTER TABLE `tnoticias`
  ADD PRIMARY KEY (`id_noticia`);

--
-- Indexes for table `topciones_encuesta`
--
ALTER TABLE `topciones_encuesta`
  ADD PRIMARY KEY (`nid_opcion`);

--
-- Indexes for table `tpedidos`
--
ALTER TABLE `tpedidos`
  ADD PRIMARY KEY (`cid_pedido`);

--
-- Indexes for table `tproductos`
--
ALTER TABLE `tproductos`
  ADD KEY `Index_producto` (`cid_produc`),
  ADD KEY `Index_alterno` (`cid_alter`);
ALTER TABLE `tproductos` ADD FULLTEXT KEY `Index_descripci` (`cdescripci`);

--
-- Indexes for table `tproductos_precio`
--
ALTER TABLE `tproductos_precio`
  ADD KEY `Index_producto` (`cid_produc`),
  ADD KEY `Index_tipopre` (`ctipo_pre`);

--
-- Indexes for table `tservicios`
--
ALTER TABLE `tservicios`
  ADD PRIMARY KEY (`idservicio`),
  ADD KEY `id_serv_padre` (`id_serv_padre`);

--
-- Indexes for table `tsublineas`
--
ALTER TABLE `tsublineas`
  ADD PRIMARY KEY (`cid_sublin`);

--
-- Indexes for table `ttipos_usuario`
--
ALTER TABLE `ttipos_usuario`
  ADD PRIMARY KEY (`cid_tipousuario`);

--
-- Indexes for table `tusuarios`
--
ALTER TABLE `tusuarios`
  ADD PRIMARY KEY (`clogin`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `chat`
--
ALTER TABLE `chat`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `encuesta`
--
ALTER TABLE `encuesta`
  MODIFY `nid_encuesta` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `topciones_encuesta`
--
ALTER TABLE `topciones_encuesta`
  MODIFY `nid_opcion` int(5) NOT NULL AUTO_INCREMENT;
--
-- Database: `felcason_demoliderplus`
--
CREATE DATABASE IF NOT EXISTS `liderplus` DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
USE `liderplus`;

-- --------------------------------------------------------

--
-- Table structure for table `chat`
--

DROP TABLE IF EXISTS `chat`;
CREATE TABLE `chat` (
  `id` int(10) UNSIGNED NOT NULL,
  `from` varchar(255) CHARACTER SET latin1 NOT NULL DEFAULT '',
  `to` varchar(255) CHARACTER SET latin1 NOT NULL DEFAULT '',
  `message` text,
  `sent` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `recd` int(10) UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `encuesta`
--

DROP TABLE IF EXISTS `encuesta`;
CREATE TABLE `encuesta` (
  `nid_encuesta` int(11) NOT NULL,
  `cpregunta` varchar(100) DEFAULT NULL,
  `lstatus` tinyint(1) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `tciudades`
--

DROP TABLE IF EXISTS `tciudades`;
CREATE TABLE `tciudades` (
  `cid_estado` varchar(2) DEFAULT NULL,
  `cid_ciudad` varchar(2) DEFAULT NULL,
  `cdescripci` varchar(20) DEFAULT NULL,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tclientes`
--

DROP TABLE IF EXISTS `tclientes`;
CREATE TABLE `tclientes` (
  `cid_clien` varchar(5) DEFAULT NULL,
  `cnombre_cl` varchar(100) DEFAULT NULL,
  `cdir_cli1` varchar(60) DEFAULT NULL,
  `cdir_cli2` varchar(60) DEFAULT NULL,
  `cid_ciudac` varchar(2) DEFAULT NULL,
  `cid_estadc` varchar(2) DEFAULT NULL,
  `cnombre_es` varchar(40) DEFAULT NULL,
  `dfecha_nes` datetime DEFAULT NULL,
  `ctele_cli` varchar(25) DEFAULT NULL,
  `ccelu_cli` varchar(25) DEFAULT NULL,
  `cfax_cli` varchar(25) DEFAULT NULL,
  `crif_cli` varchar(12) DEFAULT NULL,
  `cnit_cli` varchar(12) DEFAULT NULL,
  `dfecha_nac` datetime DEFAULT NULL,
  `cid_grucxc` varchar(2) DEFAULT NULL,
  `ndias_blo` smallint(6) DEFAULT NULL,
  `mobservaci` longtext,
  `nlimite_c` decimal(17,2) DEFAULT NULL,
  `nsaldo_a` decimal(17,2) DEFAULT NULL,
  `nmaximo_d` decimal(7,2) DEFAULT NULL,
  `nvencimien` smallint(6) DEFAULT NULL,
  `dfecha_inc` datetime DEFAULT NULL,
  `ce_mail` varchar(60) DEFAULT NULL,
  `cid_vende` varchar(5) DEFAULT NULL,
  `cweb` varchar(50) DEFAULT NULL,
  `cid_zona` varchar(2) DEFAULT NULL,
  `cid_tipocl` varchar(2) DEFAULT NULL,
  `cid_ruta` varchar(2) DEFAULT NULL,
  `cnombre_r` varchar(40) DEFAULT NULL,
  `cdir_r1` varchar(40) DEFAULT NULL,
  `cdir_r2` varchar(40) DEFAULT NULL,
  `cid_ciudar` varchar(2) DEFAULT NULL,
  `cid_estadr` varchar(2) DEFAULT NULL,
  `ctel_habr` varchar(25) DEFAULT NULL,
  `cfax_r` varchar(25) DEFAULT NULL,
  `ccelular_r` varchar(25) DEFAULT NULL,
  `dfecha_nr` date DEFAULT NULL,
  `mempresas` longtext,
  `ccategoria` varchar(3) DEFAULT NULL,
  `cactividad` varchar(20) DEFAULT NULL,
  `mcontactos` longtext,
  `cdir_env1` varchar(60) DEFAULT NULL,
  `cdir_env2` varchar(60) DEFAULT NULL,
  `ctele_env` varchar(25) DEFAULT NULL,
  `ccelu_env` varchar(25) DEFAULT NULL,
  `cfax_env` varchar(25) DEFAULT NULL,
  `cid_ciudae` varchar(2) DEFAULT NULL,
  `cid_estade` varchar(2) DEFAULT NULL,
  `lcontribu` bit(1) DEFAULT NULL,
  `cid_tipo_p` varchar(2) DEFAULT NULL,
  `lcliente_b` bit(1) DEFAULT NULL,
  `lactivo` bit(1) DEFAULT NULL,
  `ndescadic` decimal(7,2) DEFAULT NULL,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL,
  `cdirimag` longtext,
  `cid_tpr_cr` varchar(2) DEFAULT NULL,
  `ctipo` varchar(2) DEFAULT NULL,
  `nporc_ret` decimal(7,2) DEFAULT NULL,
  `nmonto_ret` decimal(17,2) DEFAULT NULL,
  `cid_grunc` varchar(2) DEFAULT NULL,
  `cid_grund` varchar(2) DEFAULT NULL,
  `cid_tiponc` varchar(2) DEFAULT NULL,
  `cid_tipond` varchar(2) DEFAULT NULL,
  `cid_cuennc` varchar(16) DEFAULT NULL,
  `cid_cuennd` varchar(16) DEFAULT NULL,
  `ndias_ret` smallint(6) DEFAULT NULL,
  `cnombre_de` varchar(40) DEFAULT NULL,
  `lcredito` bit(1) DEFAULT NULL,
  `linternet` bit(1) DEFAULT NULL,
  `cusuweb` varchar(20) DEFAULT NULL,
  `ccod_secre` varchar(20) DEFAULT NULL,
  `cpostal` varchar(4) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tcolores`
--

DROP TABLE IF EXISTS `tcolores`;
CREATE TABLE `tcolores` (
  `cid_color` varchar(3) DEFAULT NULL,
  `cdescripci` varchar(40) DEFAULT NULL,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tconfiguracion`
--

DROP TABLE IF EXISTS `tconfiguracion`;
CREATE TABLE `tconfiguracion` (
  `cid_vende` varchar(5) NOT NULL,
  `b` varchar(5) NOT NULL,
  `cid_pedido` int(10) UNSIGNED DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tcontroles`
--

DROP TABLE IF EXISTS `tcontroles`;
CREATE TABLE `tcontroles` (
  `niva` double NOT NULL,
  `cid_vende` varchar(5) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `tcotizaciones`
--

DROP TABLE IF EXISTS `tcotizaciones`;
CREATE TABLE `tcotizaciones` (
  `cid_cotiza` varchar(8) DEFAULT NULL,
  `cid_clien` varchar(5) DEFAULT NULL,
  `cnombre_cl` varchar(100) DEFAULT NULL,
  `npesototal` decimal(14,4) DEFAULT NULL,
  `nmonto_e` decimal(17,2) DEFAULT NULL,
  `nmonto_b` decimal(17,2) DEFAULT NULL,
  `crif_cli` varchar(12) DEFAULT NULL,
  `cid_vende` varchar(5) DEFAULT NULL,
  `dfecha` date DEFAULT NULL,
  `dfecha_ven` date DEFAULT NULL,
  `cid_pedido` varchar(8) DEFAULT NULL,
  `ctipo_pre` varchar(2) DEFAULT NULL,
  `mobservaci` longtext,
  `nmonto_c` decimal(17,2) DEFAULT NULL,
  `ndesc_por` decimal(7,2) DEFAULT NULL,
  `ndesc_bol` decimal(17,2) DEFAULT NULL,
  `nbase_iva` decimal(17,2) DEFAULT NULL,
  `ntasa_iva` decimal(7,2) DEFAULT NULL,
  `nsub_desc` decimal(17,2) DEFAULT NULL,
  `nmontoti` decimal(17,2) DEFAULT NULL,
  `nmontotal` decimal(17,2) DEFAULT NULL,
  `cid_status` varchar(3) DEFAULT NULL,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL,
  `nvolumen` decimal(11,3) DEFAULT NULL,
  `nmontodesc` decimal(17,2) DEFAULT NULL,
  `nmonto_eb` decimal(17,2) DEFAULT NULL,
  `nmontoiva` decimal(17,2) DEFAULT NULL,
  `_nullflags` varchar(1) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tcuentas_banco`
--

DROP TABLE IF EXISTS `tcuentas_banco`;
CREATE TABLE `tcuentas_banco` (
  `cid_cuen_b` varchar(5) DEFAULT NULL,
  `csucursal` varchar(40) DEFAULT NULL,
  `cid_banco` varchar(2) DEFAULT NULL,
  `cnro_cuen` varchar(20) DEFAULT NULL,
  `ldebito_b` bit(1) DEFAULT NULL,
  `ndebito_b` decimal(7,2) DEFAULT NULL,
  `ccuenta_cb` varchar(16) DEFAULT NULL,
  `ccuenta_cd` varchar(16) DEFAULT NULL,
  `cid_tipoc` varchar(2) DEFAULT NULL,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL,
  `nsaldo_act` decimal(17,2) DEFAULT NULL,
  `nsaldo_ini` decimal(17,2) DEFAULT NULL,
  `nsaldo_ic` decimal(17,2) DEFAULT NULL,
  `nsaldo_ac` decimal(17,2) DEFAULT NULL,
  `ccontacto` varchar(40) DEFAULT NULL,
  `nnumch_ini` bigint(20) DEFAULT NULL,
  `nnumch_fin` bigint(20) DEFAULT NULL,
  `lcompegr` bit(1) DEFAULT NULL,
  `ncompegr` int(11) DEFAULT NULL,
  `ncompnd` int(11) DEFAULT NULL,
  `lcompigr` bit(1) DEFAULT NULL,
  `ncompigr` int(11) DEFAULT NULL,
  `ncompnc` int(11) DEFAULT NULL,
  `nfactor` decimal(17,2) DEFAULT NULL,
  `npor_cr` decimal(7,2) DEFAULT NULL,
  `ccuenta_cr` varchar(16) DEFAULT NULL,
  `npor_db` decimal(7,2) DEFAULT NULL,
  `ccuenta_db` varchar(16) DEFAULT NULL,
  `npor_islr` decimal(7,2) DEFAULT NULL,
  `ccuenta_is` varchar(16) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tdetalles_cotizacion`
--

DROP TABLE IF EXISTS `tdetalles_cotizacion`;
CREATE TABLE `tdetalles_cotizacion` (
  `cid_cotiza` varchar(8) DEFAULT NULL,
  `cid_produc` varchar(20) DEFAULT NULL,
  `ncantidad` decimal(19,3) DEFAULT NULL,
  `nprecio` decimal(25,6) DEFAULT NULL,
  `nmonto` decimal(17,2) DEFAULT NULL,
  `nfacturado` decimal(17,2) DEFAULT NULL,
  `ndescuento` decimal(16,6) DEFAULT NULL,
  `mobservaci` longtext,
  `nlinea` int(11) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tdetalles_devolucion_venta`
--

DROP TABLE IF EXISTS `tdetalles_devolucion_venta`;
CREATE TABLE `tdetalles_devolucion_venta` (
  `CID_DEV_V` varchar(8) DEFAULT NULL,
  `CID_PRODUC` varchar(20) DEFAULT NULL,
  `NCANTIDAD` float(16,3) DEFAULT NULL,
  `NPRECIO` float(19,6) DEFAULT NULL,
  `NDEVUELTO` float(15,2) DEFAULT NULL,
  `NMONTO` float(19,6) DEFAULT NULL,
  `NDESCUENTO` float(10,6) DEFAULT NULL,
  `CID_ALMACE` varchar(2) DEFAULT NULL,
  `MOBSERVACI` mediumtext,
  `NCANTKG` float(16,3) DEFAULT NULL,
  `CLOTE` varchar(10) DEFAULT NULL,
  `DFECHA_VEN` date DEFAULT NULL,
  `NLINEA` int(11) DEFAULT NULL,
  `CID_VENDE` varchar(5) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tdetalles_pedido`
--

DROP TABLE IF EXISTS `tdetalles_pedido`;
CREATE TABLE `tdetalles_pedido` (
  `cid_pedido` varchar(8) DEFAULT NULL,
  `cid_produc` varchar(20) DEFAULT NULL,
  `ncantidad` decimal(19,3) DEFAULT NULL,
  `nentregado` decimal(17,2) DEFAULT NULL,
  `mobservaci` longtext,
  `nprecio` decimal(25,6) DEFAULT NULL,
  `nmonto` decimal(17,2) DEFAULT NULL,
  `ndescuento` decimal(8,2) DEFAULT NULL,
  `cid_docum` varchar(2) DEFAULT NULL,
  `cid_prefac` varchar(8) DEFAULT NULL,
  `nlinea` int(11) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tdetalles_recibo_ingreso`
--

DROP TABLE IF EXISTS `tdetalles_recibo_ingreso`;
CREATE TABLE `tdetalles_recibo_ingreso` (
  `CID_CLIEN` char(5) NOT NULL,
  `CID_DOCUM` char(8) DEFAULT NULL,
  `CID_GRUPO` char(2) DEFAULT NULL,
  `CID_TIPO_A` char(2) DEFAULT NULL,
  `CID_TIPO_D` char(2) DEFAULT NULL,
  `CREFERENCI` char(8) DEFAULT NULL,
  `CTIPO` char(1) DEFAULT NULL,
  `DFECHA` date DEFAULT NULL,
  `MOBSERVACI` text,
  `NMONTO_D` decimal(18,2) DEFAULT NULL,
  `NMONTO_H` decimal(18,2) DEFAULT NULL,
  `NSALDO` decimal(18,2) DEFAULT NULL,
  `CDOC_REF` char(8) DEFAULT NULL,
  `NFACTOR` decimal(20,10) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tdetalles_servicios`
--

DROP TABLE IF EXISTS `tdetalles_servicios`;
CREATE TABLE `tdetalles_servicios` (
  `idservicio` varchar(3) DEFAULT NULL,
  `tipousuario` varchar(2) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tdetalles_usuario`
--

DROP TABLE IF EXISTS `tdetalles_usuario`;
CREATE TABLE `tdetalles_usuario` (
  `clogin` varchar(10) NOT NULL,
  `cid_clien` varchar(5) NOT NULL,
  `ccargo` varchar(45) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tdetalles_vendedor_cuenta`
--

DROP TABLE IF EXISTS `tdetalles_vendedor_cuenta`;
CREATE TABLE `tdetalles_vendedor_cuenta` (
  `cid_vende` varchar(5) DEFAULT NULL,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tdevoluciones_venta`
--

DROP TABLE IF EXISTS `tdevoluciones_venta`;
CREATE TABLE `tdevoluciones_venta` (
  `CID_DEV_V` varchar(8) DEFAULT NULL,
  `CID_FACTU` varchar(8) DEFAULT NULL,
  `DFECHA` date DEFAULT NULL,
  `CID_CLIEN` varchar(5) DEFAULT NULL,
  `CNOMBRE_CL` varchar(100) DEFAULT NULL,
  `CRIF_CLI` varchar(12) DEFAULT NULL,
  `CID_VENDE` varchar(5) DEFAULT NULL,
  `NMONTO_E` float(19,6) DEFAULT NULL,
  `NMONTO_B` float(19,6) DEFAULT NULL,
  `NTASA_IVA` float(15,2) DEFAULT NULL,
  `NSUB_TOT` float(19,6) DEFAULT NULL,
  `NMONTO_T` float(19,6) DEFAULT NULL,
  `NMONTO_TI` float(19,6) DEFAULT NULL,
  `CID_STATUS` varchar(3) DEFAULT NULL,
  `MOBSERVACI` mediumtext,
  `CID_USUARI` varchar(8) DEFAULT NULL,
  `DFECHA_ACT` datetime DEFAULT NULL,
  `CID_GRUPO` varchar(2) DEFAULT NULL,
  `NBASE_IVA` float(19,6) DEFAULT NULL,
  `NPORDESC` float(5,2) DEFAULT NULL,
  `NDESCUENTO` float(15,2) DEFAULT NULL,
  `CID_ALMRET` varchar(2) DEFAULT NULL,
  `NDCTOBOLI` float(15,2) DEFAULT NULL,
  `LIMPRESO` bit(1) DEFAULT NULL,
  `CID_TIPO_D` varchar(2) DEFAULT NULL,
  `CNRO_CONTROL` varchar(8) DEFAULT NULL,
  `CSERIE` varchar(2) DEFAULT NULL,
  `CTIPO_DEV` varchar(1) DEFAULT NULL,
  `CID_CLIPRO` varchar(5) DEFAULT NULL,
  `CCOMPROB_F` varchar(12) DEFAULT NULL,
  `CMAQUINA_F` varchar(12) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tdocumentos_cxc`
--

DROP TABLE IF EXISTS `tdocumentos_cxc`;
CREATE TABLE `tdocumentos_cxc` (
  `cid_doccxc` varchar(8) DEFAULT NULL,
  `cid_tipo_d` varchar(2) DEFAULT NULL,
  `cid_clien` varchar(5) DEFAULT NULL,
  `dfecha` date DEFAULT NULL,
  `dfecha_ven` date DEFAULT NULL,
  `nsaldo` decimal(17,2) DEFAULT NULL,
  `cid_grucxc` varchar(2) DEFAULT NULL,
  `nmonto_d` decimal(17,2) DEFAULT NULL,
  `nmonto_h` decimal(17,2) DEFAULT NULL,
  `cid_vende` varchar(5) DEFAULT NULL,
  `cid_ven_a` varchar(5) DEFAULT NULL,
  `dfecha_a` date DEFAULT NULL,
  `nimpuesto` decimal(17,2) DEFAULT NULL,
  `cid_status` varchar(3) DEFAULT NULL,
  `lcobro` bit(1) DEFAULT NULL,
  `mobservaci` longtext,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL,
  `nbase` decimal(17,2) DEFAULT NULL,
  `ntasa_iva` decimal(7,2) DEFAULT NULL,
  `nfactor` decimal(21,6) DEFAULT NULL,
  `cnrofiscal` varchar(8) DEFAULT NULL,
  `cserie` varchar(2) DEFAULT NULL,
  `limpreso` bit(1) DEFAULT NULL,
  `dfecha_nue` date DEFAULT NULL,
  `dfecha_vie` date DEFAULT NULL,
  `cid_factug` varchar(8) DEFAULT NULL,
  `ccomprob_f` varchar(12) DEFAULT NULL,
  `cmaquina_f` varchar(12) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `testados`
--

DROP TABLE IF EXISTS `testados`;
CREATE TABLE `testados` (
  `cid_estado` varchar(2) DEFAULT NULL,
  `cdescripci` varchar(20) DEFAULT NULL,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `thistorial_gps`
--

DROP TABLE IF EXISTS `thistorial_gps`;
CREATE TABLE `thistorial_gps` (
  `cserial` varchar(50) DEFAULT NULL,
  `nlongitud` double DEFAULT NULL,
  `nlatitud` double DEFAULT NULL,
  `nprecision` double DEFAULT NULL,
  `nhora_gps` double DEFAULT NULL,
  `cproveedor` char(50) DEFAULT NULL,
  `lenviado` tinyint(1) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tlineas`
--

DROP TABLE IF EXISTS `tlineas`;
CREATE TABLE `tlineas` (
  `cid_linea` varchar(3) DEFAULT NULL,
  `cdescripci` varchar(40) DEFAULT NULL,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tnoticias`
--

DROP TABLE IF EXISTS `tnoticias`;
CREATE TABLE `tnoticias` (
  `id_noticia` varchar(5) NOT NULL,
  `titulo_noticia` tinytext,
  `contenido_noticia` text,
  `fecha` date NOT NULL,
  `status` varchar(1) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `topciones_encuesta`
--

DROP TABLE IF EXISTS `topciones_encuesta`;
CREATE TABLE `topciones_encuesta` (
  `nid_opcion` int(5) NOT NULL,
  `nid_encuesta` int(5) NOT NULL,
  `cdescripcion` varchar(100) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tpedidos`
--

DROP TABLE IF EXISTS `tpedidos`;
CREATE TABLE `tpedidos` (
  `cid_pedido` int(10) UNSIGNED NOT NULL,
  `cid_clien` char(5) DEFAULT NULL,
  `dfecha` datetime DEFAULT NULL,
  `cid_status` char(3) DEFAULT NULL,
  `mobservaci` mediumtext,
  `npesototal` double DEFAULT NULL,
  `cnombre_cl` char(100) DEFAULT NULL,
  `crif_cli` char(12) DEFAULT NULL,
  `cid_priori` char(1) DEFAULT NULL,
  `cid_usuari` char(8) DEFAULT NULL,
  `cid_vende` char(5) DEFAULT NULL,
  `creferenci` char(5) DEFAULT NULL,
  `nvolumen` int(11) DEFAULT NULL,
  `ctipo_pre` char(0) DEFAULT NULL,
  `nmonto_t` double DEFAULT NULL,
  `dfecha_e` date DEFAULT NULL,
  `corden_com` char(0) DEFAULT NULL,
  `cid_almace` char(20) DEFAULT NULL,
  `cid_transp` char(2) DEFAULT NULL,
  `cconductor` char(2) DEFAULT NULL,
  `ctelefono` char(30) DEFAULT NULL,
  `ccedula` char(30) DEFAULT NULL,
  `ccamion` char(15) DEFAULT NULL,
  `cplaca` char(20) DEFAULT NULL,
  `nmontoti` double DEFAULT NULL,
  `ntasa_iva` double DEFAULT NULL,
  `nbase_iva` double DEFAULT NULL,
  `nmonto_f` double DEFAULT NULL,
  `nmonto_b` double DEFAULT NULL,
  `nmonto_e` double DEFAULT NULL,
  `nmonto_eb` double DEFAULT NULL,
  `nmontoiva` double DEFAULT NULL,
  `nlatitud` double DEFAULT NULL,
  `nlongitud` double DEFAULT NULL,
  `nprecision` float DEFAULT NULL,
  `nhora_gps` double DEFAULT NULL,
  `cproveedor` varchar(50) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tproductos`
--

DROP TABLE IF EXISTS `tproductos`;
CREATE TABLE `tproductos` (
  `cid_produc` varchar(20) DEFAULT NULL,
  `cdescripci` varchar(40) DEFAULT NULL,
  `cdescrialt` varchar(40) DEFAULT NULL,
  `cempaque` varchar(8) DEFAULT NULL,
  `creferenci` varchar(40) DEFAULT NULL,
  `npeso` decimal(14,4) DEFAULT NULL,
  `cunidad_m` varchar(3) DEFAULT NULL,
  `nmedida_l` decimal(11,3) DEFAULT NULL,
  `nmedida_m` decimal(11,3) DEFAULT NULL,
  `nmedida_p` decimal(11,3) DEFAULT NULL,
  `dfecha_inc` date DEFAULT NULL,
  `cclasi1` varchar(3) DEFAULT NULL,
  `cclasi2` varchar(3) DEFAULT NULL,
  `cclasi3` varchar(3) DEFAULT NULL,
  `cclasi4` varchar(3) DEFAULT NULL,
  `nmaximo` decimal(19,3) DEFAULT NULL,
  `nminimo` decimal(19,3) DEFAULT NULL,
  `lapli_iva` bit(1) DEFAULT NULL,
  `nporc_iva` decimal(7,2) DEFAULT NULL,
  `gfoto` varchar(40) DEFAULT NULL,
  `lservicio` bit(1) DEFAULT NULL,
  `ngarantia` smallint(6) DEFAULT NULL,
  `mobservaci` longtext,
  `npuntos_v` int(11) DEFAULT NULL,
  `npuntos_c` int(11) DEFAULT NULL,
  `lserial` bit(1) DEFAULT NULL,
  `nmonto_c` decimal(17,2) DEFAULT NULL,
  `cid_alter` varchar(20) DEFAULT NULL,
  `nexisten` decimal(19,3) DEFAULT NULL,
  `ncompro` decimal(19,3) DEFAULT NULL,
  `napartado` decimal(19,3) DEFAULT NULL,
  `npedido` decimal(19,3) DEFAULT NULL,
  `npordes` decimal(19,3) DEFAULT NULL,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT CURRENT_TIMESTAMP,
  `lactivo` bit(1) DEFAULT NULL,
  `cid_gru_ar` varchar(3) DEFAULT NULL,
  `cid_cuenco` varchar(16) DEFAULT NULL,
  `cid_cuende` varchar(16) DEFAULT NULL,
  `cid_cuenve` varchar(16) DEFAULT NULL,
  `cid_cuenin` varchar(16) DEFAULT NULL,
  `ldual` bit(1) DEFAULT NULL,
  `ldecimales` bit(1) DEFAULT NULL,
  `cid_cuendc` varchar(16) DEFAULT NULL,
  `cid_prodkg` varchar(20) DEFAULT NULL,
  `ndescmax` decimal(8,2) DEFAULT NULL,
  `nmindias` int(11) DEFAULT NULL,
  `nmaxdias` int(11) DEFAULT NULL,
  `lprodvario` bit(1) DEFAULT NULL,
  `ltransito` int(11) DEFAULT NULL,
  `lrecienllegado` int(11) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tproductos_almacen`
--

DROP TABLE IF EXISTS `tproductos_almacen`;
CREATE TABLE `tproductos_almacen` (
  `cid_produc` varchar(20) NOT NULL,
  `cid_almace` varchar(2) NOT NULL,
  `nexisten` varchar(20) NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tproductos_equivalente`
--

DROP TABLE IF EXISTS `tproductos_equivalente`;
CREATE TABLE `tproductos_equivalente` (
  `cid_produc` varchar(20) DEFAULT NULL,
  `cid_equiva` varchar(20) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tproductos_precio`
--

DROP TABLE IF EXISTS `tproductos_precio`;
CREATE TABLE `tproductos_precio` (
  `cid_produc` char(20) DEFAULT NULL,
  `ctipo_pre` char(2) DEFAULT NULL,
  `nprecio` double DEFAULT NULL,
  `ctipo_ref` char(2) DEFAULT NULL,
  `nfactor` double DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `trecibos_ingreso`
--

DROP TABLE IF EXISTS `trecibos_ingreso`;
CREATE TABLE `trecibos_ingreso` (
  `CID_RECI_I` char(8) DEFAULT NULL,
  `DFECHA` date DEFAULT NULL,
  `CID_CLIEN` char(5) DEFAULT NULL,
  `CID_COBRA` char(5) DEFAULT NULL,
  `MOBSERVACI` text,
  `CID_STATUS` char(3) DEFAULT NULL,
  `NMONTO` decimal(18,2) DEFAULT NULL,
  `CID_USUARI` char(8) DEFAULT NULL,
  `DFECHA_ACT` datetime DEFAULT NULL,
  `CID_CAJA` char(2) DEFAULT NULL,
  `CNRO_FIS` char(8) DEFAULT NULL,
  `LIMPRESO` tinyint(4) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tservicios`
--

DROP TABLE IF EXISTS `tservicios`;
CREATE TABLE `tservicios` (
  `idservicio` varchar(3) NOT NULL,
  `id_serv_padre` varchar(5) DEFAULT NULL,
  `descripcion` varchar(40) DEFAULT NULL,
  `url` varchar(100) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tsublineas`
--

DROP TABLE IF EXISTS `tsublineas`;
CREATE TABLE `tsublineas` (
  `cid_sublin` varchar(3) NOT NULL,
  `cdescripci` varchar(40) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `ttallas`
--

DROP TABLE IF EXISTS `ttallas`;
CREATE TABLE `ttallas` (
  `cid_talla` varchar(3) DEFAULT NULL,
  `cdescripci` varchar(40) DEFAULT NULL,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `ttipos_documentocxc`
--

DROP TABLE IF EXISTS `ttipos_documentocxc`;
CREATE TABLE `ttipos_documentocxc` (
  `cid_tipod` varchar(2) DEFAULT NULL,
  `cdescripci` varchar(40) DEFAULT NULL,
  `lsuma` bit(1) DEFAULT NULL,
  `cabreviado` varchar(4) DEFAULT NULL,
  `ndias_ven` smallint(6) DEFAULT NULL,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL,
  `lventa` bit(1) DEFAULT NULL,
  `liva_reten` bit(1) DEFAULT NULL,
  `lnotacr` bit(1) DEFAULT NULL,
  `lfiscal` bit(1) DEFAULT NULL,
  `cid_cuenta` varchar(16) DEFAULT NULL,
  `cid_tipcan` varchar(2) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `ttipos_precio`
--

DROP TABLE IF EXISTS `ttipos_precio`;
CREATE TABLE `ttipos_precio` (
  `cid_tipo_p` varchar(2) DEFAULT NULL,
  `cdescripci` varchar(10) DEFAULT NULL,
  `nfactor` decimal(20,5) DEFAULT NULL,
  `ctipo_ref` varchar(2) DEFAULT NULL,
  `linclu_iva` bit(1) DEFAULT NULL,
  `ndecimal` tinyint(4) DEFAULT NULL,
  `lmuestra` bit(1) DEFAULT NULL,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL,
  `ldecena` bit(1) DEFAULT NULL,
  `lcentena` bit(1) DEFAULT NULL,
  `lunida_mil` bit(1) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `ttipos_usuario`
--

DROP TABLE IF EXISTS `ttipos_usuario`;
CREATE TABLE `ttipos_usuario` (
  `cid_tipousuario` varchar(2) NOT NULL,
  `cdescripci` varchar(20) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `ttipos_vendedor`
--

DROP TABLE IF EXISTS `ttipos_vendedor`;
CREATE TABLE `ttipos_vendedor` (
  `cid_tipove` varchar(2) DEFAULT NULL,
  `cdescripci` varchar(40) DEFAULT NULL,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tusuarios`
--

DROP TABLE IF EXISTS `tusuarios`;
CREATE TABLE `tusuarios` (
  `clogin` varchar(10) NOT NULL,
  `ccontrasena` varchar(10) DEFAULT NULL,
  `crif` varchar(12) DEFAULT NULL,
  `cnombres` varchar(40) DEFAULT NULL,
  `capellidos` varchar(40) DEFAULT NULL,
  `crazonsocial` varchar(100) DEFAULT NULL,
  `cid_tipo_usuario` varchar(2) DEFAULT NULL,
  `cstatus` varchar(1) DEFAULT NULL,
  `cid_vende` varchar(5) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tvendedores`
--

DROP TABLE IF EXISTS `tvendedores`;
CREATE TABLE `tvendedores` (
  `cid_vende` varchar(5) DEFAULT NULL,
  `cnombrev` varchar(40) DEFAULT NULL,
  `cdir_ven1` varchar(40) DEFAULT NULL,
  `cdir_ven2` varchar(40) DEFAULT NULL,
  `ctele_ven` varchar(25) DEFAULT NULL,
  `ccelu_ven` varchar(25) DEFAULT NULL,
  `cfax_ven` varchar(25) DEFAULT NULL,
  `crif_ven` varchar(12) DEFAULT NULL,
  `cnit_ven` varchar(12) DEFAULT NULL,
  `mobservaci` longtext,
  `dfecha_nac` date DEFAULT NULL,
  `dfecha_inc` date DEFAULT NULL,
  `ce_mail` varchar(50) DEFAULT NULL,
  `lactivo` bit(1) DEFAULT NULL,
  `npor_comc` decimal(7,2) DEFAULT NULL,
  `npor_comv` decimal(7,2) DEFAULT NULL,
  `cid_tipove` varchar(2) DEFAULT NULL,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL,
  `ncostomano` decimal(17,2) DEFAULT NULL,
  `ldescuento` bit(1) DEFAULT NULL,
  `ndescmax` decimal(8,2) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tvendedor_actividades`
--

DROP TABLE IF EXISTS `tvendedor_actividades`;
CREATE TABLE `tvendedor_actividades` (
  `cid_vende` varchar(5) DEFAULT NULL,
  `dfecha` date DEFAULT NULL,
  `dfecha_fin` date DEFAULT NULL,
  `cid_status` varchar(1) DEFAULT NULL,
  `cprioridad` varchar(1) DEFAULT NULL,
  `ctitulo` varchar(40) DEFAULT NULL,
  `mactividad` longtext,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL,
  `dfecha_f` date DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tvendedor_precio`
--

DROP TABLE IF EXISTS `tvendedor_precio`;
CREATE TABLE `tvendedor_precio` (
  `cid_vende` varchar(5) DEFAULT NULL,
  `cid_tipo_p` varchar(2) DEFAULT NULL,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL,
  `cnro_doc` varchar(2) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tvisitas_empresa`
--

DROP TABLE IF EXISTS `tvisitas_empresa`;
CREATE TABLE `tvisitas_empresa` (
  `cid_clien` varchar(5) DEFAULT NULL,
  `cid_vende` varchar(5) DEFAULT NULL,
  `dfecha_v` varchar(10) DEFAULT NULL,
  `mobservaci` varchar(200) DEFAULT NULL,
  `cid_status` varchar(1) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tvotos`
--

DROP TABLE IF EXISTS `tvotos`;
CREATE TABLE `tvotos` (
  `nid_encuesta` int(5) NOT NULL,
  `nid_opcion` int(5) NOT NULL,
  `cip` varchar(15) DEFAULT NULL,
  `dfecha_voto` varchar(10) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `chat`
--
ALTER TABLE `chat`
  ADD PRIMARY KEY (`id`),
  ADD KEY `to` (`to`),
  ADD KEY `from` (`from`);

--
-- Indexes for table `encuesta`
--
ALTER TABLE `encuesta`
  ADD PRIMARY KEY (`nid_encuesta`);

--
-- Indexes for table `tcontroles`
--
ALTER TABLE `tcontroles`
  ADD PRIMARY KEY (`niva`);

--
-- Indexes for table `tdetalles_usuario`
--
ALTER TABLE `tdetalles_usuario`
  ADD PRIMARY KEY (`clogin`,`cid_clien`);

--
-- Indexes for table `tnoticias`
--
ALTER TABLE `tnoticias`
  ADD PRIMARY KEY (`id_noticia`);

--
-- Indexes for table `topciones_encuesta`
--
ALTER TABLE `topciones_encuesta`
  ADD PRIMARY KEY (`nid_opcion`);

--
-- Indexes for table `tpedidos`
--
ALTER TABLE `tpedidos`
  ADD PRIMARY KEY (`cid_pedido`);

--
-- Indexes for table `tproductos`
--
ALTER TABLE `tproductos`
  ADD KEY `Index_producto` (`cid_produc`),
  ADD KEY `Index_alterno` (`cid_alter`);
ALTER TABLE `tproductos` ADD FULLTEXT KEY `Index_descripci` (`cdescripci`);

--
-- Indexes for table `tproductos_precio`
--
ALTER TABLE `tproductos_precio`
  ADD KEY `Index_producto` (`cid_produc`),
  ADD KEY `Index_tipopre` (`ctipo_pre`);

--
-- Indexes for table `tservicios`
--
ALTER TABLE `tservicios`
  ADD PRIMARY KEY (`idservicio`),
  ADD KEY `id_serv_padre` (`id_serv_padre`);

--
-- Indexes for table `tsublineas`
--
ALTER TABLE `tsublineas`
  ADD PRIMARY KEY (`cid_sublin`);

--
-- Indexes for table `ttipos_usuario`
--
ALTER TABLE `ttipos_usuario`
  ADD PRIMARY KEY (`cid_tipousuario`);

--
-- Indexes for table `tusuarios`
--
ALTER TABLE `tusuarios`
  ADD PRIMARY KEY (`clogin`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `chat`
--
ALTER TABLE `chat`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `encuesta`
--
ALTER TABLE `encuesta`
  MODIFY `nid_encuesta` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `topciones_encuesta`
--
ALTER TABLE `topciones_encuesta`
  MODIFY `nid_opcion` int(5) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
