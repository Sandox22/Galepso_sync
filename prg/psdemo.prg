	* -- Simple sample code to demonstrate sending SMTP email using the PowerShell Send-MailMessage cmdlet. 
	* --
	* -- The example shows HTML format with attachment and inline body signature image via the Mandrill SMTP service.
	* -- To use with Mandrill, you will need at least a free Mandrill account. Add your own SMTP server as appropriate.
	* --
	* -- This is a simple example, there is no checking for the presence of least one recipient, correctly formed email addresses 
	* -- or anything else. You would probably want to write a wrapper class for this in real world usage.
	* --
	* -- The basic Send-EmailMessage PowerShell cmdlet does not handle inline images. Therefore for an HTML message to use an image
	* -- it would need to be hosted in a location resolvable by a the standard img tag.
	* -- <img src='www.myserver.com/images/logo.jpg'>
	* -- 
	* -- Inline images are attached to the message, and can then be referred to using their ContentID 
	* -- <img src='cid:mylogofile'>
	* --
	* -- As mentioned, the standard cmdlet does not provide a mechanism for inline images however an extended version by
	* -- David Wyatt does: https://gallery.technet.microsoft.com/scriptcenter/Send-MailMessage-3a920a6d
	*
	* -- The general flow here is:
	* --   Build a Send-EmailMessage string as appropriate (that could be executed in PowerShell)
	* --   If the SMTP server requires login details, build PowerShell code to return a valid PsCredentials object with
	* --   encrypted credentials.
	* --   Build a PowerShell script file (.PS1) with the credentials code (if appropriate) and the Send-EmailMessage string.
	* --   Run that script using Windows Scripting Host. Presumably ShellExecuteW() could also be used. The important thing 
	* --   is that either way the VFP side must wait for PowerShell to finish, so each email send is a blocking operation.
	* --   This means for bulk sends you would probably want to think about this further. 
	* --
	* --   A sample of a generated PS1 script file where credentials are used (the send-emailmessage line is split for readibility):
	* -- 
	* --   $secpasswd = ConvertTo-SecureString "mymandrillpassword" -AsPlainText -Force
	* --   $mycreds = New-Object System.Management.Automation.PSCredential ("mymandrillusername", $secpasswd)
	* --   send-mailmessage -from "Alan B <alan.bourke@myemail.ie>" -to "Mike Patton <mikepatton@test.com>","Dick Jones <dick.jones@ocp.com>" 
	* --			-cc "Tommy Steele <tommy@blah.com>" -bcc "Saoirse <saoirse@test.com>" -attachments "c:\temp\out.txt","c:\temp\audit.txt" 
	* --            -subject "Test email from PowerShell at 11/11/2015 15:31:42" -body "<html><body>This is a <b>test</b> message.</body></html>"
	* --            -smtpserver smtp.mandrillapp.com -port 587 -priority High -DeliveryNotificationOption OnFailure -bodyashtml -credential $mycreds 
	* -- 
	* --   Full Send-MailMessage documentation: https://technet.microsoft.com/en-us/library/hh849925(v=wps.630).aspx

	Local loPsServer, loMessage

	***** EXAMPLE USAGE START *****
	
	* -- Amend server and sender and recipient details for your own case.
		
	* -- New server definition. 
	loPsServer   			= CreateObject("clsPsSmtpServer")
	loPsServer.cServer		= "your.smtpserver.com"
	loPsServer.cUser		= "your.email@yourdomain.com"
	loPsServer.cPass		= "yourpassword"
	loPsServer.lNeedCreds	= .t.
	loPsServer.nPort		= 587
	loPsServer.lUseSSL 		= .f.

	
	* -- Add a message to the server definition. The cDNO setting indicates
	* -- that a delivery notification will only be sent back on failure.
	loMessage = CreateObject("clsPsMessage")
	loMessage.lIsHtml		= .t.
	loMessage.cFrom 		= "Me <your.email@yourdomain.com>"
	loMessage.cPriority		= "High"		&& Or Normal or Low
	loMessage.cDNO			= "OnFailure"	&& Or None,OnSuccess,Delay,None
	
	* -- Add recipients (normal, CC and BCC)
	loMessage.colRecipients.Add(CreateObject("clsRecipient", "Peter", "peter@test.com"))
	loMessage.colCC.Add(CreateObject("clsRecipient", "Paul", "paul@test.com"))
	loMessage.colBCC.Add(CreateObject("clsRecipient", "Mary", "mary@test.com"))

	* -- Add attachments.
	loMessage.colAttach.Add("c:\temp\out.txt")
	loMessage.colAttach.Add("c:\temp\audit.txt")
	
	* -- Body and subject etc.
	loMessage.cSubject = '"Test email from PowerShell at ' + Ttoc(Datetime()) + '"'
	loMessage.cBody = '"<html><body>This is a <b>test</b> message.</body></html>"'	
	
	* -- Get ready and send.	
	loPsServer.oMessages.Add(loMessage)
	loPsServer.SendMessages()

	***** EXAMPLE USAGE END *****

Return	&& -- Main Prog ends here.


***************************************************************************
*- Name............: clsPsSMTPServer
*- Description.....: Class to encapsulate an SMTP server with settings and
*- ................: associated messages.
***************************************************************************
Define Class clsPsSMTPServer As Custom

	Add Object oMessages As Collection
	
	* -- SMTP server specific items.
	cServer	= ""

	cUser		= ""
	cPass		= ""
	lNeedCreds	= .t.
	cCredCode	= ""
	
	nPort		= 587
	lUseSSL 	= .f.
	
	***************************************************************************
	*- Name............: PrepareCreds
	*- Description.....: Prepares PowerShell code that creates a PsCredentials
	*- ................: object in the generated script.
	***************************************************************************
	Hidden Function PrepareCreds(lcUsername as String, lcPassword as String) 
	Local loCreds
	
		loCreds = CreateObject("clsPsCredentials")
		This.cCredCode = loCreds.GetCredentialsCode(lcUsername, lcPassword)

	Endfunc
	
	***************************************************************************
	*- Name............: PrepareMessages
	*- Description.....: Prepares PowerShell code that creates a PsCredentials
	*- ................: object in the generated script.
	***************************************************************************
	Hidden Function PrepareMessages
	Local loMessage

		* -- Do credentials need to be supplied (probably don't with your own mail server).
		If This.lNeedCreds
			This.PrepareCreds(This.cUser, This.cPass)
		Endif

		* -- Build a PowerShell command for each message.
		For Each loMessage in This.oMessages
			loMessage.PrepareMessage(this)
		Endfor	
				
	EndFunc
	
	***************************************************************************
	*- Name............: SendMessages
	*- Description.....: Prepares and sends any messages that have been added.
	***************************************************************************	
	Function SendMessages
	Local lcTempScript, lcCmd, lcPowerShell, loWsh, loMessage
	
		If this.oMessages.Count > 0
		
			* -- For each message, prepare a PowerShell Send-MailMessage call.
			This.PrepareMessages()

			* -- Output to a PowerShell script and run.
			* -- The format for executing a PS script from CMD.EXE is:
			* --    powershell -ExecutionPolicy RemoteSigned -File "myscript.ps1"
			lcTempScript = Addbs(Sys(2023)) + Sys(3) + ".ps1"
			
			* -- If credentials used, add that code in first.
			lcCmd = Iif(This.lNeedCreds, This.cCredCode, "")
			
			* -- Add the PowerShell commands to send mail.
			For Each loMessage in This.oMessages
				lcCmd = lcCmd + loMessage.cCmd + Chr(13) + Chr(10)
			Endfor	
			
			If StrToFile(lcCmd, lcTempScript) > 0
				lcPowerShell = 'powershell.exe -ExecutionPolicy RemoteSigned -File "' + lcTempScript + '"'
				loWsh = CreateObject("wscript.shell")
				loWsh.Run(lcPowerShell, 0, .T.)		&& -- Execute, hide PowerShell window, and wait for return.
				*Modify File (lcTempScript)
				Delete File (lcTempScript)	
			Endif

		Endif

	Endfunc

EndDefine	

***************************************************************************
*- Name............: clsPsMessage
*- Description.....: Class to encapsulate an email message.
***************************************************************************
Define Class clsPsMessage As Custom


	cFrom 		= ""
	cPriority	= "Normal"		&& Or High or Low
	cDNO		= "OnFailure"	&& Or None,OnSuccess,Delay,None
	cSubject 	= ""
	cBody		= ""
	lIsHtml		= .t.	
	
	* -- Message components.
	Add Object colRecipients As "clsRecipientCollection"
	Add Object colCC As "clsRecipientCollection"	
	Add Object colBCC As "clsRecipientCollection"
	Add Object colAttach As "clsAttachmentCollection"
	
	cCmd			= ""
	
	* -- Builds a Send-EmailMessage string.
	Procedure PrepareMessage(loServer As Object)
	Local lcRecipients, lcCC, lcBCC, lcAttach
	
		lcRecipients = this.colRecipients.Stringify()
		lcCC = this.colCC.Stringify()
		lcBCC = this.colBCC.Stringify()
		lcAttach = this.colAttach.Stringify()

		With this

			* -- Build the PowerShell command.
			.cCmd = ""
		
			.cCmd = .cCmd +  'send-mailmessage ' + '-from "' + .cFrom + '" '
			.cCmd = .cCmd + "-to " + lcRecipients + " "	
			If !Empty(lcCC)
				.cCmd = .cCmd + "-cc " + lcCC + " "
			EndIf
			If !Empty(lcBCC)	
				.cCmd = .cCmd + "-bcc " + lcBCC + " "
			Endif
			If !Empty(lcAttach)	
				.cCmd = .cCmd + "-attachments " + lcAttach + " "
			Endif	
	
			.cCmd = .cCmd + "-subject " + .cSubject + " "
			.cCmd = .cCmd + "-body " + .cBody + " "
			.cCmd = .cCmd + "-smtpserver " + loServer.cServer + " "
			.cCmd = .cCmd + Iif(loServer.lUseSSL, "-UseSSL ", "")
			.cCmd = .cCmd + "-port " + Alltrim(Str(loServer.nPort, 5, 0)) + " "
			.cCmd = .cCmd + "-priority " + .cPriority + " "
			.cCmd = .cCmd + "-DeliveryNotificationOption " + .cDNO + " "
			.cCmd = .cCmd + Iif(.lIsHTML, "-bodyashtml ", "")
		
			If loServer.lNeedCreds
				.cCmd = .cCmd + "-credential $mycreds" + " " 
			endif	
	
		Endwith
	
	EndProc

EndDefine

***************************************************************************
*- Name............: clsRecipient
*- Description.....: Class to encapsulate a recipient.
***************************************************************************
Define Class clsRecipient As Custom
	
	cName 			= ""
	cEmailAddress 	= "" 

	Function Init(lcName As String, lcEmailAddress As String) as Boolean
		This.cName = lcName
		This.cEmailAddress = lcEmailAddress
	Return .t.

EndDefine		

***************************************************************************
*- Name............: clsRecipientCollection
*- Description.....: A recipient collection class with method to return 
*- ................: recipients in correct string format.
***************************************************************************	
Define Class clsRecipientCollection As Collection

	Function Stringify As String
	Local lcRet, loRecip
	
		lcRet = ""
		
		If This.Count > 0
			For each loRecip in This
				lcRet = lcRet + '"' + loRecip.cName + ' <' + loRecip.cEmailAddress + '>",'
			EndFor
			lcRet = Left(lcRet, Len(lcRet)-1) 		&& Strip trailing quotes.
		EndIf
				
	Return lcRet
	

EndDefine

***************************************************************************
*- Name............: clsAttachmentCollection
*- Description.....: An attachment collection class with method to return 
*- ................: attachments in correct string format.
***************************************************************************
Define Class clsAttachmentCollection As Collection

	Function Stringify As String
	Local lcRet, loAttachment
	
		lcRet = ""
		
		If This.Count > 0
			For each loAttachment in This
				lcRet = lcRet + '"' + loAttachment + '",'
			EndFor
			lcRet = Left(lcRet, Len(lcRet)-1)		&& Strip trailing quotes.
		EndIf
				
	Return lcRet
	

EndDefine

***************************************************************************
*- Name............: clsPsCredentials
*- Description.....: Encapsulates the PowerShell PSCredentials class 
*- ................: if username/password need to be supplied.
***************************************************************************
Define Class clsPsCredentials As Custom

	* -- Returns PowerShell script code that will generate a PsCredentials object.
	Function GetCredentialsCode(lcUsername As String, lcPassword As String) As String
	Local lcRet
		
		lcRet = '$secpasswd = ConvertTo-SecureString "' + lcPassword + '" -AsPlainText -Force' + Chr(13) + Chr(10)
		lcRet = lcRet + '$mycreds = New-Object System.Management.Automation.PSCredential ("' + lcUsername + '", $secpasswd)' + Chr(13) + Chr(10)
	
	Return lcRet

EndDefine
