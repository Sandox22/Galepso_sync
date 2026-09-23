SET SAFETY OFF
SET EXCLUSIVE OFF
SET EXACT ON
CLEAR
SET EXCLUSIVE OFF
SET DELETED ON
SET DEBUGOUT TO c:\resultado.txt
SET DATE TO JAPAN
CLOSE DATABASES ALL
_CALCVALUE=6023
LOCAL dirdata, dirdatasistema, lcApiBase, lcBody, lcResp, lcJson
dirdata = ALLTRIM(PCUNIDAD) + "\" + pcSistema + "\data\" + pcEmpresa + "\"
dirdatasistema = ALLTRIM(PCUNIDAD) + "\" + pcSistema + "\data\sistema\"
USE SHARED (dirdata + "tproductos.dbf") IN 0
USE SHARED (dirdata + "tproductos_precio.dbf") IN 0
USE SHARED (dirdata + "tproductos_almacen.dbf") IN 0
USE SHARED (dirdata + "tlineas.dbf") IN 0
USE SHARED (dirdata + "tsublineas.dbf") IN 0
USE SHARED (dirdata + "ttallas.dbf") IN 0
USE SHARED (dirdata + "tcontroles.dbf") IN 0
USE SHARED (dirdatasistema + "ttipos_moneda.dbf") IN 0
lcDbc = ALLTRIM(PCUNIDAD) + "\" + pcSistema + "\data\" + pcEmpresa + "\bdemp.dbc"
SET DATABASE TO (lcDbc)

lcApiBase = "https://chocolatesridetti.com/liderplusapirest"

*--- Construir JSON con todas las tablas ---
lcJson = '{"tproductos":['
SELECT tproductos
SET FILTER TO lactivo = .T. AND .NOT. DELETED() AND TRIM(cclasi3)='SI'
GO TOP
lnCount = 0
SCAN
    IF lnCount > 0
        lcJson = lcJson + ','
    ENDIF
    lcJson = lcJson + '{"cid_produc":"' + JS_ESCAPE(tproductos.cid_produc) + '","cdescripci":"' + JS_ESCAPE(tproductos.cdescripci) + '","cdescrialt":"' + JS_ESCAPE(tproductos.cdescrialt) + '","cempaque":"' + JS_ESCAPE(tproductos.cempaque) + '","creferenci":"' + JS_ESCAPE(tproductos.creferenci) + '","cclasi1":"' + JS_ESCAPE(tproductos.cclasi1) + '","cclasi2":"' + JS_ESCAPE(tproductos.cclasi2) + '","cclasi3":"' + JS_ESCAPE(tproductos.cclasi3) + '","cclasi4":"' + JS_ESCAPE(tproductos.cclasi4) + '","ngarantia":' + STR(tproductos.ngarantia,3,0) + ',"gfoto":"' + JS_ESCAPE(tproductos.gfoto) + '","cid_alter":"' + JS_ESCAPE(tproductos.cid_alter) + '","nexisten":' + STR(tproductos.nexisten,12,2) + ',"lactivo":' + IIF(tproductos.lactivo,'1','0') + ',"lapli_iva":' + IIF(tproductos.lapli_iva,'1','0') + '}'
    lnCount = lnCount + 1
ENDSCAN
lcJson = lcJson + '],'

*--- tproductos_precio ---
lcJson = lcJson + '"tproductos_precio":['
SELECT tproductos_precio
SET FILTER TO .NOT. DELETED()
GO TOP
lnCount = 0
SCAN
    IF lnCount > 0
        lcJson = lcJson + ','
    ENDIF
    lcJson = lcJson + '{"cid_produc":"' + JS_ESCAPE(tproductos_precio.cid_produc) + '","ctipo_pre":"' + JS_ESCAPE(tproductos_precio.ctipo_pre) + '","nprecio":' + STR(tproductos_precio.nprecio,8,2) + ',"ctipo_ref":"' + JS_ESCAPE(tproductos_precio.ctipo_ref) + '","nfactor":' + STR(tproductos_precio.nfactor,8,2) + '}'
    lnCount = lnCount + 1
ENDSCAN
lcJson = lcJson + '],'

*--- tproductos_almacen ---
lcJson = lcJson + '"tproductos_almacen":['
SELECT tproductos_almacen
SET FILTER TO .NOT. DELETED() AND ALLTRIM(cid_almace)="02"
GO TOP
lnCount = 0
SCAN
    IF lnCount > 0
        lcJson = lcJson + ','
    ENDIF
    lcJson = lcJson + '{"cid_produc":"' + JS_ESCAPE(tproductos_almacen.cid_produc) + '","cid_almace":"' + JS_ESCAPE(tproductos_almacen.cid_almace) + '","ncantidad":0}'
    lnCount = lnCount + 1
ENDSCAN
lcJson = lcJson + '],'

*--- tlineas ---
lcJson = lcJson + '"tlineas":['
SELECT tlineas
SET FILTER TO .NOT. DELETED()
GO TOP
lnCount = 0
SCAN
    IF lnCount > 0
        lcJson = lcJson + ','
    ENDIF
    lcJson = lcJson + '{"cid_linea":"' + JS_ESCAPE(tlineas.cid_linea) + '","cdescripci":"' + JS_ESCAPE(tlineas.cdescripci) + '"}'
    lnCount = lnCount + 1
ENDSCAN
lcJson = lcJson + '],'

*--- tsublineas ---
lcJson = lcJson + '"tsublineas":['
SELECT tsublineas
SET FILTER TO .NOT. DELETED()
GO TOP
lnCount = 0
SCAN
    IF lnCount > 0
        lcJson = lcJson + ','
    ENDIF
    lcJson = lcJson + '{"cid_sublin":"' + JS_ESCAPE(tsublineas.cid_sublin) + '","cdescripci":"' + JS_ESCAPE(tsublineas.cdescripci) + '"}'
    lnCount = lnCount + 1
ENDSCAN
lcJson = lcJson + '],'

*--- ttallas ---
lcJson = lcJson + '"ttallas":['
SELECT ttallas
SET FILTER TO .NOT. DELETED()
GO TOP
lnCount = 0
SCAN
    IF lnCount > 0
        lcJson = lcJson + ','
    ENDIF
    lcJson = lcJson + '{"cid_talla":"' + JS_ESCAPE(ttallas.cid_talla) + '","cdescripci":"' + JS_ESCAPE(ttallas.cdescripci) + '"}'
    lnCount = lnCount + 1
ENDSCAN
lcJson = lcJson + '],'

*--- tcontroles ---
lcJson = lcJson + '"tcontroles":['
SELECT tcontroles
SET FILTER TO .NOT. DELETED()
GO TOP
lnCount = 0
SCAN
    IF lnCount > 0
        lcJson = lcJson + ','
    ENDIF
    lcJson = lcJson + '{"niva":' + STR(tcontroles.niva,2,2) + '}'
    lnCount = lnCount + 1
ENDSCAN
lcJson = lcJson + '],'

*--- ttipos_moneda ---
lcJson = lcJson + '"ttipos_moneda":['
SELECT ttipos_moneda
SET FILTER TO .NOT. DELETED()
GO TOP
lnCount = 0
SCAN
    IF lnCount > 0
        lcJson = lcJson + ','
    ENDIF
    lcJson = lcJson + '{"cid_tipmo":"' + JS_ESCAPE(ttipos_moneda.cid_tipmo) + '","cdescripci":"' + JS_ESCAPE(ttipos_moneda.cdescripci) + '","nfactor":' + STR(ttipos_moneda.nfactor,8,2) + ',"cabrevia":"' + JS_ESCAPE(ttipos_moneda.cabrevia) + '"}'
    lnCount = lnCount + 1
ENDSCAN
lcJson = lcJson + ']}'

*--- Enviar todo en un solo POST ---
lcResp = ApiCall(lcApiBase + "/sync/inventario", "POST", lcJson)
IF ApiSuccess(lcResp)
    PCESTADOENVIA = PCESTADOENVIA + "Inventario sincronizado con exito " + TTOC(DATETIME())
ELSE
    PCESTADOENVIA = PCESTADOENVIA + "Error sync inventario: " + ApiErrorMsg(lcResp) + " " + TTOC(DATETIME())
ENDIF

SET DATABASE TO
CLOSE DATABASES ALL

FUNCTION JS_ESCAPE
    LPARAMETERS lcStr
    lcStr = STRTRAN(lcStr, '\', '\\')
    lcStr = STRTRAN(lcStr, '"', '\"')
    lcStr = STRTRAN(lcStr, CHR(13), '\n')
    lcStr = STRTRAN(lcStr, CHR(10), '\n')
    RETURN lcStr
ENDFUNC
