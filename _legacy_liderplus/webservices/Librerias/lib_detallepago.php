<link href="../css/tablas.css" rel="stylesheet" type="text/css" />
<?
include("misclases.php");
//inicio la sesión
session_start();
class detalle_pago {
	//atributos de la clase
   //	var $num_productos;
   	//var $array_id_prod;
	//var $array_ref_prod;
   //	var $array_nombre_prod;
   //	var $array_precio_prod;
	//var $array_cant_prod;
	//var $total_pedido;
	
	var $num_facturas;
   	var $array_id_factura;
	var $array_fecha_emis;
   	var $array_fecha_ven;
   	var $array_monto;
	//var $array_cant_fact;
	var $total_pago;
	//constructor. Realiza las tareas de inicializar los objetos cuando se instancian
	//inicializa el numero de productos a 0
	function detalle_pago() {
   		$this->num_facturas=0;
		$this->total_pago=0;
	}	
	function buscar_factura($id)
	{
		$x=0;
		for($x=0;$x<$this->num_facturas;$x++)
		{	
		
			if($this->array_id_factura[$x]==$id && $this->array_id_factura[$x]!=0){
				return $x;
			}
		}
		return -1;
	}	
	//Introduce un producto en el carrito. Recibe los datos del producto
	//Se encarga de introducir los datos en los arrays del objeto carrito
	//luego aumenta en 1 el numero de productos
	function introduce_factura($id_factura,$fecha_emis,$fecha_ven,$monto){
		
		
			//$posicion=0;
			$posicion=$this->buscar_factura($id_factura);
			
			if ($posicion==-1){
				$this->array_id_factura[$this->num_facturas]=$id_factura;
				$this->array_fecha_emis[$this->num_facturas]=$fecha_emis;
				$this->array_fecha_ven[$this->num_facturas]=$fecha_ven;
				$this->array_monto[$this->num_facturas]=$monto;
				//$this->array_cant_prod[$this->num_productos]=$cantidad_prod;
				$this->num_facturas++;
			}
	
	
		
	}
		//Muestra el contenido del carrito de la compra
		//ademas pone los enlaces para eliminar un producto del carrito
		/**
	 * Devuelve la diferencia entre 2 fechas según los parámetros ingresados
	 * @author Gerber Pacheco
	 * @param string $fecha_principal Fecha Principal o Mayor
	 * @param string $fecha_secundaria Fecha Secundaria o Menor
	 * @param string $obtener Tipo de resultado a obtener, puede ser SEGUNDOS, MINUTOS, HORAS, DIAS, SEMANAS
	 * @param boolean $redondear TRUE retorna el valor entero, FALSE retorna con decimales
	 * @return int Diferencia entre fechas
	 */
	
	function imprime_detalle(){
		$configuracion=new configuracion();
		$iva=$configuracion->iva();
		//$valor_iva = mysql_fetch_object($iva);
		$valor_iva = 12.00;
		//echo 'hhh ';
		//echo $iva;
		$suma = 0;
		echo '<table border=1 cellpadding="3" cellspacing="0" class="tablas">';
		for ($i=0;$i<$this->num_facturas;$i++){
			if($this->array_id_factura[$i]!=0){
				//$dias=date("Y-m-d")-$this->array_fecha_ven[$i]-$this->array_fecha_emis[$i];
			
				$fechact=strtotime(date("Y-m-d"));
				
				
				$dias=$fechact-strtotime($this->array_fecha_ven[$i])  ;
			
				
				$diferencia=round($dias/86400);
				echo '<tr>';
					if($i%2==0)
					{
					echo '<td width="80" align="center">' . $this->array_id_factura[$i] . '</td>';
					echo '<td width="102" align="center">' . date("d/m/Y ",strtotime($this->array_fecha_ven[$i]))  . '</td>';
					echo '<td width="139" align="center">' . date("d/m/Y ",strtotime($this->array_fecha_emis[$i])) . '</td>';
					echo '<td width="50" align="center">' . $diferencia . '</td>';
					echo '<td width="132" align="right">' . $this->array_monto[$i] . '</td>';
								
					echo '<td width="91" align="center"><a href="eliminar_factura.php?linea='.$i.'"><img src="images/flechaarriba.png" width="20" height="20" /></a></td>';
					}
					else
					{
					echo '<td bgcolor="#f2f2f2" width="80" align="center">' . $this->array_id_factura[$i] . '</td>';
					echo '<td bgcolor="#f2f2f2" width="102" align="center">' . date("d/m/Y ",strtotime($this->array_fecha_ven[$i]))  . '</td>';
					echo '<td bgcolor="#f2f2f2" width="139" align="center">' . date("d/m/Y ",strtotime($this->array_fecha_emis[$i])) .'</td>';
					//echo '<td bgcolor="#f2f2f2" width="50" align="center">' .  strtotime($this->array_fecha_ven[$i])-strtotime($this->array_fecha_emis[$i]) .'</td>';
					echo '<td bgcolor="#f2f2f2" width="50" align="center">' . $diferencia . '</td>';
					echo '<td bgcolor="#f2f2f2" width="132" align="right">' . $this->array_monto[$i] . '</td>';
											
					echo '<td bgcolor="#f2f2f2" width="91" align="center"><a href="eliminar_factura.php?linea='.$i.'"><img src="images/flechaarriba.png" width="20" height="20" /></a></td>';
					}
				echo '</tr>';
				//echo number_format($this->array_cant_prod[$i]*$this->array_precio_prod[$i],2);
				//echo $suma;
				$suma += $this->array_monto[$i];
				//$this->total_pedido += $this->array_cant_prod[$i]*$this->array_precio_prod[$i];
			}
		}
		//muestro el total
		echo '<tr>
			  <td>&nbsp;</td>
			  <td>&nbsp;</td>
			  <td>&nbsp;</td>
				
			  <td><b>TOTAL A PAGAR : </b></td>
			  <td align="right"><b>'. number_format($suma,2) .'</b></td>
			   <td>&nbsp;</td>	
			  </tr>';
	    //total de iva
		echo '<tr>
			  <td>&nbsp;</td>
			  <td>&nbsp;</td>
			  <td>&nbsp;</td>
			  <td>&nbsp;</td>
			  <td><b> </b></td>
			  <td align="right"><b></b></td>
			  </tr>';
		//total más IVA
		echo '<tr>
			  <td>&nbsp;</td>
			  <td>&nbsp;</td>
			  <td>&nbsp;</td>
			  <td>&nbsp;</td>
			  <td><b> </b></td>
			  <td align="right"><b></b></td>
			  </tr>';
		echo "</table>";
		
	}
	
	//elimina un producto del carrito. recibe la linea del carrito que debe eliminar
	//no lo elimina realmente, simplemente pone a cero el id, para saber que esta en estado retirado
	function elimina_factura($linea){
		$suma -= $this->array_monto[$linea];
		$this->array_id_factura[$linea]=0;
	}	
	function guardar_detalle(){
	
		$configuracion=new configuracion();
		$iva=$configuracion->iva();
		$valor_iva = 12.00;
		
		//$pedido=new pedido();	
		// $ped=$pedido->setpedido(trim($_SESSION['sCod_Cliente']),getdate(),'  1','',$_SESSION['sUser'],$_SESSION['sVendedor'],$this->total_pago*(1+($valor_iva/100)),$valor_iva,$this->total_pago,($this->total_pago*$valor_iva)/100);
		
		//$insertar=$pedido->incluirpedido($this->array_id_prod,$this->array_precio_prod,$this->array_cant_prod,$this->num_productos);
	    
		
		
		//for ($i=0;$i<$this->num_productos;$i++){
				//if($this->array_id_prod[$i]!=0){					
					
				//		$detalle=$pedido->setdetalle_pedido($this->array_id_prod[$i],$this->array_cant_prod[$i],$this->array_precio_prod[$i]);
						//$insertardetalle=$pedido->incluirdetallepedido();
						
					//$total_pedido += number_format($this->array_cant_prod[$i]*$this->array_precio_prod[$i],2);
				//}
		   // }
	 
	}
	
} 
//si no esta creado el objeto carrito en la sesion, lo creo
if (!isset($_SESSION["odetalle_pago"])){
	$_SESSION["odetalle_pago"] = new detalle_pago();
	
}

?>
<link href="../css/style.css" rel="stylesheet" type="text/css" />
<link href="../css/styles.css" rel="stylesheet" type="text/css" />
