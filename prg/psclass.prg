#INCLUDE  "G:\SHARED\INCLUDE\SYSWIN.H"
***************************************************************************
*- Nombre..........: clsPsSMTPServer
*- Descripcion.....: Clase para encapsular un servidor SMTP con configuracion
*- ................: y mensajes asociados.
***************************************************************************
Define Class clsPsSMTPServer As Custom

	Add Object oMessages As Collection

	* -- Items especificos del servidor SMTP.
	cServer	= ""

	cUser		= ""
	cPass		= ""
	lNeedCreds	= .T.
	cCredCode	= ""

	nPort		= 587
	lUseSSL 	= .F.

	***************************************************************************
	*- Nombre..........: PrepareCreds
	*- Descripcion.....: Prepara el codigo PowerShell creando un objeto PsCredentials
	*- ................: en el script generado.
	***************************************************************************
	Hidden Function PrepareCreds(lcUsername As String, lcPassword As String)
		Local loCreds

		loCreds = Createobject("clsPsCredentials")
		This.cCredCode = loCreds.GetCredentialsCode(lcUsername, lcPassword)

	Endfunc

	***************************************************************************
	*- Nombre..........: PrepareMessages
	*- Descripcion.....: Prepara el codigo PowerShell de cada mensaje utilizando
	*- ................: el object PsCredentials.
	***************************************************************************
	Hidden Function PrepareMessages
		Local loMessage

		* -- Do credentials need to be supplied (probably don't with your own mail server).
		If This.lNeedCreds
			This.PrepareCreds(This.cUser, This.cPass)
		Endif

		* -- Build a PowerShell command for each message.
		For Each loMessage In This.oMessages
			loMessage.PrepareMessage(This)
		Endfor

	Endfunc

	***************************************************************************
	*- Nombre..........: SendMessages
	*- Descripcion.....: Prepara y envia cada mensaje a ser agregado.
	***************************************************************************
	Function SendMessages
		Local lcTempScript, lcCmd, lcPowerShell, loWsh, loMessage, loExe,lcResultado

		If This.oMessages.Count > 0

			* -- Para cada mensaje, prepara una llamada al comando Send-MailMessage de PowerShell.
			Keyboard '{PAUSE 1}' && Se toma un respiro para permitir adjuntar archivos grandes
			This.PrepareMessages()

			* -- Salida a codigo PowerShell y ejecucion.
			* -- El formato para ejecutar un codigo PS desde CMD.EXE es:
			* --    powershell -ExecutionPolicy RemoteSigned -File "micodigo.ps1"
			lcTempScript = Addbs(Sys(2023)) + Sys(3) + ".ps1"

			* -- Si se usan credenciales, se agregan primero en el codigo.
			lcCmd = Iif(This.lNeedCreds, This.cCredCode, "")

			* -- Agrega comandos PowerShell para enviar el mail.
			For Each loMessage In This.oMessages
				lcCmd = lcCmd + loMessage.cCmd + Chr(13) + Chr(10)
			Endfor

			If Strtofile(lcCmd, lcTempScript) > 0
				*Bandera para indicar si se permite editar el powerscript
				If F_BITFLAG(5,"78")
					Modify File (lcTempScript)
				Endif
				lcPowerShell = 'powershell.exe -ExecutionPolicy RemoteSigned -File "' + lcTempScript + '"'
				loWsh = Createobject("wscript.shell")
				If Version(2)=0 Or F_BITFLAG(5,"78")=.F. && or bandera para indicar que se usa Run
					loWsh.Run(lcPowerShell, 0, .T.)		&& -- Execute, hide PowerShell window, and wait for return.
				Else
					loExe=loWsh.Exec(lcPowerShell)
					lcResultado=loExe.StdErr.ReadAll
					If !Empty(lcResultado)
						Messagebox(lcResultado,16,'Atencion')
					Endif
				Endif
				Delete File (lcTempScript)
			Endif

		Endif

	Endfunc

Enddefine

***************************************************************************
*- Nombre..........: clsPsMessage
*- Descripcion.....: Clase to encapsular un mensaje de email.
***************************************************************************
Define Class clsPsMessage As Custom


	cFrom 		= ""
	cPriority	= "Normal"		&& Or High or Low
	cDNO		= "OnFailure"	&& Or None,OnSuccess,Delay,None
	cSubject 	= ""
	cBody		= ""
	lIsHtml		= .T.

	* -- Componentes del mensaje.
	Add Object colRecipients As "clsRecipientCollection"
	Add Object colCC As "clsRecipientCollection"
	Add Object colBCC As "clsRecipientCollection"
	Add Object colAttach As "clsAttachmentCollection"

	cCmd			= ""

	* -- Construccion de la cadena para Send-EmailMessage.
	Procedure PrepareMessage(loServer As Object)
		Local lcRecipients, lcCC, lcBCC, lcAttach

		lcRecipients = This.colRecipients.Stringify()
		lcCC = This.colCC.Stringify()
		lcBCC = This.colBCC.Stringify()
		lcAttach = This.colAttach.Stringify()

		With This

			* -- Construccion del comando PowerShell.
			.cCmd = ""

			.cCmd = .cCmd +  'send-mailmessage ' + '-from "' + .cFrom + '" '
			.cCmd = .cCmd + "-to " + lcRecipients + " "
			If !Empty(lcCC)
				.cCmd = .cCmd + "-cc " + lcCC + " "
			Endif
			If !Empty(lcBCC)
				.cCmd = .cCmd + "-bcc " + lcBCC + " "
			Endif
			If !Empty(lcAttach)
				.cCmd = .cCmd + "-attachments " + lcAttach + " "
			Endif

			.cCmd = .cCmd + '-subject "' + .cSubject + '" '
			.cCmd = .cCmd + "-body " + .cBody + " "
			.cCmd = .cCmd + "-smtpserver " + loServer.cServer + " "
			.cCmd = .cCmd + Iif(loServer.lUseSSL, "-UseSSL ", "")
			.cCmd = .cCmd + "-port " + Alltrim(Str(loServer.nPort, 5, 0)) + " "
			.cCmd = .cCmd + "-priority " + .cPriority + " "
			.cCmd = .cCmd + "-DeliveryNotificationOption " + .cDNO + " "
			.cCmd = .cCmd + Iif(.lIsHtml, "-bodyashtml ", "")

			If loServer.lNeedCreds
				.cCmd = .cCmd + "-credential $mycreds" + " "
			Endif

		Endwith

	Endproc

Enddefine

***************************************************************************
*- Nombre..........: clsRecipient
*- Descripcion.....: Clase para encapsular un recipiente.
***************************************************************************
Define Class clsRecipient As Custom

	cName 			= ""
	cEmailAddress 	= ""

	Function Init(lcName As String, lcEmailAddress As String) As Boolean
		This.cName = lcName
		This.cEmailAddress = lcEmailAddress
		Return .T.

Enddefine

***************************************************************************
*- Nombre..........: clsRecipientCollection
*- Descripcion.....: Clase para una coleccion de recipientes con el metodo para
*- ................: recuperar los recipientes en el formato de cadena correcto.
***************************************************************************
Define Class clsRecipientCollection As Collection

	Function Stringify As String
		Local lcRet, loRecip

		lcRet = ""

		If This.Count > 0
			For Each loRecip In This
				lcRet = lcRet + '"' + loRecip.cName + ' <' + loRecip.cEmailAddress + '>",'
			Endfor
			lcRet = Left(lcRet, Len(lcRet)-1) 		&& Strip trailing quotes.
		Endif

		Return lcRet


Enddefine

***************************************************************************
*- Nombre..........: clsAttachmentCollection
*- Descripcion.....: Clase para una coleccion de adjuntos con el metodo para
*- ................: recuperar los adjuntos en el formato de cadena correcto.
***************************************************************************
Define Class clsAttachmentCollection As Collection

	Function Stringify As String
		Local lcRet, loAttachment

		lcRet = ""

		If This.Count > 0
			For Each loAttachment In This
				lcRet = lcRet + '"' + loAttachment + '",'
			Endfor
			lcRet = Left(lcRet, Len(lcRet)-1)		&& Strip trailing quotes.
		Endif

		Return lcRet


Enddefine

***************************************************************************
*- Nombre..........: clsPsCredentials
*- Descripcion.....: Encapsula la clase de PowerShell PSCredentials
*- ................: si el usuario/clave deben ser reemplazados.
***************************************************************************
Define Class clsPsCredentials As Custom

	* -- Returns PowerShell script code that will generate a PsCredentials object.
	Function GetCredentialsCode(lcUsername As String, lcPassword As String) As String
		Local lcRet

		lcRet = '$secpasswd = ConvertTo-SecureString "' + lcPassword + '" -AsPlainText -Force' + Chr(13) + Chr(10)
		lcRet = lcRet + '$mycreds = New-Object System.Management.Automation.PSCredential ("' + lcUsername + '", $secpasswd)' + Chr(13) + Chr(10)

		Return lcRet

Enddefine

***************************************************************************
*- Nombre..........: clsPsFTPSWinSCP
*- Descripcion.....: Clase para encapsular un servicio FTPS utilizando
*- ................: WinSCP.
***************************************************************************
Define Class clsPsFTPSWinSCP As Custom
	* -- Propiedades disponibles.
	cPathWinSCP   = Firma.PathWinSCP
	cHostName     = Iif(Empty(Firma.BKPSITE),"belenus.servidoraweb.net",Alltrim(Firma.BKPSITE))
	nPortNumber   = Iif(Empty(Firma.BKPSITE),21,Firma.BKPPORT)
	cUsuario      = Iif(Empty(Firma.BKPSITE),"navbkp"+Transform(Val(Firma.id_codfac),'@l 9999')+"@cintegrales.com.ar",Firma.BKPUSER)
	cClave        = Iif(Empty(Firma.BKPSITE),"N4v1r4/2018",Alltrim(Firma.BKPPASS))
	cProxyMethod  = Alltrim(Firma.PXMET)
	cProxyHost    = Alltrim(Firma.PXHOST)
	cProxyPort    = Alltrim(Firma.PXPORT)
	cProxyUsuario = Alltrim(Firma.PXUSER)
	cProxyClave   = Alltrim(Firma.PXCLAVE)
	cCodePs       = ""
	cErrMsg       = ""
	cArchProg     = ""
	cArchEnd      = ""
	***************************************************************************
	*- Nombre..........: PrepareUpSimpleFtp
	*- Descripcion.....: Prepara el archivo de Powershell para ser enviado
	*- ..................por protocolo FTPS.
	***************************************************************************
	Procedure PrepareUpSimpleFtp (lcArchOri As String,lcPathDes As String,llFtps As Logical,oProgreso As Custom)
		lcMsg="Preparando archivo PowerShell "+lcArchOri
		If Type('OL_BOOT')='O' And OL_BOOT.Visible=.T.
			OL_BOOT.vl_sysavance.Caption = Evaluate(OP.M_IDIOMA([lcMsg]))
		Else
			If Type('oProgreso')='O' And !Isnull(oProgreso)
				oProgreso.CbiaLey(lcMsg)
			Else
				Wait Window lcMsg Nowait Noclear
			Endif
		Endif
		TEXT TO lcBloque01Ps TEXTMERGE NOSHOW
		# Carga del ensamblado .NET para WinSCP
		Add-Type -Path "<<ADDBS(This.cPathWinSCP)>>WinSCPnet.dll"

		# Session.FileTransferProgress event handler

		function FileTransferProgress
		{
    		param($e)

			Write-Output ("{0:P0} completo:" -f $e.OverallProgress) | Out-File "<<This.cArchProg>>" -Encoding ASCII
		}
		# Main script

		$script:lastFileName = $Null

		try
		{

			# Configuración de opciones de sesión
			$sessionOptions = New-Object WinSCP.SessionOptions -Property @{
				Protocol = [WinSCP.Protocol]::Ftp
				HostName = "<<This.cHostName>>"
				PortNumber = <<This.nPortNumber>>
				UserName = "<<This.cUsuario>>"
				Password = "<<This.cClave>>"
		ENDTEXT
		If llFtps
			TEXT TO lcBloque01bPs TEXTMERGE NOSHOW
				FtpSecure = [WinSCP.FtpSecure]::Explicit
				TlsHostCertificateFingerprint = "7b:98:a4:21:6d:33:15:ef:41:4c:12:c6:0b:12:de:33:3b:48:6f:c5"
		}
			ENDTEXT
		Else
			TEXT TO lcBloque01bPs TEXTMERGE NOSHOW
		}
			ENDTEXT
		Endif
		TEXT TO lcBloqueProxy TEXTMERGE NOSHOW
		$sessionOptions.AddRawSettings("ProxyMethod", "<<This.cProxyMethod>>")
		$sessionOptions.AddRawSettings("ProxyHost", "<<This.cProxyHost>>")
		$sessionOptions.AddRawSettings("ProxyPort", "<<This.cProxyPort>>")
		$sessionOptions.AddRawSettings("ProxyUsername", "<<This.cProxyUsuario>>")
		$sessionOptions.AddRawSettings("ProxyPassword", "<<This.cProxyClave>>")

		ENDTEXT
		TEXT TO lcBloque02Ps TEXTMERGE NOSHOW PRETEXT 5
		$session = New-Object WinSCP.Session

		try
		{
    		# Will continuously report progress of transfer
    		$session.add_FileTransferProgress( { FileTransferProgress($_) } )

    		# Conexión
    		$session.Open($sessionOptions)

    		# Transferir archivos
    		$session.PutFiles("<<lcArchOri>>", "<<lcPathDes>>*").Check()
		}
		finally
		{
			# Terminate line after the last file (if any)
			if ($script:lastFileName -ne $Null)
			{
				Write-Output ("OK") | Out-File "<<This.cArchEnd>>" -Encoding ASCII
			}

			# Disconnect, clean up
			$session.Dispose()
		}

    		exit 0
		}
		catch
		{
			Write-Output ("Error: $($_.Exception.Message)") | Out-File "<<This.cArchEnd>>" -Encoding ASCII
    		exit 1
		}

		ENDTEXT
		This.cCodePs=lcBloque01Ps+lcBloque01bPs+ CT_CC_CRLF +Iif(Empty(This.cProxyMethod),'',lcBloqueProxy)+ CT_CC_CRLF +lcBloque02Ps
	Endproc
	***************************************************************************
	*- Nombre..........: UpSimpleFtp
	*- Descripcion.....: Prepara y envia un archivo por protocolo FTPS.
	***************************************************************************
	Function UpSimpleFtp (lcArchOri As String,lcPathDes As String,llFtps As Logical,oProgreso As Custom) As Logical
		Local lcTempScript, lcCmd, lcPowerShell, loWsh, loMessage, loExe,;
			lcResultado,lnProgreso,lcErrProc
		#Define WSHEJECUTANDO 0
		#Define WSHFINALIZO 1
		#Define WSHFALLO 2
		lnProgreso=0
		This.cArchProg     = Addbs(Sys(2023)) + Sys(2015) + ".log"
		This.cArchEnd      = Addbs(Sys(2023)) + Sys(2015) + ".log"
		Try
			Local OL_ERROR As Exception
			Local VL_MSG As String
			Local VL_ERROR As Number
			VL_MSG   = CT_CHAR_EMPTY
			VL_ERROR = 0
			If !Empty(lcArchOri) And File(lcArchOri)

				* -- Prepara archivo PS de PowerShell.
				Keyboard '{PAUSE 1}' && Se toma un respiro para permitir adjuntar archivos grandes
				If File(This.cArchProg)
					Erase (This.cArchProg)
				Endif
				If File(This.cArchEnd)
					Erase (This.cArchEnd)
				Endif
				lcMsg="Preparando conexion de FTP"
				If Type('OL_BOOT')='O' And OL_BOOT.Visible=.T.
					OL_BOOT.vl_sysavance.Caption = Evaluate(OP.M_IDIOMA([lcMsg]))
				Else
					If Type('oProgreso')='O' And !Isnull(oProgreso)
						oProgreso.CbiaLey(lcMsg)
					Else
						Wait Window lcMsg Nowait Noclear
					Endif
				Endif
				This.PrepareUpSimpleFtp(lcArchOri,lcPathDes,llFtps,oProgreso)

				* -- Salida a codigo PowerShell y ejecucion.
				* -- El formato para ejecutar un codigo PS desde CMD.EXE es:
				* --    powershell -ExecutionPolicy RemoteSigned -File "micodigo.ps1"
				lcTemp = Addbs(Sys(2023)) + Sys(3)
				lcTempScript = lcTemp + ".ps1"
				lcTempLog = lcTemp + ".log"
				lcCmd = This.cCodePs + Chr(13) + Chr(10)

				lcMsg="Generando script PowerShell en "+lcTempScript
				If Type('OL_BOOT')='O' And OL_BOOT.Visible=.T.
					OL_BOOT.vl_sysavance.Caption = Evaluate(OP.M_IDIOMA([lcMsg]))
				Else
					If Type('oProgreso')='O' And !Isnull(oProgreso)
						oProgreso.CbiaLey(lcMsg)
					Else
						Wait Window lcMsg Nowait Noclear
					Endif
				Endif

				If Strtofile(lcCmd, lcTempScript) > 0
					*Bandera para indicar si se permite editar el powerscript
					If F_BITFLAG(5,"78")
						Modify File (lcTempScript)
					Endif
					lcMsg="Ejecutando el script PowerShell:"+lcTempScript
					If Type('OL_BOOT')='O' And OL_BOOT.Visible=.T.
						OL_BOOT.vl_sysavance.Caption = Evaluate(OP.M_IDIOMA([lcMsg]))
					Else
						If Type('oProgreso')='O' And !Isnull(oProgreso)
							oProgreso.CbiaLey(lcMsg)
						Else
							Wait Window lcMsg Nowait Noclear
						Endif
					Endif
					lcPowerShell = 'powershell.exe -ExecutionPolicy RemoteSigned -File "' + lcTempScript + '"'
					loWsh = Createobject("wscript.shell")
					If Version(2)=0 Or F_BITFLAG(5,"78")=.F. && or bandera para indicar que se usa Run
						loWsh.Run(lcPowerShell, 0, .F.)		&& -- Execute, hide PowerShell window, and wait for return.
					Else
						loExe=loWsh.Exec(lcPowerShell)
					Endif
					lcMsg="Esperando creacion del archivo:"+This.cArchProg
					If Type('OL_BOOT')='O' And OL_BOOT.Visible=.T.
						OL_BOOT.vl_sysavance.Caption = Evaluate(OP.M_IDIOMA([lcMsg]))
					Else
						If Type('oProgreso')='O' And !Isnull(oProgreso)
							oProgreso.CbiaLey(lcMsg)
						Else
							Wait Window lcMsg Nowait Noclear
						Endif
					Endif
					OP.M_Sleep(2)
					Do While lnProgreso<100 And !File(This.cArchEnd)
						Try
							lnProgreso=Val(Getwordnum(Filetostr(This.cArchProg),1,'%'))
						Catch To loError
						Endtry
						lcMsg="Copiando "+Justfname(lcArchOri)+" a "+lcPathDes+" ("+Alltrim(Str(lnProgreso))+"%)"
						If Type('OL_BOOT')='O' And OL_BOOT.Visible=.T.
							OL_BOOT.vl_sysavance.Caption = Evaluate(OP.M_IDIOMA([lcMsg]))
						Else
							If Type('oProgreso')='O' And !Isnull(oProgreso)
								oProgreso.CbiaLey(lcMsg)
							Else
								Wait Window lcMsg Nowait Noclear
							Endif
						Endif
						OP.M_Sleep(1)
					Enddo
					If F_BITFLAG(5,"78")
						OP.M_WRITEFILE(Sys(5)+ Sys(2003) + "\" + "TRACE.LOG", Ttoc(Datetime()) + ": El script utilizado esta en " + lcTempScript + CT_CC_CRLF)
					Else
						Delete File (lcTempScript)
					Endif
				Else
					lcMsg="No pudo generarse el script PowerShell en "+lcTempScript
					If Type('OL_BOOT')='O' And OL_BOOT.Visible=.T.
						OL_BOOT.vl_sysavance.Caption = Evaluate(OP.M_IDIOMA([lcMsg]))
					Else
						If Type('oProgreso')='O' And !Isnull(oProgreso)
							oProgreso.CbiaLey(lcMsg)
						Else
							Wait Window lcMsg Nowait Noclear
						Endif
					Endif
				Endif

			Endif
			If lnProgreso<100
				If File(This.cArchEnd)
					lcErrProc=Alltrim(Filetostr(This.cArchEnd))
					lcMsg="El proceso del script fue interrumpido con el error indicado en: " +;
						This.cArchEnd +"("+lcErrProc+")"
				Else
					lcMsg="El proceso del script fue interrumpido pero no hay registro del error."
				Endif
				OP.M_WRITEFILE(Sys(5)+ Sys(2003) + "\" + "TRACE.LOG", Ttoc(Datetime()) + ": "+lcMsg+ CT_CC_CRLF)
				lcMsg="No pudo generarse el script PowerShell en "+lcTempScript
				If Type('OL_BOOT')='O' And OL_BOOT.Visible=.T.
					OL_BOOT.vl_sysavance.Caption = Evaluate(OP.M_IDIOMA([lcMsg]))
				Else
					If Type('oProgreso')='O' And !Isnull(oProgreso)
						oProgreso.CbiaLey(lcMsg)
					Else
						Wait Window lcMsg Nowait Noclear
					Endif
				Endif
			Endif
		Catch To OL_ERROR
			=OP.M_ADDERROR(OL_ERROR,Alias(),Order())
			VL_ERROR = -1
		Finally
			Do Case
				Case VL_ERROR=-1
					OL_PM = Createobject("EMPTY")
					AddProperty(OL_PM,"ERRORINT",OL_ERROR)
					AddProperty(OL_PM,"TITULO",'')
					AddProperty(OL_PM,"REFERENCIA","")
					Do Form G:\Shared\ENTORNO\F_STERROR With OL_PM
					OL_PM=Null
				Case VL_ERROR>0 And !Empty(VL_MSG)
					VL_IDMSG = OP.M_MB(Evaluate(OP.M_IDIOMA([VL_MSG])),CT_MB_OKONLY + CT_MB_ICONINFORMATION + CT_MB_SYSTEMMODAL,OP.M_IDIOMA(OP.P_SYSNAME))
			Endcase
		Endtry
		Return (lnProgreso=100)
	Endfunc

Enddefine
