PARAMETERS lcbdempresa,lcnegocio

SET SAFETY OFF
SET EXCLUSIVE OFF
SET EXACT ON
CLEAR
SET EXCLUSIVE OFF
SET DELETED ON
SET DEBUGOUT TO c:\resultado.txt
SET CENTURY on
SET DATE TO BRITISH
 
CLOSE DATABASES ALL
LOCAL dirdata
LOCAL cod_empre
cod_empre=lcnegocio
**cod_empre="4"
dirdata = "z:\galepso\data\emp"+lcbdempresa+"\"
**dirdata = "z:\galepso\data\emp1\"

USE SHARED (dirdata + "tfacturas.dbf") IN 0
USE SHARED (dirdata + "tdetalles_pago_factura.dbf") IN 0
USE SHARED (dirdata + "trecibos_ingreso.dbf") IN 0
USE SHARED (dirdata + "tdetalles_pago_recibo.dbf") IN 0
USE SHARED (dirdata + "tgastos.dbf") IN 0

	
LOCAL nTotalRegistros
nTotalRegistros=0

LOCAL lBandera AS Boolean
	lBanderas=.f.
LOCAL lFacturas,lCompras,lDevVen,lDevcom as Boolean
lFacturas=.f.
lCompras=.f.
lDevVen=.f.
lDevCom	=.f.


LOCAL lcSQLcommand AS STRING

LOCAL lcSQLcommandglobal AS STRING

LOCAL lcstringcnxlocal AS STRING
lcstringcnxlocal = "Driver={MySQL ODBC 3.51 Driver};Server=200.74.207.9;Database=bdferreperiquitos;User=ferreperiquitos; Password=101084pedro;Option=3"
SQLSETPROP(0, "DispLogin", 3)
lnhandle = SQLSTRINGCONNECT(lcstringcnxlocal)
IF lnhandle > 0
  
  SELECT tdetalles_pago_factura.CID_FACTU,tdetalles_pago_factura.CID_FORMAP,tdetalles_pago_factura.NMONTO,CID_BANCO,tdetalles_pago_factura.CNUM_REF,tfacturas.MOBSERVACI,tdetalles_pago_factura.CID_TIPO_D,tdetalles_pago_factura.NVUELTO,CCUEN_CLI,CID_CUEN_B,CID_MOV_B,dfecha;
  FROM tfacturas INNER JOIN tdetalles_pago_factura ON tfacturas.cid_factu=tdetalles_pago_factura.cid_factu INTO CURSOR ttdetalles_pago_factura
   
  SELECT tdetalles_pago_recibo.CID_RECI_I,CID_FORMAP,tdetalles_pago_recibo.NMONTO,CID_BANCO,tdetalles_pago_recibo.CNUM_REF,trecibos_ingreso.MOBSERVACI,CCUEN_CLI,CID_CUEN_B,CID_MOV_B,LBANCO,dfecha;
  FROM trecibos_ingreso INNER JOIN tdetalles_pago_recibo ON trecibos_ingreso.cid_reci_i=tdetalles_pago_recibo.cid_reci_i INTO CURSOR ttdetalles_pago_recibo
  
  

		lcSQLcommandglobal = ""
	SELECT ttdetalles_pago_factura
	GO bottom
		nTotalRegistros=RECNO()			
	GO TOP
	DO WHILE !EOF()
				
		IF !lBandera
		lcSQLcommand = "INSERT INTO tdetalles_pago_factura(CID_EMPRE,CID_FACTU,CID_FORMAP,NMONTO,CID_BANCO,CNUM_REF,MOBSERVACI,CID_TIPO_D,NVUELTO,CCUEN_CLI,CID_CUEN_B,CID_MOV_B,DFECHA) VALUES"
		lBandera=.t.
		ENDIF	
		
		TEXT TO lcSQLcommand NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
	    ('<<cod_empre>>','<<ttdetalles_pago_factura.cid_factu>>','<<ttdetalles_pago_factura.CID_FORMAP>>',<<ttdetalles_pago_factura.NMONTO>>,'<<ttdetalles_pago_factura.CID_BANCO>>','<<ttdetalles_pago_factura.CNUM_REF>>','<<ttdetalles_pago_factura.MOBSERVACI>>','<<ttdetalles_pago_factura.CID_TIPO_D>>',<<ttdetalles_pago_factura.NVUELTO>>,'<<ttdetalles_pago_factura.CCUEN_CLI>>','<<ttdetalles_pago_factura.CID_CUEN_B>>','<<ttdetalles_pago_factura.CID_MOV_B>>','<<ttdetalles_pago_factura.dfecha>>')
		ENDTEXT
		
		IF RECNO()=nTotalRegistros then
		 **lcSQLcommand=lcSQLcommand+""
		ELSE
		 lcSQLcommand=lcSQLcommand+","
		ENDIF	
		 	
		SELECT ttdetalles_pago_factura
		SKIP
	ENDDO
	
	lcSQLcommand=lcSQLcommand+";"
	SQLEXEC(lnhandle, "DELETE FROM tdetalles_pago_factura where cid_empre='"+cod_empre+"'")
	SQLEXEC(lnhandle, lcSQLcommand )

    lcSQLcommand =""
	nTotalRegistros=0
	lBandera=.f.	
	
	
	SELECT ttdetalles_pago_recibo
	GO bottom
		nTotalRegistros=RECNO()	
	GO TOP
	DO WHILE !EOF()
	
		
		IF !lBandera 
		lcSQLcommand = "INSERT INTO tdetalles_pago_recibo(CID_EMPRE,CID_RECI_I,CID_FORMAP,NMONTO,CID_BANCO,CNUM_REF,MOBSERVACI,CCUEN_CLI,CID_CUEN_B,CID_MOV_B,LBANCO,dfecha) VALUES"
		lBandera=.t.
		ENDIF

		TEXT TO lcSQLcommand NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
	    ('<<cod_empre>>','<<ttdetalles_pago_recibo.CID_RECI_I>>','<<ttdetalles_pago_recibo.CID_FORMAP>>',<<ttdetalles_pago_recibo.NMONTO>>,'<<ttdetalles_pago_recibo.CID_BANCO>>','<<ttdetalles_pago_recibo.CNUM_REF>>','<<ttdetalles_pago_recibo.MOBSERVACI>>','<<ttdetalles_pago_recibo.CCUEN_CLI>>','<<ttdetalles_pago_recibo.CID_CUEN_B>>','<<ttdetalles_pago_recibo.CID_MOV_B>>',<<IIF(ttdetalles_pago_recibo.LBANCO,1,0)>>,'<<ttdetalles_pago_recibo.dfecha>>')
		ENDTEXT
				
		IF RECNO()=nTotalRegistros then
		 **lcSQLcommand=lcSQLcommand+""
		 ELSE
		 lcSQLcommand=lcSQLcommand+","
		 ENDIF		
		 		
		SELECT ttdetalles_pago_recibo
		SKIP
	ENDDO
	
	lcSQLcommand=lcSQLcommand+";"
	SQLEXEC(lnhandle, "DELETE FROM tdetalles_pago_recibo where cid_empre='"+cod_empre+"'")
	SQLEXEC(lnhandle, lcSQLcommand )


    lcSQLcommand =""
	nTotalRegistros=0
	lBandera=.f.

	SELECT tgastos
	GO bottom
		nTotalRegistros=RECNO()	
	GO TOP
	DO WHILE !EOF()		
	
		IF !lBandera 
			lcSQLcommand = "INSERT INTO tgastos(CID_EMPRE,CID_GASTO,CNRO_FISCAL,CFACTURA,DFECHA,CHORA,CID_CAJA,CID_VENDE,MOBSERVACI,CID_PROVEE,CRIF_PR,CNOMBRE_PR,NBASE,NTASA,NIMPUESTO,NMONTO,DFECHA_ACT,CID_USUARI,CID_TIPO_D,CID_TIPO_A,CID_STATUS,NMONTO_EX) VALUES"
			lBandera=.t.
		ENDIF	

		TEXT TO lcSQLcommand NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
	    ('<<cod_empre>>','<<tgastos.CID_GASTO>>','<<tgastos.CNRO_FISCAL>>','<<tgastos.CFACTURA>>','<<tgastos.DFECHA>>','<<tgastos.CHORA>>','<<tgastos.CID_CAJA>>','<<tgastos.CID_VENDE>>','<<tgastos.MOBSERVACI>>','<<tgastos.CID_PROVEE>>','<<tgastos.CRIF_PR>>','<<tgastos.CNOMBRE_PR>>',<<tgastos.NBASE>>,<<tgastos.NTASA>>,<<tgastos.NIMPUESTO>>,<<tgastos.NMONTO>>,'<<tgastos.DFECHA_ACT>>','<<tgastos.CID_USUARI>>','<<tgastos.CID_TIPO_D>>','<<tgastos.CID_TIPO_A>>','<<tgastos.CID_STATUS>>',<<tgastos.NMONTO_EX>>)
		ENDTEXT
		
		 IF RECNO()=nTotalRegistros then
		 **lcSQLcommand=lcSQLcommand+""
		 ELSE
		 lcSQLcommand=lcSQLcommand+","
		 ENDIF			
		SELECT tgastos
		SKIP
	ENDDO

	
	CLOSE DATABASES ALL
	
	lcSQLcommand=lcSQLcommand+";"
	SQLEXEC(lnhandle, "DELETE FROM tgastos where cid_empre='"+cod_empre+"'")
	SQLEXEC(lnhandle, lcSQLcommand )
	SQLEXEC(lnhandle, "UPDATE tsincronizacion set dact_cajas=CONVERT_TZ(NOW(),'-4:30','-8:00') where cid_empre='"+cod_empre+"'")

    lcSQLcommand =""
	nTotalRegistros=0
	lBandera=.f.

	**CREATE CURSOR temporal( consulta M)
	**SELECT temporal
	**APPEND BLANK
	**replace consulta WITH lcSQLcommand	
	

    SQLDISCONNECT(lnhandle)
    
    PCESTADOENVIA = PCESTADOENVIA+CHR(13)+"Transferencia de Cajas Realizada en forma Exitosa " + TTOC(DATETIME())
ELSE
     PCESTADOENVIA = PCESTADOENVIA+CHR(13)+ "No se encontro conexion a internet " + TTOC(DATETIME())
ENDIF


	
		
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

