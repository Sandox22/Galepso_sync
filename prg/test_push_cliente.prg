* test_push_cliente.prg
* Push aislado de 1 cliente DBF local -> conex_clientes (MySQL remoto)
* Requiere: lcStringConexion definida en PUBLIC por principal.prg
* ----------------------------------------------------------------
SET SAFETY OFF
LOCAL lnH, laErr(1), lnRet, lcSQL

* 1. Abrir tclientes.dbf local
LOCAL dirdata
dirdata = "X:\galepso\data\emp1\"
IF !FILE(dirdata + "tclientes.dbf")
    MESSAGEBOX("No se encontro tclientes.dbf en: " + dirdata, 16, "Error")
    RETURN
ENDIF
USE SHARED (dirdata + "tclientes.dbf") IN 0 ALIAS tclientes

* 2. Tomar primer registro
SELECT tclientes
GO TOP
IF EOF()
    MESSAGEBOX("tclientes.dbf esta vacio.", 16, "Sin datos")
    USE IN tclientes
    RETURN
ENDIF

* 3. Conectar a MySQL remoto
lnH = SQLSTRINGCONNECT(lcStringConexion)
IF lnH < 1
    AERROR(laErr)
    MESSAGEBOX("FALLO conexion:" + CHR(13) + ALLTRIM(laErr[2]), 16, "ODBC Error")
    USE IN tclientes
    RETURN
ENDIF

* 4. Construir y ejecutar INSERT en conex_clientes (esquema CNX_CLT_*)
TEXT TO lcSQL NOSHOW TEXTMERGE
    INSERT INTO conex_clientes (
        CNX_CLT_CODIGO,
        CNX_CLT_NOMBRE,
        CNX_CLT_RIF
    ) VALUES (
        '<<ALLTRIM(tclientes.cid_clien)>>',
        '<<CHRTRAN(ALLTRIM(tclientes.cnombre_cl),"'","''")>>',
        '<<ALLTRIM(tclientes.crif_cli)>>'
    )
    ON DUPLICATE KEY UPDATE
        CNX_CLT_NOMBRE = VALUES(CNX_CLT_NOMBRE),
        CNX_CLT_RIF    = VALUES(CNX_CLT_RIF);
ENDTEXT

lnRet = SQLEXEC(lnH, lcSQL)

* 5. Reportar resultado
IF lnRet > 0
    MESSAGEBOX("EXITO: conex_clientes actualizado." + CHR(13) + ;
               "Cliente: " + ALLTRIM(tclientes.cid_clien) + " - " + ALLTRIM(tclientes.cnombre_cl), ;
               64, "Push OK")
ELSE
    AERROR(laErr)
    MESSAGEBOX("ERROR SQLEXEC: " + CHR(13) + ALLTRIM(laErr[2]), 16, "Push FAIL")
ENDIF

* 6. Cerrar
SQLDISCONNECT(lnH)
USE IN tclientes
SET SAFETY ON
