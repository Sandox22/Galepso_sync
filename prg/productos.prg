* productos.prg
* Módulo independiente para sincronización de productos a conex_productos
* Arquitectura Modular - Fase 1

LPARAMETERS tnH
IF TYPE("tnH") <> "N" OR tnH <= 0
    MESSAGEBOX("Se requiere un handle de conexión ODBC válido para sincronizar productos.", 16, "Error")
    RETURN .F.
ENDIF

LOCAL tcMap, lnResult, lcDirData

* Obtener directorio de data
IF TYPE("dirdata") = "U"
    lcDirData = "X:\Galepso\Data\Emp6\"
ELSE
    lcDirData = dirdata
ENDIF

* Apertura defensiva de las tablas
IF !USED("tproductos")
    IF FILE(lcDirData + "tproductos.dbf")
        USE (lcDirData + "tproductos.dbf") SHARED IN 0 ALIAS tproductos
    ELSE
        IF TYPE("PCESTADOENVIA") = "C"
            PCESTADOENVIA = PCESTADOENVIA + "No se encontro tproductos.dbf en " + lcDirData + CHR(13)
        ENDIF
        RETURN .F.
    ENDIF
ENDIF

IF !USED("tproductos_precio")
    IF FILE(lcDirData + "tproductos_precio.dbf")
        USE (lcDirData + "tproductos_precio.dbf") SHARED IN 0 ALIAS tproductos_precio
    ELSE
        IF TYPE("PCESTADOENVIA") = "C"
            PCESTADOENVIA = PCESTADOENVIA + "No se encontro tproductos_precio.dbf en " + lcDirData + CHR(13)
        ENDIF
        RETURN .F.
    ENDIF
ENDIF

* Preparación de cursores
SELECT cid_produc, MAX(nprecio) AS nprecio, MAX(nfactor) AS nfactor ;
FROM tproductos_precio ;
GROUP BY cid_produc ;
INTO CURSOR cur_pre_temp

SELECT cid_produc, CAST(0.00 AS N(12,2)) AS nexisten ;
FROM tproductos ;
INTO CURSOR cur_alm_temp

SELECT p.cid_produc, p.cdescripci, p.cempaque, ;
       NVL(pr.nprecio, 0.00) AS nprecio, NVL(pr.nfactor, 0.00) AS nfactor, ;
       NVL(a.nexisten, 0.00) AS nexisten ;
FROM tproductos p ;
LEFT JOIN cur_pre_temp pr ON p.cid_produc = pr.cid_produc ;
LEFT JOIN cur_alm_temp a ON p.cid_produc = a.cid_produc ;
WHERE ALLTRIM(p.cclasi1) == '05' ;
INTO CURSOR cur_productos READWRITE

tcMap = "cid_produc|CNX_PDT_CODIGO|C,cdescripci|CNX_PDT_DESCRIPCION|C,cempaque|CNX_UND_ID|C,nprecio|CNX_PDT_PRE_PRECIO|N,nexisten|CNX_PDT_EXIS|N,nfactor|CNX_PDT_FACTOR|N"

lnResult = SyncUpsert(tnH, "cur_productos", "conex_productos", tcMap)

* Cierre de cursores temporales
IF USED("cur_pre_temp")
    USE IN cur_pre_temp
ENDIF
IF USED("cur_alm_temp")
    USE IN cur_alm_temp
ENDIF
IF USED("cur_productos")
    USE IN cur_productos
ENDIF

* Control de errores y reporte global
IF TYPE("PCESTADOENVIA") = "C"
    IF lnResult > 0
        IF TYPE("contaenviar") = "N"
            contaenviar = contaenviar + lnResult
        ENDIF
        PCESTADOENVIA = PCESTADOENVIA + "Productos Insertados con exito " + TTOC(DATETIME()) + CHR(13)
    ELSE
        IF lnResult < 0
            PCESTADOENVIA = PCESTADOENVIA + CHR(13) + "Error SyncUpsert Productos " + TTOC(DATETIME())
        ELSE
            PCESTADOENVIA = PCESTADOENVIA + "No se encontraron registros para Productos " + TTOC(DATETIME()) + CHR(13)
        ENDIF
    ENDIF
ENDIF

RETURN lnResult
