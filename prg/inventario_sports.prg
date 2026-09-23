*** 
*** ReFox X  #UK933629  MANRIQUE ORELLANA  MANSOFT SYSTEMS [VFP80]
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
LOCAL dirdata
dirdata = "c:\galepso\data\emp1\"
USE SHARED (dirdata +  ;
    "tclientes.dbf") IN 0
USE SHARED (dirdata +  ;
    "tproductos.dbf") IN 0
USE SHARED (dirdata +  ;
    "tproductos_precio.dbf") IN  ;
    0
USE SHARED (dirdata +  ;
    "tdocumentos_cxc.dbf") IN 0
USE SHARED (dirdata +  ;
    "ttipos_documentocxc.dbf") IN  ;
    0
USE SHARED (dirdata +  ;
    "tlineas.dbf") IN 0
USE SHARED (dirdata +  ;
    "tsublineas.dbf") IN 0
USE SHARED (dirdata +  ;
    "tproductos_almacen.dbf") IN  ;
    0
USE SHARED (dirdata +  ;
    "tcolores.dbf") IN 0
USE SHARED (dirdata +  ;
    "tcontroles.dbf") IN 0
SET DATABASE TO c:\galepso\data\emp1\bdemp.dbc
LOCAL lcstringcnxlocal AS STRING
lcstringcnxlocal = "Driver={MySQL ODBC 3.51 Driver};Server=200.74.207.9;Database=bdferreperiquitos;User=ferreperiquitos; Password=101084pedro;Option=3"
SQLSETPROP(0, "DispLogin", 3)
lnhandle = SQLSTRINGCONNECT(lcstringcnxlocal)
IF lnhandle > 0
     SET DATABASE TO c:\galepso\data\emp1\bdemp.dbc
     SELECT tproductos_almacen
     SQLEXEC(lnhandle,  ;
            "delete from tproductos_almacen where TRIM(tproductos_almacen.cid_almace)='4'",  ;
            "ttproductos_almacen")
     SQLEXEC(lnhandle,  ;
            "select * from tproductos_almacen",  ;
            "ttproductos_almacen")
     CURSORSETPROP("Buffering", 5,  ;
                  "ttproductos_almacen")
     CURSORSETPROP("Tables",  ;
                  "bdfelcas.dbo.tproductos_almacen",  ;
                  "ttproductos_almacen")
     CURSORSETPROP("KeyFieldList",  ;
                  "cid_produc")
     CURSORSETPROP("UpdateNameList",  ;
                  "cid_produc bdfelcas.dbo.tproductos_almacen.cid_produc" ;
                  )
     CURSORSETPROP("UpdatableFieldList",  ;
                  "cid_produc")
     CURSORSETPROP("SendUpdates",  ;
                  .T.)
     SELECT tproductos_almacen
     SET FILTER TO ;
.NOT. DELETED();
.AND. ALLTRIM(cid_almace) = "06"
     GOTO TOP
     DO WHILE  .NOT. EOF()
          strsql = "INSERT INTO tproductos_almacen(CID_PRODUC,CID_ALMACE,NEXISTEN)"
          strsql = strsql +  ;
                   " values('" +  ;
                   ALLTRIM(tproductos_almacen.cid_produc) +  ;
                   "','4','" +  ;
                   STR(tproductos_almacen.nexisten,  ;
                   5, 2) + "')"
          SQLEXEC(lnhandle,  ;
                 strsql,  ;
                 "ttproductos_almacen")
          SELECT tproductos_almacen
          SKIP
     ENDDO
     SQLDISCONNECT(lnhandle)
ELSE
     AERROR(laerr)
     MESSAGEBOX( ;
               "No se pudo conectar al servidor. Error: " +  ;
               CHR(13) +  ;
               laerr(2))
ENDIF
ENDPROC
**
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
**
*** 
*** ReFox - retrace your steps ... 
***
