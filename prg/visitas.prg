SET SAFETY OFF
SET EXCLUSIVE OFF
SET EXACT ON
CLEAR
SET EXCLUSIVE OFF
SET DELETED ON
SET DEBUGOUT TO c:\resultado.txt
SET DATE TO british
CLOSE DATABASES ALL
_CALCVALUE=6023
LOCAL dirdata
dirdata = ALLTRIM(PCUNIDAD) + "\" + pcSistema + "\data\" + pcEmpresa + "\"
USE SHARED (dirdata + "tpedidos.dbf") IN 0
USE SHARED (dirdata + "tdetalles_pedido.dbf") IN 0
USE SHARED (dirdata + "tvisitas_empresa.dbf") IN 0
USE SHARED (dirdata + "tdetalles_finca.dbf") IN 0


SELECT tdetalles_finca
SET ORDER TO IX_LOTES   && CID_FINAN+CNOMBREENV+CID_LOTE

LOCAL lcSQLcommand
	lcSQLcommand=""
	
	LOCAL lBandera AS Boolean
	lBanderas=.f.
	
	LOCAL nTotalRegistros
	nTotalRegistros=0
	
SELECT tpedidos
SET ORDER TO ix_pedido	

PUBLIC lcStringConexion
**lcStringConexion = "Driver={MySQL ODBC 3.51 Driver};Server=40.160.61.158;Database=chocola2_liderplus;User=chocola2_liderplus; Password=Liderplus2026*;Option=3"
lcStringConexion = "Driver={MySQL ODBC 3.51 Driver};Server=localhost;Database=liderplus_sandbox;User=root; Password=;Option=3"
**LOCAL lcstringcnxlocal AS STRING
**lcstringcnxlocal = "Driver={MySQL ODBC 3.51 Driver};Server=204.12.208.38;Database=autorepu_f1;User=autor_f1; Password=auto@123;Option=3"
*lcstringcnxlocal = "Driver={MySQL ODBC 3.51 Driver};Server=localhost;Database=bdfelcas;User=root; Password=;Option=3"
SQLSETPROP(0, "DispLogin", 3)
lnhandle = SQLSTRINGCONNECT(lcStringConexion)
IF lnhandle > 0

	cmdVisitas=SQLExec(lnHandle,"SELECT * from tvisitas_empresa inner join tclientes on tvisitas_empresa.cid_clien=tclientes.cid_clien where trim(cid_status)='1'","ttvisitas")
	
	cmdDetalles=SQLExec(lnHandle,"SELECT tvisitas_empresa.cid_visi,cid_produc,ncantidad,nprecio,nmonto,ndescuento from tvisitas_empresa inner join tdetalles_visita on tvisitas_empresa.cid_visi=tdetalles_visita.cid_visi WHERE trim(cid_status)='1'","ttdetalles_visita")
	
	cmdLotes=SQLExec(lnHandle,"SELECT cid_finan, cnombreenv, cid_lote, ncant_se, ncant_fi, ncant_si, ncant_pr, cid_status, mobservaci, dfechacambio, cid_visita, lsincronizado from tdetalles_finca_cambios where cid_status='1'","ttlotes")
	
	
	LOCAL lcSqlUpdate,lcPedidos
	LOCAL lnMontoTotal
	lnMontoTotal=0
	lcVisitas=""
	lcSqlUpdate="UPDATE tvisitas_empresa SET cid_status=case trim(cid_visi) "
	
	SELECT ttvisitas
	GO bottom
	nTotalRegistros=RECNO() 
	GO top
	DO WHILE !EOF()
	lnMontoTotal=0
		SELECT tpedidos
		SEEK(PADL(ALLTRIM(ttvisitas.cid_visi),8))
		IF FOUND()
			SELECT ttvisitas
			SKIP
			loop
		ENDIF
		
			lcVisitas=lcVisitas+PADL(ALLTRIM(ttvisitas.cid_visi),8)+","
		
			SELECT tpedidos
		    append blank
		    replace cid_pedido with PADL(ALLTRIM(ttvisitas.cid_visi),8)
		    replace cid_clien with str(val(NVL(ttvisitas.cid_clien, "0")),5)
		 	replace dfecha with DATE()            
		    replace cid_status with "  1"
		    replace ctipo_pre with " 1"
		    replace cid_vende with str(val(NVL(ttvisitas.cid_vende, "0")),5)
		    replace cnombre_cl with NVL(ttvisitas.cnombre_cl, "")
		    replace crif_cli WITH NVL(ttvisitas.crif_cli, "")
		    
		    SELECT tvisitas_empresa
			APPEND BLANK
			replace cid_clien WITH NVL(ttvisitas.cid_clien, "") IN tvisitas_empresa
			replace cid_vende WITH NVL(ttvisitas.cid_vende, "") IN tvisitas_empresa
			replace dfecha_v WITH DATE() IN tvisitas_empresa
			**replace mobservaci WITH ttvisitas.mobservaci IN tvisitas_empresa
			replace cid_status WITH .t. IN tvisitas_empresa
			replace cid_usuari WITH "LIDERPLUS" IN tvisitas_empresa
			replace dfecha_act WITH DATE() IN tvisitas_empresa
			replace cid_visi WITH NVL(ttvisitas.cid_visi, "") IN tvisitas_empresa
			replace mlotes WITH "" IN tvisitas_empresa 
			replace mrecomen WITH NVL(ttvisitas.mrecomen, "") IN tvisitas_empresa
			SET DATe YMD
			replace dfecha WITH CTOT(CHRTRAN(NVL(ttvisitas.dfecha_v,"-"),"-","/")) IN tvisitas_empresa
			SET DATE british
			replace cnombreenv WITH "" IN tvisitas_empresa
			replace cid_finan WITH NVL(ttvisitas.cid_finan, "") IN tvisitas_empresa
			replace cid_ciclo WITH NVL(ttvisitas.cciclo, "") IN tvisitas_empresa
			replace ctipo_v WITH " 1" IN tvisitas_empresa
		    
		    
		    **replace nmonto_t WITH ttvisitas.nmonto_t+ttvisitas.nmontoiva
		           
			    select ttdetalles_visita
			    set filter to ttdetalles_visita.cid_visi == ttvisitas.cid_visi
			    goto top
			    do while !eof()
			      select tdetalles_pedido
			      append blank
			      replace cid_pedido with PADL(ALLTRIM(ttvisitas.cid_visi),8)
			      replace cid_produc with NVL(ttdetalles_visita.cid_produc, "")
			      replace ncantidad with NVL(ttdetalles_visita.ncantidad, 0)
			      replace nprecio with NVL(ttdetalles_visita.nprecio, 0)
			      replace nmonto with NVL(ttdetalles_visita.nmonto, 0)
			      lnMontoTotal=lnMontoTotal+NVL(ttdetalles_visita.nmonto, 0)
			      replace cid_almace WITH "P1"
			     ** replace ndescuento with ttdetalles_pedido.ndescuento
			      
			    SELECT ttdetalles_visita
			    SKIP
			    enddo 
			    
			     
		
		
	
	SELECT tpedidos
	replace nmonto_t WITH lnMontoTotal IN tpedidos
	lcSqlUpdate=lcSqlUpdate+ " WHEN "+ALLTRIM(ttvisitas.cid_visi)+" then '3'"
	
		IF RECNO()=nTotalRegistros then
		 **lcSQLcommand=lcSQLcommand+""
		ELSE
		 lcSqlUpdate=lcSqlUpdate+""
		ENDIF
		
	SELECT ttvisitas		
		
	SKIP
	ENDDO 
	
	lcVisitas=SUBSTR(ALLTRIM(lcVisitas),1,LEN(ALLTRIM(lcVisitas))-1)
	
	lcSqlUpdate=lcSqlUpdate+" END WHERE TRIM(cid_visi) in("+lcVisitas+")"	
	
	CREATE CURSOR temporal(Comando M)
	SELECT temporal
	APPEND BLANK
	replace Comando WITH lcSqlUpdate
	
	SQLEXEC(lnHandle,lcSqlUpdate)
	
	
	
	lcSqlUpdate=""
	lcSqlUpdate="UPDATE tdetalles_finca_cambios SET cid_status='999' where TRIM(cid_finan) in ("
	
	LOCAL lcLotes
	lcLotes=""
	
	SELECT ttlotes
	GO top
	DO WHILE !EOF()
		SELECT tdetalles_finca
		SEEK(PADL(ALLTRIM(ttlotes.cid_finan),8)+PADR(ALLTRIM(ttlotes.cnombreenv),20)+PADR(ALLTRIM(ttlotes.cid_lote),8))
		IF FOUND()
		replace ncant_se WITH ttlotes.ncant_se IN tdetalles_finca
		replace ncant_si WITH ttlotes.ncant_si IN tdetalles_finca
		replace ncant_pr WITH ttlotes.ncant_pr IN tdetalles_finca
		
		lcLotes=lcLotes+ALLTRIM(ttlotes.cid_finan)+","
		endif
	SELECT ttlotes
	SKIP
	enddo 
	
	lcLotes=lcLotes+SUBSTR(ALLTRIM(lcLotes),1,LEN(ALLTRIM(lcLotes))-1)+")"
	lcSqlUpdate=lcSqlUpdate+lcLotes
	 
	 SELECT temporal
	APPEND BLANK
	replace Comando WITH lcSqlUpdate
	SQLEXEC(lnHandle,lcSqlUpdate)
	 
	SELECT ttvisitas
	GO top
	IF VAL(ttvisitas.cid_visi)>0 then
	correovisitas()
	endif
	**return
	
	
	**return
	
	 CLOSE DATABASES all
     SQLDISCONNECT(lnhandle)
     PCESTADOENVIA = "Visitas Recibidos con exito " + TTOC(DATETIME())
ELSE
    PCESTADOENVIA = "No se encontro conexion a internet " + TTOC(DATETIME())		
ENDIF

FUNCTION FECHAGUION2
LPARAMETERS fecha
LOCAL valor
valor = ALLTRIM(STR(YEAR(fecha))) +  ;
        "/" +  ;
        ALLTRIM(STR(MONTH(fecha))) +  ;
        "/" +  ;
        ALLTRIM(STR(DAY(fecha)))
RETURN valor
ENDFUNC

FUNCTION Correovisitas()
	LOCAL lcTextoCorreo,strHTML
	lcTextoCorreo=""
	strHTML=""

	loCfg = CREATEOBJECT("CDO.Configuration")
	WITH loCfg.Fields
	  .Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "smtp.gmail.com"
	  .Item("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 465
	  .Item("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
	  .Item("http://schemas.microsoft.com/cdo/configuration/sendusername") = "pravenca.cobranza@gmail.com"
	  .Item("http://schemas.microsoft.com/cdo/configuration/sendpassword") = "mhucmtjpvhfsqice"
	  .Item("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = .T.
	  .Item("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = .T.
	  .Update
	ENDWITH

	loMsg = CREATEOBJECT ("CDO.Message")
	WITH loMsg
	  .Configuration = loCfg
	  .From = "pravenca.cobranza@gmail.com"
	  .To = "pedidos.productores@pravenca.com"
	  .Subject = "Notificacion de Visitas Tecnicas recibidas en oficina"
	 
	  
	  strHTML = "<HTML>"
	  strHTML = strHTML + "<HEAD>"
	  strHTML = strHTML + "<BODY>"
	  strHTML = strHTML + "<b> Se han recibido las siguientes visitas tecnicas</b><br>"
	  strHTML = strHTML + "<table border=2>"
	  	 
	  
	  SELECT ttvisitas
	  GO top
	  DO while !EOF()
	   	strHTML = strHTML + "<tr>"
	  	strHTML = strHTML + "<td width=200>Visita Nro: "+ALLTRIM(ttvisitas.cid_visi)+"</td><td width=600> Cliente: "+ttvisitas.cid_clien+" - "+ALLTRIM(ttvisitas.cnombre_cl)+"</td>"
	  	strHTML = strHTML + "</tr>"
	  SKIP
	  ENDDO
	  
	  
	  
	 ** strHTML = strHTML + lcTextoCorreo
	  
	  
	  strHTML = strHTML + "<table>"
	  
	  strHTML = strHTML + "</BODY>"
	  strHTML = strHTML + "</HTML>"
	  .HTMLBody = strHTML
	  .Send()
	ENDWITH
ENDFUNC

