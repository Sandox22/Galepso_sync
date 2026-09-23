* =============================================================
* crear_dbfs_sandbox.prg
* Genera las tablas DBF locales requeridas por el sincronizador
* Convención de nombres: Galepso usa prefijo "t" en todas las tablas
* Ruta destino: C\galepso\data\emp1\
* =============================================================
CLOSE DATABASES ALL
SET SAFETY OFF

LOCAL dirdata
dirdata = ALLTRIM("X:") + "\Galepso\data\emp1\"

* Verificar que la ruta existe
IF !DIRECTORY(dirdata)
    MESSAGEBOX("Ruta no encontrada: " + dirdata, 16, "Error")
    RETURN
ENDIF

* ------------------------------------------------------------------
* 1. TCLIENTES.DBF  (leído por cxc.prg y pedidos.prg)
* ------------------------------------------------------------------
IF FILE(dirdata + "tclientes.dbf")
    DELETE FILE (dirdata + "tclientes.dbf")
    IF FILE(dirdata + "tclientes.fpt")
        DELETE FILE (dirdata + "tclientes.fpt")
    ENDIF
ENDIF

CREATE TABLE (dirdata + "tclientes") ( ;
    cid_clien   C(5),   ;
    cnombre_cl  C(100), ;
    cdir_cli1   C(60),  ;
    cdir_cli2   C(60),  ;
    cid_ciudac  C(5),   ;
    cid_estadc  C(5),   ;
    ctele_cli   C(20),  ;
    ccelu_cli   C(20),  ;
    crif_cli    C(20),  ;
    ce_mail     C(60),  ;
    cid_vende   C(5),   ;
    nlimite_c   N(10,2),;
    nsaldo_a    N(10,2),;
    cid_tipo_p  C(5),   ;
    lactivo     L       ;
)

INSERT INTO tclientes (cid_clien, cnombre_cl, crif_cli, lactivo) ;
    VALUES ("00001", "CLIENTE TEST DBF", "J-12345678-9", .T.)

USE

* ------------------------------------------------------------------
* 2. TPEDIDOS.DBF  (leído por pedidos.prg)
* ------------------------------------------------------------------
IF FILE(dirdata + "tpedidos.dbf")
    DELETE FILE (dirdata + "tpedidos.dbf")
ENDIF

CREATE TABLE (dirdata + "tpedidos") ( ;
    cid_pedido  C(8),   ;
    cid_clien   C(5),   ;
    cnombre_cl  C(100), ;
    crif_cli    C(20),  ;
    cid_vende   C(5),   ;
    dfecha      D,      ;
    cid_status  C(5),   ;
    ctipo_pre   C(3),   ;
    nmonto_t    N(12,2),;
    nmontoiva   N(12,2) ;
)

INDEX ON cid_pedido TAG ix_pedido

INSERT INTO tpedidos (cid_pedido, cid_clien, cnombre_cl, cid_status, dfecha) ;
    VALUES ("00000001", "00001", "CLIENTE TEST DBF", "  1", DATE())

USE

* ------------------------------------------------------------------
* 3. TDETALLES_PEDIDO.DBF  (leído por pedidos.prg)
* ------------------------------------------------------------------
IF FILE(dirdata + "tdetalles_pedido.dbf")
    DELETE FILE (dirdata + "tdetalles_pedido.dbf")
ENDIF

CREATE TABLE (dirdata + "tdetalles_pedido") ( ;
    cid_pedido  C(8),   ;
    cid_produc  C(10),  ;
    ncantidad   N(10,2),;
    nentregado  N(10,2),;
    nprecio     N(12,2),;
    nmonto      N(12,2),;
    ndescuento  N(8,2)  ;
)

INSERT INTO tdetalles_pedido (cid_pedido, cid_produc, ncantidad, nprecio, nmonto) ;
    VALUES ("00000001", "PROD001", 1, 100.00, 100.00)

USE

* ------------------------------------------------------------------
* 4. TFACTURAS.DBF  (leído por cxc.prg)
* ------------------------------------------------------------------
IF FILE(dirdata + "tfacturas.dbf")
    DELETE FILE (dirdata + "tfacturas.dbf")
    IF FILE(dirdata + "tfacturas.fpt")
        DELETE FILE (dirdata + "tfacturas.fpt")
    ENDIF
ENDIF

CREATE TABLE (dirdata + "tfacturas") ( ;
    cid_factu   C(10),  ;
    ctipo_fac   C(5),   ;
    cid_clien   C(5),   ;
    cnombre_cl  C(100), ;
    crif_cli    C(20),  ;
    cid_vende   C(5),   ;
    dfecha      D,      ;
    cid_caja    C(5),   ;
    dfecha_ven  D,      ;
    cid_pedido  C(8),   ;
    cid_tipo_p  C(5),   ;
    mobservaci  M,      ;
    cid_status  C(5),   ;
    ntasa_iva   N(5,2), ;
    nmontoti    N(18,2),;
    nbase_iva   N(18,2),;
    nmontotal   N(18,2),;
    nmontoiva   N(18,2) ;
)

INSERT INTO tfacturas (cid_factu, cid_clien, cnombre_cl, dfecha, dfecha_ven, cid_status, nmontotal) ;
    VALUES ("FAC0000001", "00001", "CLIENTE TEST DBF", DATE(), DATE()+30, "999", 100.00)

USE

* ------------------------------------------------------------------
* 5. TDETALLES_FACTURA.DBF  (leído por cxc.prg)
* ------------------------------------------------------------------
IF FILE(dirdata + "tdetalles_factura.dbf")
    DELETE FILE (dirdata + "tdetalles_factura.dbf")
    IF FILE(dirdata + "tdetalles_factura.fpt")
        DELETE FILE (dirdata + "tdetalles_factura.fpt")
    ENDIF
ENDIF

CREATE TABLE (dirdata + "tdetalles_factura") ( ;
    cid_factu   C(10),  ;
    cid_produc  C(10),  ;
    ncantidad   N(10,2),;
    nprecio     N(12,2),;
    nmonto      N(12,2),;
    ndescuento  N(8,2), ;
    cid_docum   C(5),   ;
    mobservaci  M,      ;
    cid_almace  C(5)    ;
)

INSERT INTO tdetalles_factura (cid_factu, cid_produc, ncantidad, nprecio, nmonto, cid_almace) ;
    VALUES ("FAC0000001", "PROD001", 1, 100.00, 100.00, "C1")

USE

* ------------------------------------------------------------------
* 6. TDOCUMENTOS_CXC.DBF  (leído por cxc.prg)
* ------------------------------------------------------------------
IF FILE(dirdata + "tdocumentos_cxc.dbf")
    DELETE FILE (dirdata + "tdocumentos_cxc.dbf")
ENDIF

CREATE TABLE (dirdata + "tdocumentos_cxc") ( ;
    cid_doccxc  C(10),  ;
    cid_tipo_d  C(5),   ;
    cid_clien   C(5),   ;
    dfecha      D,      ;
    dfecha_ven  D,      ;
    nsaldo      N(12,2),;
    cid_vende   C(5),   ;
    nimpuesto   N(10,2),;
    nbase       N(10,2),;
    ntasa_iva   N(10,2),;
    cnrofiscal  C(20),  ;
    cserie      C(10),  ;
    ccomprob_f  C(20),  ;
    nmonto_d    N(12,2),;
    nmonto_h    N(12,2),;
    nfactor     N(12,6) ;
)

USE

* ------------------------------------------------------------------
* 7. TTIPOS_DOCUMENTOCXC.DBF  (leído por cxc.prg)
* ------------------------------------------------------------------
IF FILE(dirdata + "ttipos_documentocxc.dbf")
    DELETE FILE (dirdata + "ttipos_documentocxc.dbf")
ENDIF

CREATE TABLE (dirdata + "ttipos_documentocxc") ( ;
    cid_tipod   C(5),   ;
    cdescripci  C(60),  ;
    lsuma       L,      ;
    cabreviado  C(10)   ;
)

USE

* ------------------------------------------------------------------
* 8. TVENDEDORES.DBF  (leído por cxc.prg)
* ------------------------------------------------------------------
IF FILE(dirdata + "tvendedores.dbf")
    DELETE FILE (dirdata + "tvendedores.dbf")
ENDIF

CREATE TABLE (dirdata + "tvendedores") ( ;
    cid_vende   C(5),   ;
    cnombrev    C(60),  ;
    lactivo     L       ;
)

INSERT INTO tvendedores (cid_vende, cnombrev, lactivo) ;
    VALUES ("00001", "VENDEDOR TEST", .T.)

USE

* ------------------------------------------------------------------
* 9. TDEVOLUCIONES_VENTA.DBF  (leído por cxc.prg)
* ------------------------------------------------------------------
IF FILE(dirdata + "tdevoluciones_venta.dbf")
    DELETE FILE (dirdata + "tdevoluciones_venta.dbf")
ENDIF

CREATE TABLE (dirdata + "tdevoluciones_venta") ( ;
    cid_dev_v   C(10),  ;
    cid_factu   C(10),  ;
    dfecha      D       ;
)

INDEX ON cid_factu TAG ix_factura

USE

* ------------------------------------------------------------------
* 10. TDETALLES_DEVOLUCION_VENTA.DBF  (leído por cxc.prg)
* ------------------------------------------------------------------
IF FILE(dirdata + "tdetalles_devolucion_venta.dbf")
    DELETE FILE (dirdata + "tdetalles_devolucion_venta.dbf")
ENDIF

CREATE TABLE (dirdata + "tdetalles_devolucion_venta") ( ;
    cid_dev_v   C(10),  ;
    cid_produc  C(10),  ;
    ncantidad   N(10,2) ;
)

INDEX ON cid_dev_v + cid_produc TAG IX_DETDEVV

USE

* ------------------------------------------------------------------
* 11. TABLAS DUMMY requeridas por inventario.prg (emp1)
* ------------------------------------------------------------------
LOCAL lcTablasDummy(10), lnT
lcTablasDummy(1)  = "tlineas"
lcTablasDummy(2)  = "tsublineas"
lcTablasDummy(3)  = "tproductos_almacen"
lcTablasDummy(4)  = "tvendedores_almacen"
lcTablasDummy(5)  = "ttallas"
lcTablasDummy(6)  = "tcontroles"
lcTablasDummy(7)  = "tequipos"
lcTablasDummy(8)  = "tdetalles_equipo"
lcTablasDummy(9)  = "tnotas_entrega"
lcTablasDummy(10) = "tdetalles_notas_entrega"

FOR lnT = 1 TO 10
    IF FILE(dirdata + lcTablasDummy(lnT) + ".dbf")
        DELETE FILE (dirdata + lcTablasDummy(lnT) + ".dbf")
    ENDIF
    CREATE TABLE (dirdata + lcTablasDummy(lnT)) (dummy C(1))
    USE
ENDFOR

* ------------------------------------------------------------------
* 12. TPRODUCTOS.DBF  (leído por inventario.prg, tabla principal)
* ------------------------------------------------------------------
IF FILE(dirdata + "tproductos.dbf")
    DELETE FILE (dirdata + "tproductos.dbf")
    IF FILE(dirdata + "tproductos.fpt")
        DELETE FILE (dirdata + "tproductos.fpt")
    ENDIF
ENDIF

CREATE TABLE (dirdata + "tproductos") ( ;
    cid_produc  C(10),  ;
    cdescripci  C(100), ;
    cdescrialt  C(100), ;
    cempaque    C(20),  ;
    creferenci  C(20),  ;
    cclasi1     C(5),   ;
    cclasi2     C(5),   ;
    cclasi3     C(5),   ;
    cclasi4     C(5),   ;
    ngarantia   N(3,0), ;
    gfoto       G,      ;
    cid_alter   C(10),  ;
    nexisten    N(12,2),;
    lactivo     L,      ;
    lapli_iva   L       ;
)

INSERT INTO tproductos ( ;
    cid_produc, cdescripci, cdescrialt, cclasi1, nexisten, lactivo, lapli_iva) ;
    VALUES ("PROD001", "PRODUCTO TEST DBF", "DESC ALT TEST", "2", 10.00, .T., .T.)

USE

* ------------------------------------------------------------------
* 13. TPRODUCTOS_PRECIO.DBF  (leído por inventario.prg)
* ------------------------------------------------------------------
IF FILE(dirdata + "tproductos_precio.dbf")
    DELETE FILE (dirdata + "tproductos_precio.dbf")
ENDIF

CREATE TABLE (dirdata + "tproductos_precio") ( ;
    cid_produc  C(10),  ;
    ctipo_pre   C(3),   ;
    nprecio     N(12,2),;
    ctipo_ref   C(5),   ;
    nfactor     N(8,2)  ;
)

INSERT INTO tproductos_precio (cid_produc, ctipo_pre, nprecio, ctipo_ref, nfactor) ;
    VALUES ("PROD001", "1", 100.00, "BS", 1.00)

USE

* ------------------------------------------------------------------
* 14. TTIPOS_MONEDA.DBF requerida por inventario.prg (dirdatasistema)
* ------------------------------------------------------------------
LOCAL dirdatasistema
dirdatasistema = ALLTRIM("X:") + "\Galepso\data\sistema\"

IF !DIRECTORY(dirdatasistema)
    MD (dirdatasistema)
ENDIF

IF FILE(dirdatasistema + "ttipos_moneda.dbf")
    DELETE FILE (dirdatasistema + "ttipos_moneda.dbf")
ENDIF

CREATE TABLE (dirdatasistema + "ttipos_moneda") ( ;
    cid_tipmo   C(5),   ;
    cdescripci  C(60),  ;
    nfactor     N(12,6),;
    cabrevia    C(10)   ;
)

INSERT INTO ttipos_moneda (cid_tipmo, cdescripci, nfactor, cabrevia) ;
    VALUES ("BS", "BOLIVAR SOBERANO", 1.000000, "Bs.")

USE

* ------------------------------------------------------------------
* FIN
* ------------------------------------------------------------------
CLOSE DATABASES ALL
SET SAFETY ON

MESSAGEBOX( ;
    "Sandbox completo:" + CHR(13) + ;
    "- 12 tablas en: " + dirdata + CHR(13) + ;
    "- 2 tablas en:  " + dirdatasistema, ;
    64, "Sandbox DBF OK")
