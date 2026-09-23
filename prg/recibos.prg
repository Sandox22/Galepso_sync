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
USE SHARED (dirdata + "trecibos_ingreso.dbf") IN 0
USE SHARED (dirdata + "tdetalles_recibo_ingreso.dbf") IN 0
USE SHARED (dirdata + "tclientes.dbf") IN 0


LOCAL lcSQLcommand
	lcSQLcommand=""
	
	LOCAL lBandera AS Boolean
	lBanderas=.f.
	
	LOCAL nTotalRegistros
	nTotalRegistros=0
	
SELECT trecibos_ingreso
SET ORDER TO ix_rec_ing	
**PUBLIC lcStringConexion
**lcStringConexion = "Driver={MySQL ODBC 3.51 Driver};Server=108.179.194.12;Database=felcason_demoliderplus;User=felcason_demo; Password=DeMoLiDeR;Option=3"
LOCAL cmdRecibos
LOCAL cmdDetalles

**LOCAL lcstringcnxlocal AS STRING
**lcstringcnxlocal = "Driver={MySQL ODBC 3.51 Driver};Server=204.12.208.38;Database=autorepu_f1;User=autor_f1; Password=auto@123;Option=3"
*lcstringcnxlocal = "Driver={MySQL ODBC 3.51 Driver};Server=localhost;Database=bdfelcas;User=root; Password=;Option=3"
SQLSETPROP(0, "DispLogin", 3)
lnHandle = SQLSTRINGCONNECT(lcStringConexion)
IF lnHandle > 0

	cmdRecibos=SQLExec(lnHandle,"SELECT cid_reci_i,trecibos_ingreso.cid_clien,tclientes.cnombre_cl,tclientes.crif_cli,dfecha,cid_status,trecibos_ingreso.cid_cobra from trecibos_ingreso inner join tclientes on trecibos_ingreso.cid_clien=tclientes.cid_clien where trim(cid_status)='1' ","ttrecibos")
	
	cmdDetalles=SQLExec(lnHandle,"SELECT trecibos_ingreso.cid_reci_i,cid_docum,nmonto_d,nmonto_h,nsaldo,cdoc_ref,creferenci,cid_tipo_d from trecibos_ingreso inner join tdetalles_recibo_ingreso on trecibos_ingreso.cid_reci_i=tdetalles_recibo_ingreso.creferenci WHERE trim(cid_status)='1'","ttdetalles_recibo_ingreso")
	
	LOCAL lcSqlUpdate,lcRecibos
	lcRecibos=""
	lcSqlUpdate="UPDATE trecibos_ingreso SET cid_status=case cid_reci_i "
	
	SELECT ttrecibos
	GO bottom
	nTotalRegistros=RECNO() 
	GO top
	DO WHILE !EOF()
		SELECT trecibos_ingreso
		SEEK(PADL(ALLTRIM(ttrecibos.cid_reci_i),8))
		IF FOUND()
			SELECT ttrecibos
			SKIP
			loop
		ENDIF
		
			lcRecibos=lcRecibos+ALLTRIM(ttrecibos.cid_reci_i)+","
		
*!*			    append blank
*!*			    replace cid_reci_i with str(ttrecibos.cid_reci_i,8)
*!*			    replace cid_clien with str(val(ttpedidos.cid_clien),5)
*!*			 	replace dfecha with ttpedidos.dfecha		            
*!*			    replace cid_status with "  1"
*!*			    replace ctipo_pre with " 1"
*!*			    replace cid_vende with str(val(ttpedidos.cid_vende),5)
*!*			    replace cnombre_cl with ttpedidos.cnombre_cl
*!*			    replace crif_cli WITH ttpedidos.crif_cli
*!*			    replace nmonto_f with ttpedidos.nmonto_t
*!*			    replace nmontoti with ttpedidos.nmontoiva
*!*			    replace nmonto_t WITH ttpedidos.nmonto_t+ttpedidos.nmontoiva
*!*			           
*!*				    select ttdetalles_pedido
*!*				    set filter to ttdetalles_pedido.cid_pedido == ttpedidos.cid_pedido
*!*				    goto top
*!*				    do while !eof()
*!*				      select tdetalles_pedido
*!*				      append blank
*!*				      replace cid_pedido with str(ttpedidos.cid_pedido,8)
*!*				      replace cid_produc with ttdetalles_pedido.cid_produc
*!*				      replace ncantidad with ttdetalles_pedido.ncantidad
*!*				      replace nprecio with ttdetalles_pedido.nprecio
*!*				      replace nmonto with ttdetalles_pedido.nmonto
*!*				     ** replace ndescuento with ttdetalles_pedido.ndescuento
*!*				      
*!*				    SELECT ttdetalles_pedido
*!*				    SKIP
*!*				    enddo  
		
		
	
	SELECT ttrecibos
	lcSqlUpdate=lcSqlUpdate+ " WHEN "+ALLTRIM(ttrecibos.cid_reci_i)+" then '3'"
	
		IF RECNO()=nTotalRegistros then
		 **lcSQLcommand=lcSQLcommand+""
		ELSE
		 lcSqlUpdate=lcSqlUpdate+""
		ENDIF	
		
	SKIP
	ENDDO 
	
	lcRecibos=SUBSTR(ALLTRIM(lcRecibos),1,LEN(ALLTRIM(lcRecibos))-1)
	
	lcSqlUpdate=lcSqlUpdate+" END WHERE cid_reci_i in("+lcRecibos+")"	
	
	CREATE CURSOR temporal(Comando M)
	SELECT temporal
	APPEND BLANK
	replace Comando WITH lcSqlUpdate
	
	SQLEXEC(lnHandle,lcSqlUpdate)
	
	
	
	SELECT ttrecibos
	GO top
	
	IF !EMPTY(ttrecibos.cid_reci_i)
	correo()
	endif
	**return
	
	
	
	
	 CLOSE DATABASES all
     SQLDISCONNECT(lnhandle)
     PCESTADOENVIA = "Recibos Recibidos con exito " + TTOC(DATETIME())
ELSE
    PCESTADOENVIA = "No se logro establecer conexion a internet recibiendo recibos" + TTOC(DATETIME())		
ENDIF


FUNCTION Correo()
	LOCAL lcTextoCorreo,strHTML
	lcTextoCorreo=""
	strHTML=""

	loCfg = CREATEOBJECT("CDO.Configuration")
	WITH loCfg.Fields
	  .Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "smtp.gmail.com"
	  .Item("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 465
	  .Item("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
	  .Item("http://schemas.microsoft.com/cdo/configuration/sendusername") = "ventasypedidoselite@gmail.com"
	  .Item("http://schemas.microsoft.com/cdo/configuration/sendpassword") = "lbyuvxtvqdqtesek"
	  .Item("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = .T.
	  .Item("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = .T.
	  .Update
	ENDWITH

	loMsg = CREATEOBJECT ("CDO.Message")
	WITH loMsg
	  .Configuration = loCfg
	  .From = "ventasypedidoselite@gmail.com"
	  .To = "ventasypedidoselite@gmail.com"
	  .Subject = "Notificacion de Cobranzas de Caracas recibidas en oficina"
	 
	  
	  strHTML = "<HTML>"
	  strHTML = strHTML + "<HEAD>"
	  strHTML = strHTML + "<BODY>"
	  strHTML = strHTML + "<b> Se han recibido los siguientes Cobros</b><br>"
	  
	  	 
	  
	  SELECT ttrecibos
	  GO top
	  DO while !EOF()
	  	strHTML = strHTML + "<table border=2>"
	   	strHTML = strHTML + "<tr>"
	  	strHTML = strHTML + "<td width=200>Cobranza Nro: "+ALLTRIM(ttrecibos.cid_reci_i)+"</td><td width=600> Cliente: "+ttrecibos.cid_clien+" - "+ALLTRIM(ttrecibos.cnombre_cl)+"</td>"
	  	strHTML = strHTML + "</tr>"
	  	strHTML = strHTML + "</table>"
	  	
	  	strHTML = strHTML + "<table border=2>"
	  	SELECT ttdetalles_recibo_ingreso
	  	SET FILTER TO creferenci=ttrecibos.cid_reci_i
	  	GO TOP 
	  	DO while !EOF()
	  		
	  		strHTML = strHTML + "<tr>"
	  		strHTML = strHTML + "<td width=200>Doc:</td><td width=200> Tipo Doc</td><td width=200> Monto Debe </td><td width=200> Monto Haber </td> <td width=200> Saldo </td>"
	  		strHTML = strHTML + "</tr>"
	   		strHTML = strHTML + "<tr>"
	   		strHTML = strHTML + "<td width=200>"+ALLTRIM(ttdetalles_recibo_ingreso.cid_docum)+"</td><td width=200>"+ttdetalles_recibo_ingreso.cid_tipo_d+"</td><td width=200>"+ALLTRIM(STR(ttdetalles_recibo_ingreso.nmonto_d,12,2))+"</td><td width=200>"+ALLTRIM(STR(ttdetalles_recibo_ingreso.nmonto_h,12,2))+"</td> <td width=200>"+ALLTRIM(STR(ttdetalles_recibo_ingreso.nsaldo,8,2))+"</td>"
	
	  		strHTML = strHTML + "</tr>"
	  		
	  	
	  	SELECT ttdetalles_recibo_ingreso
	  	SKIP
	  	ENDDO
	  	strHTML = strHTML + "</table>"
	  SELECT ttrecibos
	  SKIP
	  ENDDO
	  
	  
	  
	 ** strHTML = strHTML + lcTextoCorreo
	  
	  
	 
	  
	  strHTML = strHTML + "</BODY>"
	  strHTML = strHTML + "</HTML>"
	  .HTMLBody = strHTML
	  .Send()
	ENDWITH
endfunc