<link href="../css/tablas.css" rel="stylesheet" type="text/css" />
<?
include("misclases.php");
//inicio la sesión
session_start();
class carrito {
	//atributos de la clase
   	var $num_productos;
   	var $array_id_prod;
	var $array_ref_prod;
   	var $array_nombre_prod;
   	var $array_precio_prod;
	var $array_cant_prod;
	var $total_pedido;
	//constructor. Realiza las tareas de inicializar los objetos cuando se instancian
	//inicializa el numero de productos a 0
	function carrito () {
   		$this->num_productos=0;
		$this->total_pedido=0;
	}	
	function buscar_producto($id)
	{
		$x=0;
		for($x=0;$x<=$this->num_productos;$x++)
		{	
		echo $this->array_id_prod[$x];
			if($this->array_id_prod[$x]==$id && $this->array_id_prod[$x]!=0){
				echo 'entre '.$x.' ';
				return $x;
			}
		}
		return -1;
	}	
	//Introduce un producto en el carrito. Recibe los datos del producto
	//Se encarga de introducir los datos en los arrays del objeto carrito
	//luego aumenta en 1 el numero de productos
	function introduce_producto($id_prod,$nombre_prod,$precio_prod,$cantidad_prod,$ref_prod){
		if ($cantidad_prod>0){
			//$posicion=0;
			$posicion=$this->buscar_producto($id_prod);
			
			if ($posicion==-1){
				$this->array_id_prod[$this->num_productos]=$id_prod;
				$this->array_ref_prod[$this->num_productos]=$ref_prod;
				$this->array_nombre_prod[$this->num_productos]=$nombre_prod;
				$this->array_precio_prod[$this->num_productos]=$precio_prod;
				$this->array_cant_prod[$this->num_productos]=$cantidad_prod;
				$this->num_productos++;
			}
			else
			{				
				//$this->array_precio_prod[$posicion]+=$precio_prod;
				$this->array_cant_prod[$posicion]+=$cantidad_prod;
				//$this->num_productos++;
			}	
	
		}
	}
	//Muestra el contenido del carrito de la compra
	//ademas pone los enlaces para eliminar un producto del carrito
	function imprime_carrito(){
		$configuracion=new configuracion();
		$iva=$configuracion->iva();
		//$valor_iva = mysqli_fetch_object($iva);
		$valor_iva = 12.00;
		//echo 'hhh ';
		//echo $iva;
		$suma = 0;
		echo '<table border=0 cellpadding="3" cellspacing="0" class="tablas">
			  <tr>
			  	<td width="80" bgcolor="#C14717" class="encabezados"><b>C&oacute;digo</b></td>
				<td width="100" bgcolor="#C14717" class="encabezados"><b>Referencia</b></td>
				<td width="300" bgcolor="#C14717" class="encabezados"><b>Nombre producto</b></td>
				<td width="60" bgcolor="#C14717" class="encabezados"><b>Cantidad</b></td>
				<td width="70" bgcolor="#C14717" class="encabezados"><b>Precio</b></td>				
				<td width="70" bgcolor="#C14717" class="encabezados"><b>Monto</b></td>
				<td bgcolor="#C14717" width="100">&nbsp;</td>
			  </tr>';
		for ($i=0;$i<$this->num_productos;$i++){
			if($this->array_id_prod[$i]!=0){
				echo '<tr>';
					if($i%2==0)
					{
					echo '<td style="color:#000000">' . $this->array_id_prod[$i] . '</td>';
					echo '<td style="color:#000000">' . $this->array_ref_prod[$i] . '</td>';
					echo '<td style="color:#000000">' . $this->array_nombre_prod[$i] . '</td>';
					echo '<td style="color:#000000">' . $this->array_cant_prod[$i] . '</td>';
					echo '<td align="right" style="color:#000000">' . number_format($this->array_precio_prod[$i],2) . '</td>';
					echo '<td align="right" style="color:#000000">' . number_format($this->array_cant_prod[$i]*$this->array_precio_prod[$i],2) . '</td>';				
					echo '<td align="right" style="color:#000000"><a href="eliminar_producto.php?linea='.$i.'">Eliminar producto</a></td>';
					}
					else
					{
					echo '<td bgcolor="#f2f2f2" style="color:#000000">' . $this->array_id_prod[$i] . '</td>';
					echo '<td bgcolor="#f2f2f2" style="color:#000000">' . $this->array_ref_prod[$i] . '</td>';
					echo '<td bgcolor="#f2f2f2" style="color:#000000">' . $this->array_nombre_prod[$i] .'</td>';
					echo '<td bgcolor="#f2f2f2" style="color:#000000">' . $this->array_cant_prod[$i] . '</td>';
					echo '<td bgcolor="#f2f2f2" align="right" style="color:#000000">' . number_format($this->array_precio_prod[$i],2) . '</td>';
					echo '<td bgcolor="#f2f2f2" align="right" style="color:#000000">' . number_format($this->array_cant_prod[$i]*$this->array_precio_prod[$i],2) . '</td>';				
					echo '<td align="right" bgcolor="#f2f2f2" style="color:#000000"><a href="eliminar_producto.php?linea='.$i.'">Eliminar producto</a></td>';
					}
				echo '</tr>';
				//echo number_format($this->array_cant_prod[$i]*$this->array_precio_prod[$i],2);
				//echo $suma;
				$suma += $this->array_cant_prod[$i]*$this->array_precio_prod[$i];
				$this->total_pedido =$suma;
			}
		}
		//muestro el total
		echo '  <tr>
								  <td>
								  &nbsp;
								  </td>
							  </tr>
		<tr>
			  <td>&nbsp;</td>
			  <td>&nbsp;</td>
			  <td>&nbsp;</td>
			  <td>&nbsp;</td>
			  <td>&nbsp;</td>
			  <td style="color:#000000"><b>BASE : </b></td>
			  <td align="right" style="color:#000000"><b>'. number_format($suma,2) .'</b></td>	
			  </tr>';
	    //total de iva
		echo '<tr>
			  <td>&nbsp;</td>
			  <td>&nbsp;</td>
			  <td>&nbsp;</td>
			  <td>&nbsp;</td>
			  <td>&nbsp;</td>
			  <td style="color:#000000"><b>IVA ('.$valor_iva.'%): </b></td>
			  <td align="right" style="color:#000000"><b>' . number_format(($suma * $valor_iva)/100,2) . '</b></td>
			  </tr>';
		//total más IVA
		echo '<tr>
			  <td>&nbsp;</td>
			  <td></td>
			  <td>&nbsp;</td>
			  <td>&nbsp;</td>
			  <td>&nbsp;</td>
			  <td style="color:#000000"><b>TOTAL :</b></td>
			  <td align="right" style="color:#000000"><b>' . number_format($suma * (1+($valor_iva/100)),2) . '</b></td>
			  </tr>';
		echo "</table>";
		
	}
	
	//elimina un producto del carrito. recibe la linea del carrito que debe eliminar
	//no lo elimina realmente, simplemente pone a cero el id, para saber que esta en estado retirado
	function elimina_producto($linea){
		$this->total_pedido -= $this->array_cant_prod[$linea]*$this->array_precio_prod[$linea];
		$this->array_id_prod[$linea]=0;
	}	
	function guardar_pedido(){
	
		$configuracion=new configuracion();
		$iva=$configuracion->iva();
		$valor_iva = 12.00;
		
		$pedido=new pedido();	
		 $ped=$pedido->setpedido(trim($_SESSION['sCod_Cliente']),getdate(),'  1','',$_SESSION['sUser'],$_SESSION['sVendedor'],$this->total_pedido*(1+($valor_iva/100)),$valor_iva,$this->total_pedido,($this->total_pedido*$valor_iva)/100);
		
		$insertar=$pedido->incluirpedido($this->array_id_prod,$this->array_precio_prod,$this->array_cant_prod,$this->num_productos);
	    
		
		
	/////////////////////////////////////////////////////7
	
				require_once('class.phpmailer.php');
				//include("class.smtp.php"); // optional, gets called from within class.phpmailer.php if not already loaded
				
				$mail = new PHPMailer(true); // the true param means it will throw exceptions on errors, which we need to catch
				
				$mail->IsSMTP(); // telling the class to use SMTP
				
				try {
				  $mail->SMTPAuth   = true;                  // enable SMTP authentication
				  $mail->SMTPSecure = "ssl";                 // sets the prefix to the servier
				  $mail->Host       = "smtp.gmail.com"; // SMTP server
				 // $mail->SMTPDebug  = 2;                     // enables SMTP debug information (for testing)
				  			 
				  $mail->Host       = "smtp.gmail.com";      // sets GMAIL as the SMTP server
				  $mail->Port       = 465;                   // set the SMTP port for the GMAIL server
				  $mail->Username   = "ventas@felcas.com.ve";  // GMAIL username
				  $mail->Password   = "ventas123";            // GMAIL password
				  $mail->AddAddress('pedrolopez@felcas.com.ve', 'Nuevo Pedido');
				  $mail->AddAddress('eliocastillo@felcas.com.ve', 'Nuevo Pedido');
				  $mail->AddAddress('rosnelespinoza@felcas.com.ve', 'Nuevo Pedido');
				  $mail->SetFrom('ventas@felcas.com.ve', 'Nuevo Pedido');
				  $mail->AddReplyTo('ventas@felcas.com.ve', 'Nuevo Pedido');
				  $mail->Subject = 'Nuevo Pedido';
				  $mail->AltBody = ''; // optional - MsgHTML will create an alternate automatically
				  //$mail->MsgHTML(file_get_contents('contents.html'));
				  //$mail->MsgHTML(file_get_contents('contents.html'));
				  $mail->MsgHTML('Hay un nuevo pedido del cliente '.$_SESSION['sRazonSocial']);
				  //$mail->AddAttachment('images/phpmailer.gif');      // attachment
				  //$mail->AddAttachment('images/phpmailer_mini.gif'); // attachment
				  $mail->Send();
				 // echo "Message Sent OK</p>\n";
				} catch (phpmailerException $e) {
				 // echo $e->errorMessage(); //Pretty error messages from PHPMailer
				} catch (Exception $e) {
				  //echo $e->getMessage(); //Boring error messages from anything else!
				}

	
	
	////////////////////////////////////////////////////
	 
	}
	
} 
//si no esta creado el objeto carrito en la sesion, lo creo
if (!isset($_SESSION["ocarrito"])){
	$_SESSION["ocarrito"] = new carrito();
}
?>
<link href="../css/style.css" rel="stylesheet" type="text/css" />
<link href="../css/styles.css" rel="stylesheet" type="text/css" />
