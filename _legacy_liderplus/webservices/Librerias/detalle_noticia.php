
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Detalle de Noticia</title>
<link href="/felcas/css/EncabezadoGrande.css" rel="stylesheet" type="text/css" />
<link href="/felcas/css/tablas.css" rel="stylesheet" type="text/css" />
<link href="/felcas/css/EncabezadoNoticias.css" rel="stylesheet" type="text/css" />
<link href="css/styles.css" rel="stylesheet" type="text/css" />
<link href="css/EncabezadoGrande.css" rel="stylesheet" type="text/css" />
</head>

<body>
 <?php 
 include("Librerias/misclases.php");
   $noticia=new noticias();
				 
   $noti=$noticia->detalle_noticia(trim($_GET['id']));
				
  ?>
<table width="776" height="707" border="0" align="center" cellpadding="0" cellspacing="0" class="frame" id="Table_01">
	<tr>
		<td height="200" colspan="10"><object id="FlashID" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="775" height="200">
		  <param name="movie" value="header.swf">
		  <param name="quality" value="high">
		  <param name="wmode" value="opaque">
		  <param name="swfversion" value="7.0.70.0">
		  <!-- Esta etiqueta param indica a los usuarios de Flash Player 6.0 r65 o posterior que descarguen la versión más reciente de Flash Player. Elimínela si no desea que los usuarios vean el mensaje. -->
		  <param name="expressinstall" value="Scripts/expressInstall.swf">
		  <!-- La siguiente etiqueta object es para navegadores distintos de IE. Ocúltela a IE mediante IECC. -->
		  <!--[if !IE]>-->
		  <object type="application/x-shockwave-flash" data="header.swf" width="775" height="200">
		    <!--<![endif]-->
		    <param name="quality" value="high">
		    <param name="wmode" value="opaque">
		    <param name="swfversion" value="7.0.70.0">
		    <param name="expressinstall" value="Scripts/expressInstall.swf">
		    <!-- El navegador muestra el siguiente contenido alternativo para usuarios con Flash Player 6.0 o versiones anteriores. -->
		    <div>
		      <h4>El contenido de esta p&aacute;gina requiere una versi&oacute;n m&aacute;s reciente de Adobe Flash Player.</h4>
		      <p><a href="http://www.adobe.com/go/getflashplayer"><img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Obtener Adobe Flash Player" /></a></p>
	        </div>
		    <!--[if !IE]>-->
	      </object>
		  <!--<![endif]-->
	    </object></td>
		
	</tr>
        <tr>
            <td height="408"  align="center" valign="top" background="./images/__.jpg" style="background-repeat:no-repeat"><table width="643" height="314" border="0" align="center" cellpadding="0" cellspacing="0">
              <tr>
                <td width="643" align="center" valign="top">&nbsp;
                  <table width="633" height="314" border="0" cellpadding="5" cellspacing="0" class="tablas">
                    <?php 
					 if($noti>0){
                  
						for($j=0;$j<count($noti);$j++)
							{
								?>
                    <tr>
                      <td width="522" height="21" align="left" valign="middle" bgcolor="#C14717" class="encabezados"><?php echo $noti[$j][2]; ?></td>
                      <td width="101" align="right" valign="middle" bgcolor="#C14717" class="EncabezadoGrande"><?php  echo date("d/m/Y",strtotime($noti[$j][3])); ?></td>
                    </tr>
                    <tr>
                      <td colspan="2" align="left" valign="top" class="textosvarios"><?php echo $noti[$j][4]; ?></td>
                    </tr>
                    <?php 
						} 
					  }
						
					
					 ?>
                  </table></td>
              </tr>
            </table></td>
		
        </tr>
	
		<td height="57"  align="center" valign="middle" background="./images/MarcasFelcas.png" style="background-repeat:no-repeat"> </td>
		
	</tr>
	<tr>
		<td height="34" align="center" valign="middle" class="EncabezadoGrande" background="./images/PiePagina.png"><table width="763" height="38" border="0" cellpadding="0" cellspacing="0">
		  <tr>
		    <td width="763" height="38" style="background-repeat:no-repeat">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="index.php"><span class="EncabezadoGrande">INICIO</span></a> | <a href="nosotros.php"><span class="EncabezadoGrande">NOSOTROS</span></a> |<a href="productos.php"><span class="EncabezadoGrande">PRODUCTOS</span></a> |<a href="descargas.php"><span class="EncabezadoGrande"> DESCARGAS</span></a> |<a href="contactos.php"><span class="EncabezadoGrande"> CONT&Aacute;CTENOS</span></a><br>
	        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="encabezados">&nbsp;Todos los Derechos Reservados &copy; Distribuidora Felcas C.A.</span></td>
	      </tr>
      </table></td>
		
	</tr>
	<tr>
		
	</tr>
</table>
</body>
</html>

