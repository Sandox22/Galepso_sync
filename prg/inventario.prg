*** 
*** ReFox MMII (Win) #UK813760  OSCAR VALENTE  LINCKER S.R.L. [VFP60]
***
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
LOCAL dirdata
*dirdata = ALLTRIM(PCUNIDAD) + "\" + pcSistema + "\data\" + pcEmpresa + "\"
dirdata = "X:\Galepso\Data\Emp6\"
LOCAL dirdatasistema
dirdatasistema = ALLTRIM(PCUNIDAD) + "\" + pcSistema + "\data\sistema\"
LOCAL ARRAY laTablasData[6]
laTablasData[1]  = "tclientes.dbf"
laTablasData[2]  = "tproductos.dbf"
laTablasData[3]  = "tproductos_precio.dbf"
laTablasData[4]  = "tdocumentos_cxc.dbf"
laTablasData[5]  = "ttipos_documentocxc.dbf"
laTablasData[6]  = "testados.dbf"

LOCAL i, lcArchivo
FOR i = 1 TO ALEN(laTablasData, 1)
    lcArchivo = dirdata + laTablasData[i]
    IF FILE(lcArchivo)
        USE SHARED (lcArchivo) IN 0
    ENDIF
ENDFOR

*****************************
lcDbc = dirdata + "bdemp.dbc"

IF FILE(lcDbc)
    IF !DBUSED(JUSTSTEM(lcDbc))
        OPEN DATABASE (lcDbc) SHARED
    ENDIF
    SET DATABASE TO (JUSTSTEM(lcDbc))
ENDIF
*****************************

PUBLIC lcStringConexion
*lcStringConexion = "Driver={MySQL ODBC 3.51 Driver};Server=148.66.136.54;Database=liderplus_elite;Uid=liderplus;Pwd=*netwire-0207;Option=3"
lcstringconexion = "Driver={MySQL ODBC 3.51 Driver};Server=159.195.66.171;Port=3459;Database=bdsistemas2;Uid=galexo_kw;Pwd=PGXz&161WW0d;"
SQLSETPROP(0, "DispLogin", 3)
lnhandle = SQLSTRINGCONNECT(lcStringConexion)
IF lnhandle <= 0
    LOCAL ARRAY laError[1]
    AERROR(laError)
    MESSAGEBOX("El servidor rechazó la conexión. Motivo: " + CHR(13) + laError[2], 16, "Fallo ODBC")
ENDIF
IF lnhandle > 0
   **-- Sincronizacion incremental via Helper Dinámico (Productos) --**
   * Carga sync_upsert.prg (ruta dinámica vía SYS(16))
   SET PROCEDURE TO (ADDBS(JUSTPATH(SYS(16))) + "sync_upsert.prg") ADDITIVE

   * --- BLOQUE DE SINCRONIZACIÓN DE ESTADOS ---
   SELECT CID_ESTADO AS edo_codigo, ;
          ALLTRIM(CDESCRIPCI) AS edo_descri, ;
          1 AS edo_activo ;
   FROM testados ;
   INTO CURSOR cur_estados_sync READWRITE

   LOCAL tcMapEdo, lnResEdo
   tcMapEdo = "edo_codigo|CNX_EDOCODIGO|N,edo_descri|CNX_EDODESCRI|C,edo_activo|CNX_EDOACTIVO|N"

   lnResEdo = SyncUpsert(lnhandle, "cur_estados_sync", "conex_estados", tcMapEdo)

   IF lnResEdo > 0
       contaenviar = contaenviar + lnResEdo
       PCESTADOENVIA = PCESTADOENVIA + "Estados Insertados con exito " + TTOC(DATETIME()) + CHR(13)
   ELSE
       IF lnResEdo < 0
           LOCAL ARRAY laErrEdo[1]
           AERROR(laErrEdo)
           LOCAL lcErrMsgEdo
           lcErrMsgEdo = IIF(TYPE("laErrEdo[2]") = "C", laErrEdo[2], "Error SQL Desconocido o código: " + TRANSFORM(lnResEdo))
           PCESTADOENVIA = PCESTADOENVIA + CHR(13) + "ERROR ESTADOS: " + lcErrMsgEdo + CHR(13)
       ELSE
           PCESTADOENVIA = PCESTADOENVIA + "No se encontraron registros para Estados " + TTOC(DATETIME()) + CHR(13)
       ENDIF
   ENDIF
   * -------------------------------------------

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
   INTO CURSOR cur_productos READWRITE

   LOCAL tcMap, lnResult
   tcMap = "cid_produc|CNX_PDT_CODIGO|C,cdescripci|CNX_PDT_DESCRIPCION|C,cempaque|CNX_UND_ID|C,nprecio|CNX_PDT_PRE_PRECIO|N,nexisten|CNX_PDT_EXIS|N,nfactor|CNX_PDT_FACTOR|N"

   lnResult = SyncUpsert(lnhandle, "cur_productos", "conex_productos", tcMap)

   IF lnResult > 0
       contaenviar = contaenviar + lnResult
       PCESTADOENVIA = PCESTADOENVIA + "Productos Insertados con exito " + TTOC(DATETIME()) + CHR(13)
   ELSE
       IF lnResult < 0
           PCESTADOENVIA = PCESTADOENVIA + Chr(13) + "Error SyncUpsert Productos " + Ttoc(Datetime())
       ELSE
           PCESTADOENVIA = PCESTADOENVIA + "No se encontraron registros para Productos " + TTOC(DATETIME()) + CHR(13)
       ENDIF
   ENDIF

   *RETURN  && STOP DE PRUEBA: Detiene la ejecución para pruebas aisladas

     
     * --- BLOQUE DE SINCRONIZACIÓN DE PRECIOS UNIFICADO Y CORREGIDO ---
     SELECT pr.cid_produc, ;
            ICASE(ALLTRIM(pr.ctipo_pre) == "1", "A", ;
                  ALLTRIM(pr.ctipo_pre) == "2", "B", ;
                  ALLTRIM(pr.ctipo_pre) == "3", "C", ;
                  ALLTRIM(pr.ctipo_pre) == "4", "D", "X") AS ctipo_pre, ;
            pr.nprecio, ;
            PADR(IIF(EMPTY(p.cempaque) OR ISNULL(p.cempaque), "UND", ALLTRIM(p.cempaque)), 15) AS cemp_sync ;
     FROM tproductos_precio pr ;
     LEFT JOIN tproductos p ON ALLTRIM(pr.cid_produc) = ALLTRIM(p.cid_produc) ;
     WHERE INLIST(ALLTRIM(pr.ctipo_pre), "1", "2", "3", "4") ;
     INTO CURSOR cur_precios_sync READWRITE
     
     LOCAL tcMapPre, lnResPre
     tcMapPre = "cid_produc|CNX_PRE_PDT_CODIGO|C,ctipo_pre|CNX_PRE_PLT_LISTA|C,nprecio|CNX_PRE_PRECIO|N,cemp_sync|CNX_PRE_UGR_UND_ID|C"
     
     lnResPre = SyncUpsert(lnhandle, "cur_precios_sync", "conex_precios", tcMapPre)
     
     * --- BLOQUE DE DIAGNOSTICO ---
     MESSAGEBOX("Resultado SyncUpsert Precios: " + TRANSFORM(lnResPre), 64, "Debug Forzado")
     * -----------------------------

     IF lnResPre > 0
         contaenviar = contaenviar + lnResPre
         PCESTADOENVIA = PCESTADOENVIA+"Productos Precios I Insertados con exito"+ TTOC(DATETIME())+CHR(13)
     ELSE
         IF lnResPre < 0
             LOCAL ARRAY laErr[1]
             AERROR(laErr)
             LOCAL lcErrMsg
             lcErrMsg = IIF(TYPE("laErr[2]") = "C", laErr[2], "Error SQL Desconocido o código: " + TRANSFORM(lnResPre))
             MESSAGEBOX("Fallo en Precios. MariaDB dice: " + CHR(13) + lcErrMsg, 16, "Error ODBC")
             PCESTADOENVIA = PCESTADOENVIA + CHR(13) + "ERROR PRECIOS: " + lcErrMsg + CHR(13)
         ELSE
             PCESTADOENVIA = PCESTADOENVIA+ "No se encontraron registros para Precios "+TTOC(DATETIME())+CHR(13)
         ENDIF
     ENDIF


     * Bloque de código muerto (stock, líneas, etc.) eliminado por directiva.
		

     CLOSE DATABASES all
     SQLDISCONNECT(lnhandle)
     **PCESTADOENVIA = "Transferencia de Inventarios realizada en forma Exitosa " + TTOC(DATETIME())
ELSE
    PCESTADOENVIA = "No se encontro conexion a internet enviando inventario " + TTOC(DATETIME())		
ENDIF
*CLOSE DATABASES ALL
ENDPROC
*
FUNCTION FECHAGUION
LPARAMETERS fecha
LOCAL valor
valor = ALLTRIM(STR(YEAR(fecha))) +  ;
        "-" +  ;
        ALLTRIM(STR(MONTH(fecha))) +  ;
        "-" +  ;
        ALLTRIM(STR(DAY(fecha)))
RETURN valor
ENDFUNC

