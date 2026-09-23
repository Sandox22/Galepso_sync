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
LOCAL dirdata,cod_empre
cod_empre="1"
dirdata = "c:\galepso\data\emp"+cod_empre+"\"
LOCAL lBanderas as Boolean
lBandera=.f.
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
     SET FILTER TO .NOT. DELETED() .AND. ALLTRIM(cid_almace) = "06"
     GO bottom
		nTotalRegistros=RECNO()
     GOTO TOP
     DO WHILE .NOT. EOF()
          
     		IF !lBandera
				lcSQLcommand="INSERT INTO tproductos_almacen(CID_PRODUC,CID_ALMACE,NEXISTEN,ncosto_inv,ncosto_ulc) VALUES"
				lBandera=.t.
			ENDIF		
				
			TEXT TO lcSQLcommand NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		    ('<<ALLTRIM(tproductos_almacen.cid_produc)>>','<<'4'>>','<<Str(tproductos_almacen.nexisten,5,2)>>','<<Str(tproductos_almacen.ncosto_inv,5,2)>>','<<Str(tproductos_almacen.ncosto_ulc,5,2)>>')
			ENDTEXT	
					
			IF RECNO()=nTotalRegistros then			
			ELSE
			 lcSQLcommand=lcSQLcommand+","
			ENDIF   
     
     
       
          SELECT tproductos_almacen
          SKIP
     ENDDO
     
     CLOSE DATABASES all
     
     **===============TRANSFIRIENDO EXISTENCIAS POR ALMACEN==================
		lcSQLcommand=lcSQLcommand+";"		
		lBandera=.f.
		SQLEXEC(lnhandle,"Delete from tproductos_almacen where TRIM(tproductos_almacen.cid_almace)='4'")			
		SQLEXEC(lnhandle,lcSQLcommand)
		SQLEXEC(lnhandle, "UPDATE tsincronizacion set dact_existen=CONVERT_TZ(NOW(),'-4:30','-8:00') where cid_empre='4'")

		lcSQLcommand=""
		**===============TRANSFIRIENDO EXISTENCIAS POR ALMACEN==================

     SQLDISCONNECT(lnhandle)
     PCESTADOENVIA = "Transferencia de Inventario realizada en forma Exitosa " + TTOC(DATETIME())
ELSE
     PCESTADOENVIA = "No se encontro conexion a internet " + TTOC(DATETIME())
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
