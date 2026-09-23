-- ============================================================================
-- LIDERPLUS SANDBOX — Script de creación de base de datos local
-- Generado para pruebas CRUD del sincronizador VFP liderplussync
-- Ejecutar en MySQL local (5.7+ o 8.0)
-- ============================================================================

DROP DATABASE IF EXISTS `liderplus_sandbox`;
CREATE DATABASE `liderplus_sandbox` DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
USE `liderplus_sandbox`;

-- ============================================================================
-- TABLAS ESCRITAS POR inventario.prg (tmrEnviar → EJECUTAR_TAREA)
-- ============================================================================

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
  `lrecienllegado` int(11) DEFAULT NULL,
  KEY `Index_producto` (`cid_produc`),
  KEY `Index_alterno` (`cid_alter`),
  FULLTEXT KEY `Index_descripci` (`cdescripci`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `tproductos_precio`;
CREATE TABLE `tproductos_precio` (
  `cid_produc` char(20) DEFAULT NULL,
  `ctipo_pre` char(2) DEFAULT NULL,
  `nprecio` double DEFAULT NULL,
  `ctipo_ref` char(2) DEFAULT NULL,
  `nfactor` double DEFAULT NULL,
  KEY `Index_producto` (`cid_produc`),
  KEY `Index_tipopre` (`ctipo_pre`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `tproductos_almacen`;
CREATE TABLE `tproductos_almacen` (
  `cid_produc` varchar(20) NOT NULL,
  `cid_almace` varchar(2) NOT NULL,
  `nexisten` varchar(20) NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Tabla referenciada en inventario.prg línea 257
DROP TABLE IF EXISTS `tvendedores_almacen`;
CREATE TABLE `tvendedores_almacen` (
  `cid_vende` varchar(5) DEFAULT NULL,
  `cid_almace` varchar(2) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `tlineas`;
CREATE TABLE `tlineas` (
  `cid_linea` varchar(3) DEFAULT NULL,
  `cdescripci` varchar(40) DEFAULT NULL,
  `cid_usuari` varchar(8) DEFAULT NULL,
  `dfecha_act` datetime DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `tcontroles`;
CREATE TABLE `tcontroles` (
  `niva` double NOT NULL,
  `cid_vende` varchar(5) DEFAULT NULL,
  PRIMARY KEY (`niva`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- Tabla referenciada en inventario.prg línea 400
DROP TABLE IF EXISTS `ttipos_moneda`;
CREATE TABLE `ttipos_moneda` (
  `cid_tipmo` varchar(3) DEFAULT NULL,
  `cdescripci` varchar(40) DEFAULT NULL,
  `nfactor` decimal(20,10) DEFAULT NULL,
  `cabrevia` varchar(5) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ============================================================================
-- TABLAS ESCRITAS POR cxc.prg (tmrEnviar → EJECUTAR_TAREA)
-- ============================================================================

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

-- Tablas que cxc.prg borra/recrea pero NO están en localhost.sql
-- Estructura inferida del INSERT que genera el PRG
DROP TABLE IF EXISTS `tfacturas`;
CREATE TABLE `tfacturas` (
  `cid_factura` varchar(8) DEFAULT NULL,
  `cid_clien` varchar(5) DEFAULT NULL,
  `cnombre_cl` varchar(100) DEFAULT NULL,
  `crif_cli` varchar(12) DEFAULT NULL,
  `dfecha` date DEFAULT NULL,
  `cid_vende` varchar(5) DEFAULT NULL,
  `nmonto_t` decimal(17,2) DEFAULT NULL,
  `cid_status` varchar(3) DEFAULT NULL,
  `cid_empre` varchar(5) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `tdetalles_factura`;
CREATE TABLE `tdetalles_factura` (
  `cid_factura` varchar(8) DEFAULT NULL,
  `cid_produc` varchar(20) DEFAULT NULL,
  `ncantidad` decimal(19,3) DEFAULT NULL,
  `nprecio` decimal(25,6) DEFAULT NULL,
  `nmonto` decimal(17,2) DEFAULT NULL,
  `ndescuento` decimal(8,2) DEFAULT NULL,
  `cid_empre` varchar(5) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ============================================================================
-- TABLAS LEÍDAS/ESCRITAS POR pedidos.prg y devoluciones.prg (tmrRecibir)
-- ============================================================================

DROP TABLE IF EXISTS `tpedidos`;
CREATE TABLE `tpedidos` (
  `cid_pedido` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
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
  `ctipo_pre` char(2) DEFAULT NULL,
  `nmonto_t` double DEFAULT NULL,
  `dfecha_e` date DEFAULT NULL,
  `corden_com` char(10) DEFAULT NULL,
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
  `cproveedor` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`cid_pedido`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

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

-- ============================================================================
-- TABLAS ESCRITAS POR cajas.prg (tmrEnviar)
-- Estructura inferida de los SQLEXEC en el PRG
-- ============================================================================

DROP TABLE IF EXISTS `tdetalles_pago_factura`;
CREATE TABLE `tdetalles_pago_factura` (
  `cid_factura` varchar(8) DEFAULT NULL,
  `ctipo_pago` varchar(3) DEFAULT NULL,
  `nmonto` decimal(17,2) DEFAULT NULL,
  `creferencia` varchar(20) DEFAULT NULL,
  `cid_empre` varchar(5) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `tdetalles_pago_recibo`;
CREATE TABLE `tdetalles_pago_recibo` (
  `cid_recibo` varchar(8) DEFAULT NULL,
  `ctipo_pago` varchar(3) DEFAULT NULL,
  `nmonto` decimal(17,2) DEFAULT NULL,
  `creferencia` varchar(20) DEFAULT NULL,
  `cid_empre` varchar(5) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `tgastos`;
CREATE TABLE `tgastos` (
  `cid_gasto` varchar(8) DEFAULT NULL,
  `cdescripci` varchar(100) DEFAULT NULL,
  `nmonto` decimal(17,2) DEFAULT NULL,
  `dfecha` date DEFAULT NULL,
  `cid_empre` varchar(5) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ============================================================================
-- TABLA DE CONTROL DE SINCRONIZACIÓN
-- ============================================================================

DROP TABLE IF EXISTS `tsincronizacion`;
CREATE TABLE `tsincronizacion` (
  `cid_empre` varchar(5) DEFAULT NULL,
  `dact_inven` datetime DEFAULT NULL,
  `dact_cxc` datetime DEFAULT NULL,
  `dact_cajas` datetime DEFAULT NULL,
  `dact_pedid` datetime DEFAULT NULL,
  `dact_devol` datetime DEFAULT NULL,
  `dact_recib` datetime DEFAULT NULL,
  `dact_visit` datetime DEFAULT NULL,
  `dact_existen` datetime DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ============================================================================
-- TABLAS DE SOPORTE (visitas, usuarios, etc.)
-- ============================================================================

DROP TABLE IF EXISTS `tvisitas_empresa`;
CREATE TABLE `tvisitas_empresa` (
  `cid_clien` varchar(5) DEFAULT NULL,
  `cid_vende` varchar(5) DEFAULT NULL,
  `dfecha_v` varchar(10) DEFAULT NULL,
  `mobservaci` varchar(200) DEFAULT NULL,
  `cid_status` varchar(1) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

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
  `cid_vende` varchar(5) NOT NULL,
  PRIMARY KEY (`clogin`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ============================================================================
-- DATOS SEMILLA PARA PRUEBAS CRUD
-- ============================================================================

-- Pedido de prueba (para que pedidos.prg lo reciba)
INSERT INTO `tpedidos` (`cid_clien`, `dfecha`, `cid_status`, `cnombre_cl`, `crif_cli`, `cid_vende`, `nmonto_t`, `nmontoiva`)
VALUES ('00001', NOW(), '1', 'CLIENTE SANDBOX TEST', 'J-00000001-0', '00001', 1500.00, 240.00);

INSERT INTO `tdetalles_pedido` (`cid_pedido`, `cid_produc`, `ncantidad`, `nprecio`, `nmonto`)
VALUES ('1', 'PROD-SANDBOX-001', 10.000, 150.000000, 1500.00);

-- Cliente de prueba (para que cxc.prg lo encuentre al leer)
INSERT INTO `tclientes` (`cid_clien`, `cnombre_cl`, `crif_cli`, `cid_vende`, `lactivo`)
VALUES ('00001', 'CLIENTE SANDBOX TEST', 'J-00000001-0', '00001', 1);

-- Vendedor de prueba
INSERT INTO `tvendedores` (`cid_vende`, `cnombrev`, `lactivo`)
VALUES ('00001', 'VENDEDOR SANDBOX', 1);

-- Registro de sincronización
INSERT INTO `tsincronizacion` (`cid_empre`) VALUES ('1');

SELECT 'liderplus_sandbox creada exitosamente' AS resultado;
