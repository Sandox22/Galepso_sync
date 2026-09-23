<?PHP
include("json.php");
//include("json2.php");
//--------------------------------------------------------------------
//       Clase control
//--------------------------------------------------------------------
  class control
  { 
	var $conexion;
	var $iva;
//--------------------------------------------------------------------
//       Funci�n Abrir conexi�n 
//--------------------------------------------------------------------
  function abrir_bd() 
  {
		//error_reporting(E_ALL);
	  //OJO ESTA LINEA QUE VIENE NO ME PERMITIA QUE CUANDO EL CURSOR ESTUVIERA VACIO SE MOSTRARA EL JSON VACIO SINO QUE LO BORRABA TOTALMENTE MOSCA
	  //ini_set('display_errors', '1');
	  
	   //ini_set('memory_limit', '1024M');
	   ini_set('memory_limit', '-1');
	   ini_set('max_execution_time', 300); //300 seconds = 5 minutes
	  // echo ini_get("memory_limit")."\n";
	  setlocale(LC_MONETARY, 'es_VE');
	setlocale(LC_TIME, 'es_VE'); # Localiza en espa�ol es_Venezuela
    date_default_timezone_set('America/Caracas');
	  $iva=12;
	  //107.161.189.226
  $this->conexion = @mysqli_connect("138.128.182.50","felcas","Felc@s123*");
// $this->conexion = @mysqli_connect("localhost","root","");
   if($this->conexion>0 && mysqli_select_db( $this->conexion,"bdfelcas"))
   {	   
    return true;
   }
   else  
	{
      return false;
	}	
  }
//--------------------------------------------------------------------
//       Funci�n ejecutar SQL 
//--------------------------------------------------------------------
  function ejecutar_sql($sql) 
  {
     return mysqli_query($this->conexion,$sql);
  }
//--------------------------------------------------------------------
//       Proxima fila
//--------------------------------------------------------------------
  function proximafila($cursor) 
  {
        return mysqli_fetch_array($cursor);
  }
//--------------------------------------------------------------------
//       Funci�n cerrar conexi�n 
//--------------------------------------------------------------------
  function transacciones($tipo)
	{	
	$bd       = new control;
		if (!$bd->abrir_bd())
		    return 0;
		else
		{
		switch($tipo)
		{
		case "inicio" : $sql = "BEGIN";
		break;
		case "deshacer": $sql= "ROLLBACK";
		break;
		case "procesar": $sql= "COMMIT";
		break;
		}
		$cursor   = $bd->ejecutar_sql($sql);
		  $bd->cerrar_bd();
		  if ($cursor>0)
		       return ($cursor);
			else
			   return 0;
		}
		
		 return mysqli_query($sql,$this->conexion);
	}	
 
  function cerrar_bd() 
  {
    @mysqli_close($this->conexion);
  } 
}//Fin de la clase control
class configuracion
{
	function iva()
	{
	$bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;
		
	
	  $sql = "SELECT niva FROM tConfiguracion";
      $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;
	   
	 
	   $bd->cerrar_bd();
	   return $cursor;
  
	}
	
	
   
			function sanear_string($string)
			{
			
				$string = trim($string);
			
				$string = str_replace(
					array('�', '�', '�', '�', '�', '�', '�', '�', '�'),
					array('a', 'a', 'a', 'a', 'a', 'A', 'A', 'A', 'A'),
					$string
				);
			
				$string = str_replace(
					array('�', '�', '�', '�', '�', '�', '�', '�'),
					array('e', 'e', 'e', 'e', 'E', 'E', 'E', 'E'),
					$string
				);
			
				$string = str_replace(
					array('�', '�', '�', '�', '�', '�', '�', '�'),
					array('i', 'i', 'i', 'i', 'I', 'I', 'I', 'I'),
					$string
				);
			
				$string = str_replace(
					array('�', '�', '�', '�', '�', '�', '�', '�'),
					array('o', 'o', 'o', 'o', 'O', 'O', 'O', 'O'),
					$string
				);
			
				$string = str_replace(
					array('�', '�', '�', '�', '�', '�', '�', '�'),
					array('u', 'u', 'u', 'u', 'U', 'U', 'U', 'U'),
					$string
				);
			
				$string = str_replace(
					array('�', '�', '�', '�'),
					array('n', 'N', 'c', 'C',),
					$string
				);
			
				//Esta parte se encarga de eliminar cualquier caracter extra�o
				$string = str_replace(
					array("\\", "�", "�", "~",
						 "#", "@", "|", "!", "\"",
						 "�", "$", "%", "&",
						 "(", ")", "?", "'", "�",
						 "�", "[", "^", "`", "]",
						 "+", "}", "{", "�", "�",
						 ">", "< ", ";", ",", ":"),
					'',
					$string
				);
			
		
			return $string;
		}
	
	
	
}
class pedido  
{
//--------------------------------------------------------------------
//       Funci�n incluir cliente
//--------------------------------------------------------------------


function incluirpedido(array $array_id_prod, array $array_precio_prod, array $array_cant_prod, $filarray)		
	{
		
	//$fech = now();

		
		$bd       = new control;
		if (!$bd->abrir_bd())
		    return 0;
		else
		{
			
		$sql2 = "SELECT cid_pedido as ultimo from tconfiguracion;";
		
		  $cursorcorrelativo   = $bd->ejecutar_sql($sql2);
		  $correlativo=mysqli_fetch_object($cursorcorrelativo);
		$proximo=intval($correlativo->ultimo)+1;
			
		$sql = "INSERT INTO `tpedidos`( `cid_pedido` ,`cid_clien`,`dfecha`,`cid_status`,`mobservaci`,`cid_usuari`,  `cid_vende`,`nmonto_t`,`ntasa_iva`,`nbase_iva`,`nmontoiva`) VALUES($proximo,'$this->cid_clien',NOW(),'$this->status','$this->observacion','$this->usuario','$this->vendedor',$this->total,$this->tasa_iva,$this->base_iva,$this->monto_iva); ";
		
		
	
		
		  $cursor   = $bd->ejecutar_sql($sql);
		  $sql="";
		  
		  	for ($i=0;$i<$filarray;$i++){
				if($array_id_prod[$i]!=0){
				$sql = "INSERT INTO `tdetalles_pedido`(cid_pedido,cid_produc,ncantidad,nentregado,mobservaci,nprecio,nmonto,ndescuento,cid_docum,cid_prefac) values($proximo,'$array_id_prod[$i]',$array_cant_prod[$i],0,'', $array_precio_prod[$i], $array_cant_prod[$i]*$array_precio_prod[$i],0,'','');";
		$cursor   = $bd->ejecutar_sql($sql);
		  
				}
			}
			
		  $sql = "UPDATE tconfiguracion set cid_pedido=cid_pedido+1;";
		  $cursor   = $bd->ejecutar_sql($sql);
		  
			
		  $sql = "SELECT cid_pedido as ultimo from tconfiguracion;";
		
		  $cursor   = $bd->ejecutar_sql($sql);
		  $ultimo=mysqli_fetch_object($cursor);
		
		
		
		$codigohtml = '<html><head><title>E-Mail HTML</title></head><body>Ha sido recibido un pedido</body>';
		$email = 'pedrolopez@felcas.com.ve';
		$asunto = 'Notificacion de Pedido';
		$cabeceras = "Content-type: text/html\r\n";
	    $cabeceras .= "From: Distribuidora Felcas <ventas@felcas.com.ve>\r\n"; 
		//mail($email,$asunto,$codigohtml,$cabeceras);
		
		
		  $bd->cerrar_bd();
		  if ($cursor>0)
		  {
			  unset($_SESSION["ocarrito"]);
		  	?>
<script language='javascript'>
					//window.alert('Su pedido ha sido recibido exitosamente');
					//window.location='menu_clientes.php';
				</script>
<?php
					header("Location: ./detalle_pedido.php?id=".$ultimo->ultimo);
			
		       return ($cursor);
		  }
			else
			{
			   return 0;
			}
		}  	
	} // fin de la funcion incluir
	// ------------------ funciones set 
	
		
	
	
	function setcid_clien($cid_cliente)
	{
	   $this->cid_clien = $cid_cliente;
	}
	function setfecha($fecha)
	{
	   $this->fecha = $fecha;
	}
	function setstatus($status)
	{
	   $this->status = $status;
	}
	function setobservacion($observacion)
	{
	   $this->observacion = $observacion;
	}
	
	function setusuario($usuario)
	{
	   $this->usuario = $usuario;
	}	
	
	function setvendedor($vendedor)
	{
		$this->vendedor=$vendedor;
	}
	
	function settotal($total)
	{
		$this->total=$total;
	}

	function settasa_iva($tasa_iva)
	{
		$this->tasa_iva=$tasa_iva;
	}
	
	function setbase_iva($base_iva)
	{
		$this->base_iva=$base_iva;
	}
	function setmonto_iva($monto_iva)
	{
		$this->monto_iva=$monto_iva;
	}

	function setpedido($cid_cliente,$fecha,$status,$observacion,$usuario,$vendedor,$total,$tasa_iva,$base_iva,$monto_iva)
	{
		$this->setcid_clien($cid_cliente);
		$this->setfecha($fecha);
		$this->setstatus($status);
		$this->setobservacion($observacion);
		$this->setusuario($usuario);
		$this->setvendedor($vendedor);
		$this->settotal($total);
		$this->settasa_iva($tasa_iva);
		$this->setbase_iva($base_iva);
		$this->setmonto_iva($monto_iva);
		
	}
	
	

	
		
	function setcodigoprod($codigoprod)
	{
	   $this->codigoprod = $codigoprod;
	}
	function setcantidadprod($cantidadprod)
	{
	   $this->cantidadprod = $cantidadprod;
	}		
	function setprecio($precio)
	{
	   $this->precio = $precio;
	}
	
	function setdetalle_pedido($codigoprod,$cantidadprod,$precio)
	{
		$this->setcodigoprod($codigoprod);
		$this->setcantidadprod($cantidadprod);
		$this->setprecio($precio);
	}
	
	
	function eliminar_pedido($cid_pedido)
	{
		$bd       = new control;
		if (!$bd->abrir_bd())
		    return 0;
		else
		{
		$sql = "update tpedidos set cid_status=' 2' WHERE cid_pedido = '$cid_pedido'";
		
		  $cursor   = $bd->ejecutar_sql($sql);
		  
		  $bd->cerrar_bd();
		  if ($cursor>0){
		  ?>
<script language="javascript">
			window.alert("Su pedido ha sido anulado satisfactoriamente");
			history.go(-2);		
		</script>
<?php		  
		       return ($cursor);
		  }
			else
			{
			   return 0;
			}
		}  	
	} 
	//--------------------------------------------------------------------
//       Metodo consultar Registro de usuarios
//--------------------------------------------------------------------
  function consultarpedido($cid_pedido){
  	  $bd = new control;
 	  if(!$bd->abrir_bd())
	    return -1;			
	
	  $sql = "SELECT * FROM tclientes,tpedidos,tdetalles_pedido,tproductos WHERE tclientes.cid_clien=tpedidos.cid_clien and  tpedidos.cid_pedido=tdetalles_pedido.cid_pedido and tdetalles_pedido.cid_produc=tproductos.cid_produc and tpedidos.cid_pedido = $cid_pedido";
      $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;
	  
	  return $cursor;
  }
   function consultarpedido_eventual($cid_pedido){
  	  $bd = new control;
 	  if(!$bd->abrir_bd())
	    return -1;			
	
	  $sql = "SELECT cid_clien,cnombre_cl,crif_cli FROM tpedidos,tdetalles_pedido WHERE tpedidos.cid_pedido=tdetalles_pedido.cid_pedido and tpedidos.cid_pedido = $cid_pedido";
      $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;
	  
	  return $cursor;
  }
  function detallepedidocliente($cid_pedido)
  {
	    
	  $configuracion=new configuracion();
	  $iva=$configuracion->iva();
	  $valor_iva = 12.00;
	  $suma = 0;	  
	  
	   
	    $bd = new control;
 	  if(!$bd->abrir_bd())
	    return -1;			
	
	  $sql = "SELECT * FROM tclientes inner join tpedidos on tclientes.cid_clien=tpedidos.cid_clien inner join tdetalles_pedido on tpedidos.cid_pedido=tdetalles_pedido.cid_pedido INNER JOIN tproductos on tdetalles_pedido.cid_produc=tproductos.cid_produc WHERE tpedidos.cid_pedido = trim($cid_pedido)";
	 
      $cursor   = $bd->ejecutar_sql($sql);
	 
	  $contador = 0;
	$i=0;
	
	$ped = mysqli_fetch_object($cursor);
		 echo '<table width="745" border="0" cellpadding="0" cellspacing="1" class="frame">
				<tr>
					<td colspan="2" bgcolor="#C14717" class="encabezados">Datos de Pedido</td>
				</tr>
				<tr>
					<td width="194" bgcolor="#f2f2f2" class="textosvarios">C�digo:</td>
					<td width="505" bgcolor="#f2f2f2">'.$ped->cid_pedido.'</td>
				</tr>
				<tr>
					<td bgcolor="#f2f2f2" class="textosvarios">Fecha de Pedido:</td>
					<td bgcolor="#f2f2f2">'.date("d/m/Y h:i a",strtotime($ped->dfecha)).'</td>
				</tr>
				<tr>
					<td height="25" bgcolor="#f2f2f2" class="textosvarios">Usuario Responsable:</td>
					<td bgcolor="#f2f2f2">'.trim($ped->cid_usuari).'</td>
				</tr>
				<tr>
					<td height="25" bgcolor="#f2f2f2" class="textosvarios">Cargo:</td>
					<td bgcolor="#f2f2f2"></td>
				</tr>
		  </table> <br>';
	   	 $clientes=new clientes();
		 $clien=$clientes->consultar($ped->cid_clien);
		 $datoscliente = mysqli_fetch_object($clien);
		 
		 								   if($ped->cid_clien!='99999'){
						                   $lcnombre=$datoscliente->cnombre_cl;
					                       }
										   else
										   {
											$detalle_pedido=$this->consultarpedido_eventual($ped->cid_pedido);
											$fila3=mysqli_fetch_object($detalle_pedido);
											$lcnombre="EVENTUAL: ".$fila3->cnombre_cl;   
										   }
		 
	 echo '<table width="745" border="0" cellpadding="0" cellspacing="1" class="frame">
				<tr>
					<td colspan="2" bgcolor="#C14717" class="encabezados">Datos de Cliente</td>
				</tr>
				<tr>
					<td width="194" bgcolor="#f2f2f2" class="textosvarios">C�digo:</td>
					<td width="505" bgcolor="#f2f2f2">'.$ped->cid_clien.'</td>
				</tr>
				<tr>
					<td bgcolor="#f2f2f2" class="textosvarios">Nombre y Apellido o Raz�n Social:</td>
					<td bgcolor="#f2f2f2">'. $lcnombre .'</td>
				</tr>				
		  </table><br>';
	   
	
	 
						echo '<table border=0 cellpadding="3" class="tablas">
							  <tr>
								<td width="80" bgcolor="#C14717" class="encabezados" align="center"><b>C�digo</b></td>
								<td width="100" bgcolor="#C14717" class="encabezados" align="center"><b>Referencia</b></td>
								<td width="300" bgcolor="#C14717" class="encabezados" align="center"><b>Nombre producto</b></td>
								<td width="50" bgcolor="#C14717" class="encabezados" align="center"><b>Cantidad</b></td>
								<td width="80" bgcolor="#C14717" class="encabezados" align="center"><b>Precio</b></td>				
								<td width="85" bgcolor="#C14717" class="encabezados" align="center"><b>Monto</b></td>
								
							  </tr>';
							   $bd->cerrar_bd();
							     
	    $bd = new control;
		$fc="";
 	  if(!$bd->abrir_bd())
	    return -1;	
		
							    $cursor2   = $bd->ejecutar_sql($sql);
		   while ($fila = mysqli_fetch_object($cursor2)){
						$i++;
						
						if(!is_null($fila->lserial))
						    $fc="*";
						else
							$fc="";		
						
								echo '<tr>';
									if($i%2==0)
									{
									echo '<td align="center">' . $fila->cid_produc . '</td>';
									echo '<td align="center">' . $fila->cid_alter . '</td>';
									echo '<td align="left">' . $fc . $fila->cdescripci . '</td>';
									echo '<td align="right">' . number_format($fila->ncantidad,2,",",".") . '</td>';
									echo '<td align="right">' . number_format($fila->nprecio,2,",",".") . '</td>';
									echo '<td align="right">' . number_format($fila->ncantidad*$fila->nprecio,2,",",".") . '</td>';				
									
									}
									else
									{
									echo '<td bgcolor="#f2f2f2" align="center">' . $fila->cid_produc . '</td>';
									echo '<td bgcolor="#f2f2f2" align="center">' . $fila->cid_alter . '</td>';
									echo '<td bgcolor="#f2f2f2" align="left">' . $fc . $fila->cdescripci . '</td>';
									echo '<td bgcolor="#f2f2f2" align="right">' . number_format($fila->ncantidad,2,",",".") . '</td>';
									echo '<td bgcolor="#f2f2f2" align="right">' . number_format($fila->nprecio,2,",",".") . '</td>';
									echo '<td bgcolor="#f2f2f2" align="right">' . number_format($fila->ncantidad*$fila->nprecio,2,",",".") . '</td>';				
								
									}
								echo '</tr>';
								$suma += $fila->ncantidad*$fila->nprecio;
								$this->total_pedido += $fila->ncantidad*$fila->nprecio;
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
							 
							  <td><b>BASE : </b></td>
							  <td align="right"><b>'. number_format($suma,2,",",".") .'</b></td>	
							  </tr>';
						//total de iva
						echo '<tr>
							  <td>&nbsp;</td>
							  <td>&nbsp;</td>
							  <td>&nbsp;</td>
							  <td>&nbsp;</td>
							  <td><b>IVA (12%): </b></td>
							  <td align="right"><b>' . number_format(($suma * $valor_iva)/100,2,",",".") . '</b></td>
							 
							  </tr>
							 ';
						//total m�s IVA
						echo '<tr>
							  <td>&nbsp;</td>
							  <td>&nbsp;</td>
							  <td>&nbsp;</td>
							  <td>&nbsp;</td>							  
							  <td><b>TOTAL : </b></td>
							  <td align="right"><b>' . number_format($suma * (1+($valor_iva/100)),2,",",".") . '</b></td>
							  </tr>';
						echo "</table>";
	   
	   
	   $bd->cerrar_bd();
	   return $cursor2;
  
  }
  

  
  function listadopedidos($cid_cliente)
	{
	  $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;

	  $sql      = "SELECT * FROM tpedidos WHERE cid_clien=trim('$cid_cliente')";
      $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;


	   $bd->cerrar_bd();
	   return $cursor;
	}
	function montopedido($cid_pedido)
	{
	  $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;

	  $sql      = "SELECT sum(nmonto) as monto FROM tpedidos inner join tdetalles_pedido on tpedidos.cid_pedido=tdetalles_pedido.cid_pedido WHERE tpedidos.cid_pedido=trim('$cid_pedido')";
      $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;

	   
	  if ($row = $bd->proximafila($cursor))
	  {
			 DO
			 {				 		
			   $filas [$contador][1] = $row["monto"];
			    
			   $contador++;
			   }
			WHILE ($row = $bd->proximafila($cursor));
	   }
	   $bd->cerrar_bd();
	   return $filas[0][1];

	}
	 function listado_pedidos_vendedor($cid_vendedor)
	{
	  $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;

	  $sql      = "SELECT * FROM tpedidos inner join tclientes on tpedidos.cid_clien=tclientes.cid_clien WHERE tclientes.cid_vende=trim('$cid_vendedor') order by cast(cid_pedido as decimal)";
      $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;


	   $bd->cerrar_bd();
	   return $cursor;
	}
	function listado_pedidos_administrador()
	{
	  $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;

	  //$sql      = "SELECT tpedidos.cid_vende,cnombrev,cid_pedido,cnombre_cl,dfecha,cid_status FROM tvendedores inner join tpedidos on tvendedores.cid_vende=tpedidos.cid_vende inner join tclientes on tpedidos.cid_clien=tclientes.cid_clien where cid_status='1' or cid_status='3' or cid_status='  1' order by cast(cid_pedido as decimal)";
	
      $sql      = "SELECT tpedidos.cid_vende,cid_pedido,tclientes.cnombre_cl,dfecha,cid_status,tpedidos.cid_clien FROM tpedidos inner join tclientes on tpedidos.cid_clien=tclientes.cid_clien where cid_status='1' or cid_status='3' or cid_status='  1' order by cast(cid_pedido as decimal)";
	  $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;


	   $bd->cerrar_bd();
	   return $cursor;
	}
	
	
// ----------  finaliza funcion consultar cliente 	


  
 
  function listadopedidocompleto()
  {
  $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;
		
		
	
	  $sql = "SELECT * FROM tpedidos WHERE cstatus<>'E'";
      $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;
	   
	  if ($row = $bd->proximafila($cursor))
	  {
			 DO
			 {				 		
			   $filas [$contador][1] = $row["cid_pedido"];
			   $filas [$contador][2] = $row["cid_cliente"];
			   $filas [$contador][3] = $row["dfecha_pedido"];
			   $filas [$contador][4] = $row["clugar_recepcion"];
			   $filas [$contador][5] = $row["ccondicion_pago"];
			   $filas [$contador][6] = $row["cstatus"];
			   
			   $contador++;
			   }
			WHILE ($row = $bd->proximafila($cursor));
	   }
	   $bd->cerrar_bd();
	   return $filas;
  
  } 
  
  function listadopedidocancelar($cedula)
  {
  $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;
		
		
	
	  $sql = "SELECT * FROM tpedidos WHERE cid_cliente = '$cedula' and cstatus='C'";
      $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;
	   
	  if ($row = $bd->proximafila($cursor))
	  {
			 DO
			 {				 		
			   $filas [$contador][1] = $row["cid_pedido"];
			   $filas [$contador][2] = $row["cid_cliente"];
			   $filas [$contador][3] = $row["dfecha_pedido"];
			   $filas [$contador][4] = $row["clugar_recepcion"];
			   $filas [$contador][5] = $row["ccondicion_pago"];
			   $filas [$contador][6] = $row["cstatus"];
			   
			   $contador++;
			   }
			WHILE ($row = $bd->proximafila($cursor));
	   }
	   $bd->cerrar_bd();
	   return $filas;
  
  }
  
  
  function consultar($cedula)
	{
	  $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;
	  $sql      = "SELECT * FROM pedidoproveedor WHERE cedula = '$cedula'";
	  $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;
	  if ($row = $bd->proximafila($cursor))
	  {			 
			 	 $filas [$contador][1] = $row["cedula"];
			   $filas [$contador][2] = $row["nombre"];
			   $filas [$contador][3] = $row["referencia"];
			      $filas [$contador][4] = $row["descripcion"];
				    $filas [$contador][5] = $row["cantidad"];
			   $filas [$contador][6] = $row["precioc"];
			   $filas [$contador][7] = $row["fechaalta"];
			      $filas [$contador][8] = $row["observaciones"];		
			   	$contador++;
	   }
	   $bd->cerrar_bd();
	   return $filas;
	}//--- fin de la funcion consultar 
	
		
	//--------------------------------------------------------------------
//       Metodo consultar Cliente
//--------------------------------------------------------------------
  
	
	function consultarpedidocod($codped,$status)
	{
	  $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;
		
		
	
	  $sql = "SELECT * FROM tpedidos WHERE cid_pedido = '$codped' and cstatus='$status'";
      $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;
	   
	  if ($row = $bd->proximafila($cursor))
	  {
			 DO
			 {				 		
			   $filas [$contador][1] = $row["cid_pedido"];
			   $filas [$contador][2] = $row["cid_cliente"];
			   $filas [$contador][3] = $row["dfecha_pedido"];
			   $filas [$contador][4] = $row["clugar_recepcion"];
			   $filas [$contador][5] = $row["ccondicion_pago"];
			   $filas [$contador][6] = $row["cstatus"];
			   $filas [$contador][7] = $row["cdirerecepcion"];
			   
			   $contador++;
			   }
			WHILE ($row = $bd->proximafila($cursor));
	   }
	   $bd->cerrar_bd();
	   return $filas;
	}
	
	
	function consultarpedidosolocod($codped)
	{
	  $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;
		
		
	
	  $sql = "SELECT * FROM tpedidos WHERE cid_pedido = '$codped'";
      $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;
	   
	  if ($row = $bd->proximafila($cursor))
	  {
			 DO
			 {				 		
			   $filas [$contador][1] = $row["cid_pedido"];
			   $filas [$contador][2] = $row["cid_cliente"];
			   $filas [$contador][3] = $row["dfecha_pedido"];
			   $filas [$contador][4] = $row["clugar_recepcion"];
			   $filas [$contador][5] = $row["ccondicion_pago"];
			   $filas [$contador][6] = $row["cstatus"];
			   $filas [$contador][7] = $row["cdirerecepcion"];
			   
			   $contador++;
			   }
			WHILE ($row = $bd->proximafila($cursor));
	   }
	   $bd->cerrar_bd();
	   return $filas;
	}
	
	
	
	
	function consultardetalle($codped)
	{
	  $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;
		
		
	
	  $sql = "SELECT * FROM tdetalles_pedido WHERE cid_pedido = '$codped'";
      $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;
	  
	  if ($row = $bd->proximafila($cursor))
	  {
			 DO
			 {				 		
			   $filas [$contador][1] = $row["cid_pedido"];
			   $filas [$contador][2] = $row["cid_producto"];
			   $filas [$contador][3] = $row["cantidad"];			  
			   $contador++;
			   }
			WHILE ($row = $bd->proximafila($cursor));
	   }
	   $bd->cerrar_bd();
	   return $filas;
	}
	
	function actualizarstatus($codped,$status)
	{
	  $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;		
	
	  $sql = "update tpedidos set cid_status='$status' WHERE cid_pedido = '$codped'";
	 
      $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;	  
	  
	   $bd->cerrar_bd();
	   return $cursor;
	}
	

	

}// fin de la clase pedidoproveedor





class articulo
{

// ------------------ funciones set 
		
	function setreferencia($referencia)
	{
	   $this->referencia = $referencia;
	}
	function setdescripcion($descripcion)
	{
	   $this->descripcion = $descripcion;
	   }
			
	function setimagen($imagen)
	{
	   $this->imagen = $imagen;
	   	}		
	function setobservaciones($observaciones)
	{
	   $this->observaciones = $observaciones;
	}
	function setpreciov($preciov)
	{
	   $this->preciov = $preciov;
	}
	 //--- fin de la funcion set
	
	
	function subirimagen($nombre_archivo,$tipo_archivo,$tamano_archivo)
	{
		
		/////SUBIR IMAGEN AL SERVER////////////////////////////////	
		//compruebo si las caracter�sticas del archivo son las que deseo
		if (!((strpos($tipo_archivo, "xls") || strpos($tipo_archivo, "xlsx")) && ($tamano_archivo < 100000)))
		{
				?>
					<script language="JavaScript">
						alert("Error de tipo de archivo solo se aceptan archivos de Excel");				
					</script>
			   <?php
		 return false;
		}
		else
		{
			//if (move_uploaded_file($HTTP_POST_FILES['userfile']['tmp_name'], $nombre_archivo)){
			if (move_uploaded_file($HTTP_POST_FILES['userfile']['tmp_name'], "../temp/".$nombre_archivo))
			{
			   return true;
			}
			else
			{
				?>
					<script language="JavaScript">
						alert("No se pudo subir la imagen posible problema de permisos");                    
					</script>
				<?php
				return false;
			}
		}
	
	
	}
	function subirexcel($nombre_archivo,$tipo_archivo,$tamano_archivo)
	{
		
		/////SUBIR IMAGEN AL SERVER////////////////////////////////	
		//compruebo si las caracter�sticas del archivo son las que deseo
		if (!((strpos($tipo_archivo, "xls") || strpos($tipo_archivo, "xlsx")) && ($tamano_archivo < 100000)))
		{
				?>
					<script language="JavaScript">
						alert("Error de tipo de archivo solo se aceptan archivos de Excel");				
					</script>
			   <?php
		 return false;
		}
		else
		{
			//if (move_uploaded_file($HTTP_POST_FILES['userfile']['tmp_name'], $nombre_archivo)){
			if (move_uploaded_file($HTTP_POST_FILES['userfile']['tmp_name'], "../temp/".$nombre_archivo))
			{
			   return true;
			}
			else
			{
				?>
					<script language="JavaScript">
						alert("No se pudo subir la imagen posible problema de permisos");                    
					</script>
				<?php
				return false;
			}
		}
	
	
	}
	
	function validadirimagen($cadena)
	{
	
		$largo=strlen($cadena);
		$car="";
		$conta=0;
		
		while ($car <> "\\"){
		$conta=$conta+1;
		$car=substr($cadena,$conta*-1,1);
		?>
<script language="JavaScript">
			alert(" Caracter <?php echo $car ?> Registrado");
		
		</script>
<?php 
		}
		
		
		return substr($cadena,($conta-1)*-1);
		
	}
	
		//-------------------------------------------------------------------
//       M�todo listado cliente
//--------------------------------------------------------------------
	 
		
	function listararticulos()
	{
	  $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;
	
	  $sql      = "SELECT * FROM tproductos order by cdescripci";
      $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;

	  if ($row = $bd->proximafila($cursor))
	  {
			 DO
			 {
			   $filas [$contador][1] = $row["cid_produc"];
			   $filas [$contador][2] = $row["cdescripci"];			  
			  // $filas [$contador][3] = $row["cdescrialt"];			      
			   $filas [$contador][4] = $row["gfoto"];
			   //$filas [$contador][5] = $row["cempaque"];
			   $filas [$contador][6] = $row["cclasi1"];
			   $filas [$contador][7] = $row["cid_alter"];

			   $contador++;
			   }
			WHILE ($row = $bd->proximafila($cursor));
	   }
	   $bd->cerrar_bd();
	   return $filas;
	}
	function armar_like_busqueda($busqueda)
	{
		$opcion_or="";
		$cadena="";
		$veces=0;
		$trozos=explode("*",trim($busqueda)); 
	    $veces=count($trozos); 
		//$veces=substr_count($busqueda,'*');
		for($i=1;$i<$veces;$i++)
		{
			if($veces>2)
			{
				if($i<$veces-1)
				  $opcion_or="AND";
				else
				  $opcion_or="";
			}
			
			$cadena=$cadena." (cid_alter LIKE '%$trozos[$i]%' OR cdescripci LIKE '%$trozos[$i]%') ".$opcion_or;
		}
		
		
		//echo $veces;
		//echo print_r($trozos);
		return $cadena;
		
	}
	function listadoprecios($linea)
	{
		 $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;
		
		$parametro=trim($linea);

	if($linea=='0')
	{
	  $sql      = "select tproductos.cid_produc,cid_alter,tproductos.cdescripci,nprecio,cclasi1,cclasi4,tcolores.cdescripci as marca,cdescrialt from tproductos inner join tproductos_precio on tproductos.cid_produc=tproductos_precio.cid_produc inner join tcolores on trim(tproductos.cclasi4)=trim(tcolores.cid_color) where tproductos_precio.ctipo_pre=' 1' and lactivo=1 and tproductos.nexisten>0 and tproductos_precio.nprecio>0 order by tproductos.cdescripci";
	}
	else
	{
		$sql      = "select tproductos.cid_produc,cid_alter,tproductos.cdescripci,nprecio,cclasi1,cclasi4,tcolores.cdescripci as marca,cdescrialt from tproductos inner join tproductos_precio on tproductos.cid_produc=tproductos_precio.cid_produc inner join tcolores on trim(tproductos.cclasi4)=trim(tcolores.cid_color) where tproductos_precio.ctipo_pre=' 1' and lactivo=1 and trim(cclasi1)='$parametro' and tproductos.nexisten>0 and tproductos_precio.nprecio>0 order by tproductos.cdescripci";
	
	}
	  $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;
	  
	    
	   $bd->cerrar_bd();
	   return $cursor;
	
	
	}//fin de la function resultado
	function listadoprecios_excel()
	{
		 $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;

	  $sql      = "select tproductos.cid_produc,cid_alter,cdescripci,nprecio,cclasi1 from tproductos inner join tproductos_precio on tproductos.cid_produc=tproductos_precio.cid_produc  where tproductos_precio.ctipo_pre=' 1' and lactivo=1 order by tproductos.cdescripci";
	  $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;
	  
	    

	   $bd->cerrar_bd();
	   return $cursor;
	
	
	}//fin de la function resultado
	function listadoprecios_filtrada($linea,$busqueda)
	{
		
		
		$bd       = new control;
			  if(!$bd->abrir_bd())
				return -1;
			  if ($busqueda<>'')
			  { 
			
			   //CUENTA EL NUMERO DE PALABRAS 
			   $trozos=explode("*",$busqueda); 
			   $numero=count($trozos); 
			   
				  if ($numero==1) 
				  { 				  
				   //SI SOLO HAY UNA PALABRA DE BUSQUEDA SE ESTABLECE UNA INSTRUCION CON LIKE 
				   $sql="SELECT * FROM tproductos inner join tproductos_precio on tproductos.cid_produc=tproductos_precio.cid_produc WHERE cclasi1='$linea' and tproductos_precio.ctipo_pre=' 1' and lactivo=1 and (cid_alter LIKE '%$busqueda%' OR cdescripci LIKE '%$busqueda%') order by cdescripci"; 
				
				  } 
				  elseif ($numero>1)
				  { 
				 	   
				  //SI HAY UNA FRASE SE UTILIZA EL ALGORTIMO DE BUSQUEDA AVANZADO DE MATCH AGAINST 
				
				  //$sql="SELECT *, MATCH ( cid_produc, cdescripci ) AGAINST ( '$busqueda' ) AS Score FROM tproductos WHERE MATCH ( cid_produc, cdescripci ) AGAINST ( '$busqueda' WITH QUERY EXPANSION) and cclasi1='$linea' HAVING Score > 0.2 ORDER BY Score DESC "; 
				  $sql="SELECT * FROM tproductos inner join tproductos_precio on tproductos.cid_produc=tproductos_precio.cid_produc WHERE cclasi1='$linea' and tproductos_precio.ctipo_pre=' 1' and lactivo=1 and (". $this->armar_like_busqueda($busqueda).") order by cdescripci";
				  // header('Location: ..\prueba.php?dato='.$sql);			
				  } 
				  
				   
			  //$sql      = "SELECT * FROM tlineas order by cdescripci";
			  }
			  
			 
		
		$cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;

	   $bd->cerrar_bd();
	   return $cursor;
	
	
	}//fin
	
	
// ----------  finaliza funcion consultar cliente 
 //--------------------------------------------------------------------
//       Metodo consultar modificar cliente
//--------------------------------------------------------------------
    function consultararticulo($codigo)
	{
	  $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;

	 $sql      = "SELECT * FROM tproductos inner join tproductos_precio on tproductos.cid_produc=tproductos_precio.cid_produc WHERE tproductos.cid_produc = '$codigo' and trim(ctipo_pre)=' 1' order by cdescripci ";
	   
	  $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;

	  if ($row = $bd->proximafila($cursor))
	  {
			   $filas [$contador][1] = $row["cid_produc"];
			   $filas [$contador][2] = $row["cdescripci"];			  
			   $filas [$contador][3] = $row["cid_alter"];			      
			   $filas [$contador][4] = $row["gfoto"];
			   $filas [$contador][5] = $row["nprecio"];
			   $filas [$contador][6] = $row["cclasi1"];
			   $filas [$contador][7] = $row["creferenci"];

			   
			   $contador++;
	
	   }
	   $bd->cerrar_bd();
	   return $filas;
	}//--- fin de la funcion consultar
	 
	function consultarexistencia($codigo)
	{
	  $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;

	 $sql      = "SELECT sum(tproductos_almacen.nexisten) as existencia FROM tproductos inner join tproductos_almacen on tproductos.cid_produc=tproductos_almacen.cid_produc WHERE tproductos.cid_produc = '$codigo' order by cdescripci";

	   
	  $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;

	  if ($row = $bd->proximafila($cursor))
	  {
			   $filas [$contador][1] = $row["existencia"];
			 			   
			   $contador++;
	
	   }
	   $bd->cerrar_bd();
	   return $filas;
	}//--- fin de la funcion consultar 
	
	function consultararticulo2($codigo)
	{
	  $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;

	 $sql      = "SELECT * FROM tproductos inner join tproductos_precio on tproductos.cid_produc=tproductos_precio.cid_produc WHERE tproductos.cid_produc = '$codigo' order by cdescripci";

	   
	  $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;

	  if ($row = $bd->proximafila($cursor))
	  {
			   $filas [$contador][1] = $row["cid_produc"];
			   $filas [$contador][2] = $row["cdescripci"];			  
			   $filas [$contador][3] = $row["cid_alter"];			      
			   $filas [$contador][4] = $row["gfoto"];
			   $filas [$contador][5] = $row["nprecio"];
			   $filas [$contador][6] = $row["cclasi1"];

			   
			   $contador++;
	
	   }
	   $bd->cerrar_bd();
	   return $filas;
	}//--- fin de la funcion consultar 
	
	function productos_webservices($valor)
	{
		
	
	$dia=date("z")."  ";
		
		if(($valor/54321)==($dia+1))
		{
			
		$bd       = new control;
		$config=new configuracion;
		
		  if(!$bd->abrir_bd())
			return -1;
	
			  $sql      = "SELECT * FROM tproductos";		
			  $cursor   = $bd->ejecutar_sql($sql);
			  $contador = 0;

			  if ($row = $bd->proximafila($cursor))
			  {
					DO
					{
							
						$filas [$contador]["cid_produc"] = $row["cid_produc"];			
						$filas [$contador]["cdescripci"] = $config->sanear_string($row["cdescripci"]);	
						//$filas [$contador]["cdescrialt"] = trim($row["cdescrialt"]); comentado por uso excesivo de memoria
						$filas [$contador]["cdescrialt"] = "";
						$filas [$contador]["cempaque"] = $row["cempaque"];
						$filas [$contador]["creferenci"] = $row["creferenci"];
						$filas [$contador]["npeso"] = $row["npeso"];
						$filas [$contador]["cunidad_m"] = $row["cunidad_m"];
						$filas [$contador]["nmedida_l"] = $row["nmedida_l"];
						$filas [$contador]["nmedida_m"] = $row["nmedida_m"];
						$filas [$contador]["nmedida_p"] = $row["nmedida_p"];				
						$filas [$contador]["cclasi1"] = $row["cclasi1"];
						$filas [$contador]["cclasi2"] = $row["cclasi2"];
						$filas [$contador]["cclasi3"] = $row["cclasi3"];
						$filas [$contador]["cclasi4"] = $row["cclasi4"];
						$filas [$contador]["lapli_iva"] = $row["lapli_iva"];
						$filas [$contador]["gfoto"] = $row["gfoto"];				
						$filas [$contador]["lservicio"] = $row["lservicio"];
						$filas [$contador]["cid_alter"] = $row["cid_alter"];
						$filas [$contador]["nexisten"] = $row["nexisten"];
						$filas [$contador]["lactivo"] = $row["lactivo"];
						
									   
					   $contador++;
					}
					WHILE ($row = $bd->proximafila($cursor));
			   }
			   
			
			$json='{"productos": '.trim(array2json($filas)).' }';
			if(!ob_start("ob_gzhandler")) ob_start();
			echo prettyPrint($json);	   
		   
			$bd->cerrar_bd();
			return $filas;	   
		  
		}
	}
	
	
	
	function productos_webservicesopencart()
	{
		
	
	 //echo 'aa';
			
		$bd       = new control;
		$config=new configuracion;
		
		  if(!$bd->abrir_bd())
			return -1;
	
			  //$sql      = "SELECT tproductos.cid_produc,cdescripci,cdescrialt,cempaque,creferenci,npeso,cunidad_m,nmedida_l,nmedida_m,nmedida_p,dfecha_inc,cclasi1,cclasi2,cclasi3,cclasi4,cid_alter,a.nexisten,lactivo,p1.nprecio AS precio1,p2.nprecio AS precio2,p3.nprecio AS precio3 FROM tproductos left join tproductos_precio p1 on tproductos.cid_produc=p1.cid_produc AND p1.ctipo_pre=' 1' left join tproductos_precio p2 on tproductos.cid_produc=p2.cid_produc AND p2.ctipo_pre=' 2' left join tproductos_precio p3 on tproductos.cid_produc=p3.cid_produc AND p3.ctipo_pre='11'";		
			  $sql      = "SELECT tproductos.cid_produc,cid_alter,tproductos.cdescripci,cdescrialt,cempaque,creferenci,npeso,cunidad_m,nmedida_l,nmedida_m,nmedida_p,dfecha_inc,cclasi1,l.cdescripci AS categoria,cclasi2,s.cdescripci AS subcategoria,cclasi3,t.cdescripci AS linea,cclasi4,c.cdescripci AS marca,nexisten,lactivo,p1.nprecio AS precio1,p2.nprecio AS precio2,p3.nprecio AS precio3,ltransito,lrecienllegado
FROM tproductos left join tproductos_precio p1 on tproductos.cid_produc=p1.cid_produc AND p1.ctipo_pre=' 1' 
left join tproductos_precio p2 on tproductos.cid_produc=p2.cid_produc AND p2.ctipo_pre=' 2' 
left join tproductos_precio p3 on tproductos.cid_produc=p3.cid_produc AND p3.ctipo_pre='11'
LEFT JOIN tlineas l ON tproductos.cclasi1=l.cid_linea
LEFT JOIN tsublineas s ON tproductos.cclasi2=s.cid_sublin
LEFT JOIN ttallas t ON tproductos.cclasi3=t.cid_talla
LEFT JOIN tcolores c ON tproductos.cclasi4=c.cid_color
";

			 //echo 'xx';

			 $cursor   = $bd->ejecutar_sql($sql);
			 
			  $contador = 0;

			  if ($row = $bd->proximafila($cursor))
			  {
					DO
					{
						
						
						//echo 'jj';
						$codigo=trim($row["cid_produc"]);
							
						$filas [$contador]["cid_produc"] = $row["cid_produc"];		
						
						$filas [$contador]["cdescripci"] = trim($config->sanear_string($row["cdescripci"]));	
						$filas [$contador]["cdescrialt"] = trim($config->sanear_string($row["cdescrialt"])); 						
						$filas [$contador]["cempaque"] = $row["cempaque"];
						$filas [$contador]["creferenci"] = $row["creferenci"];
						$filas [$contador]["npeso"] = $row["npeso"];
						$filas [$contador]["cunidad_m"] = $row["cunidad_m"];
						$filas [$contador]["nmedida_l"] = $row["nmedida_l"];
						$filas [$contador]["nmedida_m"] = $row["nmedida_m"];
						$filas [$contador]["nmedida_p"] = $row["nmedida_p"];
									
						$filas [$contador]["cclasi1"] = $row["cclasi1"];
						$filas [$contador]["categoria"] = trim($row["categoria"]);
						$filas [$contador]["cclasi2"] = $row["cclasi2"];
						$filas [$contador]["subcategoria"] = trim($row["subcategoria"]);
						$filas [$contador]["cclasi3"] = $row["cclasi3"];
						$filas [$contador]["linea"] = trim($row["linea"]);
						$filas [$contador]["cclasi4"] = $row["cclasi4"];
						$filas [$contador]["marca"] = trim($row["marca"]);
						
						//$filas [$contador]["gfoto"] = $row["gfoto"];				
						
						$filas [$contador]["cid_alter"] = $row["cid_alter"];
						$filas [$contador]["nexisten"] = trim($row["nexisten"]);
						
						$filas [$contador]["precio1"] = $row["precio1"];
						$filas [$contador]["precio2"] = $row["precio2"];
						$filas [$contador]["precio3"] = $row["precio3"];
						$filas [$contador]["ltransito"] = $row["ltransito"];
						$filas [$contador]["lrecienllegado"] = $row["lrecienllegado"];
						//$filas [$contador]["lactivo"] = $row["lactivo"];
						
						$sqlequivalentes = "SELECT cid_equiva FROM tproductos_equivalente WHERE trim(cid_produc) = '$codigo' and trim(cid_equiva)<>''";
					
						$cursor2=$bd->ejecutar_sql($sqlequivalentes);
					
						$cantidad=mysqli_num_rows($cursor2);
						
						$contador2 = 0;

						if ($cantidad>0){
						  if ($row2 = $bd->proximafila($cursor2))
						  {
							  
							  
								DO
								{	
									//echo "Encontre equivalente ";
									//echo $sqlequivalentes;
									
									$valor=strval($row2["cid_equiva"]);
								
								$filas3 ["codigo".$contador2]=$valor;
								$contador2++;
								}
								WHILE ($row2 = $bd->proximafila($cursor2));
						  }		
							
if($codigo="002-0192-01") 
{	
echo "Producto: ".print_r($row2["cid_produc"]);					
 //echo print_r($filas3);
}
	

							//if(!empty($filas2))
							//{
								$filas [strval($contador)]["equivalentes"]=$filas3;
							//}								
							//else
							//{
							//	$filas [$contador]["equivalentes"]="";
							//}
						}
						else
						{
							$filas [strval($contador)]["equivalentes"]="";
						}	

										

						
					   $contador++;
					}
					WHILE ($row = $bd->proximafila($cursor));
			   }
			   
			//print_r($filas);
			$json='{"productosopencart": '.trim(array2json($filas)).' }';
			//if(!ob_start("ob_gzhandler")) ob_start();
	
			/*$archivo='productos.json';
			$handle= fopen($archivo,'w') or die('No se puede abrir el archivo '.$archivo);
			fwrite($handle,$archivo);
			fclose($handle);*/
			
			$file_pointer = dirname(__FILE__)."/../webservices/productos.json"; 
				   
				// Use unlink() function to delete a file 
				if (!unlink($file_pointer)) { 
					echo ("$file_pointer cannot be deleted due to an error"); 
				} 
				else { 
					//echo ("$file_pointer has been deleted"); 
				} 
  
			//echo $contador;
			
			$file = fopen(dirname(__FILE__)."/../webservices/productos.json", "w+");

			fwrite($file, $json . PHP_EOL);

			//fwrite($file, "Otra más" . PHP_EOL);

			fclose($file);
			
	
			//echo prettyPrint($json);	   
		   
			$bd->cerrar_bd();
			return $filas;	   
		  
		
	}

	
	
	function precios_webservices($valor)
	{
		$dia=date("z")."  ";
		
		if(($valor/54321)==($dia+1)){
		
			  $bd = new control;
			  
			  if(!$bd->abrir_bd())
				return -1;
		
			  $sql      = "SELECT * FROM tproductos_precio where trim(ctipo_pre)=' 1'";
			
			  $cursor   = $bd->ejecutar_sql($sql);
			  $contador = 0;
		
			  if ($row = $bd->proximafila($cursor))
			  {
					DO
					{
						
						$filas [$contador]["cid_produc"] = $row["cid_produc"];			
						$filas [$contador]["ctipo_pre"] = $row["ctipo_pre"];	
						$filas [$contador]["nprecio"] = $row["nprecio"];			  	
						$filas [$contador]["ctipo_ref"] = $row["ctipo_ref"];
						$filas [$contador]["nfactor"] = $row["nfactor"];
						
						
									   
					   $contador++;
					}
					WHILE ($row = $bd->proximafila($cursor));
			   }
				$json='{"precios": '.trim(array2json($filas)).' }';
				if(!ob_start("ob_gzhandler")) ob_start();
				echo prettyPrint($json);
			   
			   
			   
			   $bd->cerrar_bd();
			   return $filas;
	   
	  
		}
	}
	
	function almacenes_webservices($valor)
	{
		$dia=date("z")."  ";
		
		if(($valor/54321)==($dia+1)){
		
	$bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;

	  $sql      = "SELECT * FROM tproductos_almacen";
	
	  $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;

	  if ($row = $bd->proximafila($cursor))
	  {
			DO
			{
				
				$filas [$contador]["cid_produc"] = trim($row["cid_produc"]);			
				$filas [$contador]["cid_almace"] = $row["cid_almace"];	
			  	$filas [$contador]["nexisten"] = $row["nexisten"];			  	
				
							   
			   $contador++;
			}
			WHILE ($row = $bd->proximafila($cursor));
	   }
	     //print_r ($filas);
	    $json='{"almacenes": '.trim(array2json($filas)).' }';
		if(!ob_start("ob_gzhandler")) ob_start();
		
	    echo prettyPrint($json);
	   
	   
	   
	   $bd->cerrar_bd();
	   return $filas;
	   
	  
		}
	}
	function lineas_webservices($valor)
	{
		$dia=date("z")."  ";
		
		if(($valor/54321)==($dia+1)){
		
	$bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;

	  $sql      = "SELECT * FROM tlineas";
	
	  $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;

	  if ($row = $bd->proximafila($cursor))
	  {
			DO
			{
				
				$filas [$contador]["cid_linea"] = $row["cid_linea"];			
				$filas [$contador]["cdescripci"] = $row["cdescripci"];	
			  	//$filas [$contador]["nexisten"] = $row["nexisten"];			  	
				
							   
			   $contador++;
			}
			WHILE ($row = $bd->proximafila($cursor));
	   }
	    $json='{"lineas": '.trim(array2json($filas)).' }';
		if(!ob_start("ob_gzhandler")) ob_start();
	    echo prettyPrint($json);
	   
	   
	   
	   $bd->cerrar_bd();
	   return $filas;
	   
	  
		}
	}
	
	
	function marcas_webservices()
	{
		
			  $bd = new control;
			  
			  if(!$bd->abrir_bd())
				return -1;
		
			  $sql      = "SELECT * FROM tcolores";
			
			  $cursor   = $bd->ejecutar_sql($sql);
			  $contador = 0;
		
			  if ($row = $bd->proximafila($cursor))
			  {
					DO
					{
						
						$filas [$contador]["cid_color"] = $row["cid_color"];			
						$filas [$contador]["cdescripci"] = $row["cdescripci"];	
									   
					   $contador++;
					}
					WHILE ($row = $bd->proximafila($cursor));
			   }
				$json='{"marcas": '.trim(array2json($filas)).' }';
				if(!ob_start("ob_gzhandler")) ob_start();
				echo prettyPrint($json);
			   
			   $bd->cerrar_bd();
			   return $filas;	   
	  
		
	}
	function vendedores_webservices()
	{
	
			  $bd = new control;
			  
			  if(!$bd->abrir_bd())
				return -1;
		
			  $sql      = "SELECT * FROM tvendedores";
			
			  $cursor   = $bd->ejecutar_sql($sql);
			  $contador = 0;
		
			  if ($row = $bd->proximafila($cursor))
			  {
					DO
					{
						
						$filas [$contador]["cid_vende"] = $row["cid_vende"];			
						$filas [$contador]["cnombrev"] = $row["cnombrev"];	
									   
					   $contador++;
					}
					WHILE ($row = $bd->proximafila($cursor));
			   }
				$json='{"vendedores": '.trim(array2json($filas)).' }';
				if(!ob_start("ob_gzhandler")) ob_start();
				echo prettyPrint($json);
			   
			   $bd->cerrar_bd();
			   return $filas;	   
	  
		
	}
	
	function iva_webservices()
	{
		
			  $bd = new control;
			  
			  if(!$bd->abrir_bd())
				return -1;
		
			  $sql      = "SELECT * FROM tcontroles";
			
			  $cursor   = $bd->ejecutar_sql($sql);
			  $contador = 0;
		
			  if ($row = $bd->proximafila($cursor))
			  {
					DO
					{						
					   $filas [$contador]["niva"] = $row["niva"];
					   $filas [$contador]["cid_vende"] = $row["cid_vende"];									   
					   $contador++;
					}
					WHILE ($row = $bd->proximafila($cursor));
			   }
			  // echo print_r($filas);
			 // echo print_r(array_keys($filas));
			  $json='{"controles": '.trim(array2json($filas)).' }';
				if(!ob_start("ob_gzhandler")) ob_start();
				echo prettyPrint($json);		   
			   
			   
			  $bd->cerrar_bd();
			  return $filas;	   
	  
		
	}
	
	
// ----------  finaliza funcion consultar cliente 
//--------------------------------------------------------------------
//       Funci�n modificar Cliente
//--------------------------------------------------------------------


	
	}// fin de la clase articulo

class vendedores
{
		function listado_vendedores()
		{
			  $bd = new control;
			  
			  if(!$bd->abrir_bd())
				return -1;
		
			  $sql      = "SELECT cid_vende,cnombrev FROM tvendedores";
			
			  $cursor   = $bd->ejecutar_sql($sql);
			  return $cursor;
		}
}
class lineas
{

	function listadolineas()
	{
	$bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;

	  $sql      = "SELECT * FROM tlineas order by cdescripci";
	  
	  $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;

	  if ($row = $bd->proximafila($cursor))
	  {
			DO
			{
			 $filas [$contador][1] = $row["cid_linea"];
			  	$filas [$contador][2] = $row["cdescripci"];
				   
			   $contador++;
			}
			WHILE ($row = $bd->proximafila($cursor));
	   }
	   $bd->cerrar_bd();
	   return $filas;
	   
	  
	
	}

}
class cxc
{

	function cxc_webservices($valor)
	{
		$dia=date("z")."  ";
		//echo $dia;
		//echo $valor;
		if(($valor/54321)==($dia+1)){
		
	$bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;

	  $sql      = "SELECT * FROM tdocumentos_cxc";
	
	  $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;

	  if ($row = $bd->proximafila($cursor))
	  {
			DO
			{
				
				$filas [$contador]["cid_doccxc"] = $row["cid_doccxc"];			
				$filas [$contador]["cid_tipo_d"] = $row["cid_tipo_d"];	
			  	$filas [$contador]["cid_clien"] = $row["cid_clien"];
			  	$filas [$contador]["dfecha"] = $row["dfecha"];
				$filas [$contador]["dfecha_ven"] = $row["dfecha_ven"];
				$filas [$contador]["nsaldo"] = $row["nsaldo"];
				$filas [$contador]["cid_vende"] = $row["cid_vende"];
				$filas [$contador]["nimpuesto"] = $row["nimpuesto"];
				$filas [$contador]["nbase"] = $row["nbase"];
				$filas [$contador]["ntasa_iva"] = $row["ntasa_iva"];
				$filas [$contador]["nmonto_h"] = $row["nmonto_h"];
				$filas [$contador]["nmonto_d"] = $row["nmonto_d"];
			
			// $filas [$contador][1] = $row["cid_linea"];
			  //	$filas [$contador][2] = $row["cdescripci"];
				   
			   $contador++;
			}
			WHILE ($row = $bd->proximafila($cursor));
	   }
	    $json='{"cxc": '.trim(array2json($filas)).' }';
		if(!ob_start("ob_gzhandler")) ob_start();
	    echo prettyPrint($json);
	   
	   
	   
	   $bd->cerrar_bd();
	   return $filas;
	   
	  
		}
	}
	function cxc_tipos()
	{
		
		
	$bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;

	  $sql      = "SELECT * FROM ttipos_documentocxc";
	   
	  $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;

	  if ($row = $bd->proximafila($cursor))
	  {
			DO
			{
				
				$filas [$contador]["cid_tipod"] = $row["cid_tipod"];			
				$filas [$contador]["cdescripci"] = $row["cdescripci"];	
			  	$filas [$contador]["lsuma"] = $row["lsuma"];
			  	$filas [$contador]["cabreviado"] = $row["cabreviado"];
				$filas [$contador]["ndias_ven"] = $row["ndias_ven"];
				$filas [$contador]["liva_reten"] = $row["liva_reten"];
				$filas [$contador]["lnotacr"] = $row["lnotacr"];
				
			
			// $filas [$contador][1] = $row["cid_linea"];
			  //	$filas [$contador][2] = $row["cdescripci"];
				   
			   $contador++;
			}
			WHILE ($row = $bd->proximafila($cursor));
	   }
	    $json='{"tipos_cxc": '.trim(array2json($filas)).' }';
		if(!ob_start("ob_gzhandler")) ob_start();
	    echo prettyPrint($json);
	   
	   
	   
	   $bd->cerrar_bd();
	   return $filas;
	   
	  
		
	}
	
	function devoluciones_webservices($vendedor)
	{
		$dia=date("z")."  ";
		//echo $dia;
		//echo $valor;
		//if(($valor/54321)==($dia+1)){
		
			  $bd = new control;
			  
			  if(!$bd->abrir_bd())
				return -1;
		
			  $sql      = "SELECT cid_dev_v,cid_factu,cid_clien,cid_vende,dfecha,cid_status,ntasa_iva,nbase_iva,nmonto_ti,nmonto_t FROM tdevoluciones_venta where trim(cid_vende)=$vendedor";
			
			  $cursor   = $bd->ejecutar_sql($sql);
			  $contador = 0;
		
			  if ($row = $bd->proximafila($cursor))
			  {
					DO
					{
						$filas2 [$contador]["cid_dev_v"] = $row["cid_dev_v"];
						$filas2 [$contador]["cid_factu"] = $row["cid_factu"];
						$filas2 [$contador]["cid_clien"] = $row["cid_clien"];
						$filas2 [$contador]["cid_vende"] = $row["cid_vende"];
						$filas2 [$contador]["dfecha"] = $row["dfecha"];
						$filas2 [$contador]["cid_status"] = $row["cid_status"];
						$filas2 [$contador]["ntasa_iva"] = $row["ntasa_iva"];
						$filas2 [$contador]["nbase_iva"] = $row["nbase_iva"];
						$filas2 [$contador]["nmonto_ti"] = $row["nmonto_ti"];
						$filas2 [$contador]["nmonto_t"] = $row["nmonto_t"];					
								   
					   $contador++;
					  
					}
					WHILE ($row = $bd->proximafila($cursor));
			   }
				$json='{"devoluciones": '.trim(array2json($filas2)).' }';
				//ob_start('ob_gzhandler');
				if(!ob_start("ob_gzhandler")) ob_start();
				echo prettyPrint($json);
				
			   $bd->cerrar_bd();
			   return $filas2;	
		//}
	  
		
	}
	function devoluciones_det_webservices($vendedor)
	{
		$dia=date("z")."  ";
		//echo $dia;
		//echo $valor;
		//if(($valor/54321)==($dia+1)){
		

		$bd = new control;
			  
			  if(!$bd->abrir_bd())
				return -1;
		
			$sql2      = "SELECT cid_clien FROM tclientes where trim(cid_vende)='$vendedor'";
			
					//echo $sql2."<br>";
					$cursor2=NULL;
					$row2=NULL;
			  $cursor2   = $bd->ejecutar_sql($sql2);
			  $contador2 = 0;
			  $contageneral=0;
			  if ($row2 = $bd->proximafila($cursor2))
			  {
					DO
					{
						
						$filas2 [$contador2]["cid_clien"] = $row2["cid_clien"];	
			
		
					$sql="";
					$sql =  "SELECT tdetalles_devolucion_venta.cid_dev_v,tdetalles_devolucion_venta.cid_produc,tdetalles_devolucion_venta.ncantidad,tdetalles_devolucion_venta.nprecio,tdetalles_devolucion_venta.nmonto,tdetalles_devolucion_venta.ndescuento";
					$sql = $sql." FROM tdetalles_devolucion_venta INNER JOIN tdevoluciones_venta on trim(tdetalles_devolucion.cid_dev_v)=trim(tdevoluciones_venta.cid_dev_v)";
					$sql = $sql." inner join tclientes on trim(tclientes.cid_clien)=trim(tdevoluciones_venta.cid_clien)";
					$sql = $sql." WHERE trim(tclientes.cid_clien)='".trim($row2["cid_clien"])."'";
					$sql = $sql." tdetalles_devolucion_venta.cid_dev_v,tdetalles_devolucion_venta.cid_produc,tdetalles_devolucion_venta.ncantidad,tdetalles_devolucion_venta.nprecio,tdetalles_devolucion_venta.nmonto,tdetalles_devolucion_venta.ndescuento";
					
					//echo $sql."<br>";
					$cursor=NULL;
					  $cursor   = $bd->ejecutar_sql($sql);
					
					if ($contageneral==0)
					{
						$contador=0;
					}
					else
					{
						 $contador = $contageneral+1;
					}
					 
					  
						$row=NULL;
					  if ($row = $bd->proximafila($cursor))
					  {
							DO
							{						
								$filas [$contador]["cid_dev_v"] = $row["cid_dev_v"];			
								$filas [$contador]["cid_produc"] = $row["cid_produc"];	
								$filas [$contador]["ncantidad"] = $row["ncantidad"];
								$filas [$contador]["nprecio"] = $row["nprecio"];
								$filas [$contador]["nmonto"] = $row["nmonto"];	
								$filas [$contador]["ndescuento"] = $row["ndescuento"];
											   
							   $contador++;
							}
							WHILE ($row = $bd->proximafila($cursor));
							  $contageneral=$contageneral+1;
					   }
					   
					   
					  }
							WHILE ($row2 = $bd->proximafila($cursor2));
				} 
					   
					   
						$json='{"devoluciones_det": '.trim(array2json($filas)).' }';
						//ob_start('ob_gzhandler');
						if(!ob_start("ob_gzhandler")) ob_start();
						echo prettyPrint($json);						
					
										   
					   $bd->cerrar_bd();
					   return $filas;	   
	
		
		
	}
	
	function facturas_webservices($vendedor)
	{
		$dia=date("z")."  ";
		//echo $dia;
		//echo $valor;
		//if(($valor/54321)==($dia+1)){
		
			  $bd = new control;
			  
			  if(!$bd->abrir_bd())
				return -1;
		
			  $sql      = "SELECT cid_factu,cid_clien,cid_vende,dfecha,cid_status,ntasa_iva,nbase_iva,nmontoti,nmontotal FROM tfacturas where trim(cid_vende)='$vendedor'";
			
			  $cursor   = $bd->ejecutar_sql($sql);
			  $contador = 0;
		
			  if ($row = $bd->proximafila($cursor))
			  {
					DO
					{
						$filas2 [$contador]["cid_factu"] = $row["cid_factu"];
						$filas2 [$contador]["cid_clien"] = $row["cid_clien"];
						$filas2 [$contador]["cid_vende"] = $row["cid_vende"];
						$filas2 [$contador]["dfecha"] = $row["dfecha"];
						$filas2 [$contador]["cid_status"] = $row["cid_status"];
						$filas2 [$contador]["ntasa_iva"] = $row["ntasa_iva"];
						$filas2 [$contador]["nbase_iva"] = $row["nbase_iva"];
						$filas2 [$contador]["nmontoti"] = $row["nmontoti"];
						$filas2 [$contador]["nmontotal"] = $row["nmontotal"];					
								   
					   $contador++;
					  
					}
					WHILE ($row = $bd->proximafila($cursor));
			   }
				$json='{"facturas": '.trim(array2json($filas2)).' }';
				//ob_start('ob_gzhandler');
				if(!ob_start("ob_gzhandler")) ob_start();
				echo prettyPrint($json);
				
			   $bd->cerrar_bd();
			   return $filas2;	
		//}
	  
		
	}
	function facturas_det_webservices($vendedor)
	{
		$dia=date("z")."  ";
		//echo $dia;
		//echo $valor;
		//if(($valor/54321)==($dia+1)){
		
			  $bd = new control;
			  
			  if(!$bd->abrir_bd())
				return -1;
		
			$sql2      = "SELECT cid_clien FROM tclientes where trim(cid_vende)='$vendedor'";
			
					//echo $sql2."<br>";
					$cursor2=NULL;
					$row2=NULL;
			  $cursor2   = $bd->ejecutar_sql($sql2);
			  $contador2 = 0;
			  $contageneral=0;
			  if ($row2 = $bd->proximafila($cursor2))
			  {
					DO
					{
						
						$filas2 [$contador2]["cid_clien"] = $row2["cid_clien"];	
			
					$sql="";
					$sql =  "SELECT tdetalles_factura.cid_factu,tdetalles_factura.cid_produc,tdetalles_factura.ncantidad,tdetalles_factura.nprecio,tdetalles_factura.nmonto,tdetalles_factura.ndescuento";
					$sql = $sql." FROM tdetalles_factura inner join tfacturas on trim(tfacturas.cid_factu)=trim(tdetalles_factura.cid_factu)";
					$sql = $sql." inner join tclientes on trim(tclientes.cid_clien)=trim(tfacturas.cid_clien)";
					$sql = $sql." WHERE trim(tclientes.cid_clien)='".trim($row2["cid_clien"])."'";
					$sql = $sql." group by tdetalles_factura.cid_factu,tdetalles_factura.cid_produc,tdetalles_factura.ncantidad,tdetalles_factura.nprecio,tdetalles_factura.nmonto,tdetalles_factura.ndescuento";
					
					//echo $sql."<br>";
					$cursor=NULL;
					  $cursor   = $bd->ejecutar_sql($sql);
					
					if ($contageneral==0)
					{
						$contador=0;
					}
					else
					{
						 $contador = $contageneral+1;
					}
					 
					  
						$row=NULL;
					  if ($row = $bd->proximafila($cursor))
					  {
							DO
							{						
								$filas [$contador]["cid_factu"] = $row["cid_factu"];			
								$filas [$contador]["cid_produc"] = $row["cid_produc"];	
								$filas [$contador]["ncantidad"] = $row["ncantidad"];
								$filas [$contador]["nprecio"] = $row["nprecio"];
								$filas [$contador]["nmonto"] = $row["nmonto"];	
								$filas [$contador]["ndescuento"] = $row["ndescuento"];
											   
							   $contador++;
							}
							WHILE ($row = $bd->proximafila($cursor));
							  $contageneral=$contageneral+1;
					   }
					   
					   
					  }
							WHILE ($row2 = $bd->proximafila($cursor2));
				} 
					   
					   
						$json='{"facturas_det": '.trim(array2json($filas)).' }';
						//ob_start('ob_gzhandler');
						if(!ob_start("ob_gzhandler")) ob_start();
						echo prettyPrint($json);						
					
										   
					   $bd->cerrar_bd();
					   return $filas;	   
			  
		//}
	}

}


class clientes  
{
//--------------------------------------------------------------------
//       Funci�n incluir cliente
//--------------------------------------------------------------------
	function incluircliente()
	{
		$bd       = new control;
		if (!$bd->abrir_bd())
		    return 0;
		else
		{
		$sql = "INSERT INTO `tclientes` (`cid_cliente`, `cnombre`, `capellido`, `csexo`, `cnacionalidad`, `crif`, `dfechaalta`, `cdireccion`, `ctelefono`, `cfax`, `cmovil`, `cweb`, `cemail`, `ccuenta`, `cnombrebanco`, `cobservaciones`, `cstatus`) VALUES ('$this->cedula', '$this->nombre', '$this->apellido', '$this->sexo', '$this->nacionalidad', '$this->rif', CURDATE(), '$this->direccion','$this->telefono', '$this->fax', '$this->movil', '$this->web', '$this->email', '$this->cuenta', '$this->nombrebanco', '$this->observaciones', '$this->cstatus')";				
		  $cursor   = $bd->ejecutar_sql($sql);
		  $bd->cerrar_bd();
		  if ($cursor>0)
		  {
		  return ($cursor);
		  }
		  else
			return 0;
		}  	
	} // fin de la funcion incluir
	// ------------------ funciones set 
		
		function setcedula($cedula)
	{
	   $this->cedula = $cedula;
	}
	function setnombre($nombre)
	{
	   $this->nombre = $nombre;
	}
	function setapellido($apellido)
	{
	   $this->apellido = $apellido;
	}
	function setsexo($sexo)
	{
	   $this->sexo = $sexo;
	}
	function setnacionalidad($nacionalidad)
	{
	   $this->nacionalidad = $nacionalidad;
	}
	function setnif($rif)
	{
	   $this->rif = $rif;
	}
	function setfechaalta($fechaalta)
	{
	   $this->fechaalta = $fechaalta;
	}
	function setdireccion($direccion)
	{
	   $this->direccion = $direccion;
	}
	function settelefono($telefono)
	{
	   $this->telefono = $telefono;
	}
	function setfax($fax)
	{
	   $this->fax = $fax;
	}
	function setmovil($movil)
	{
	   $this->movil = $movil;
	}
	function setweb($web)
	{
	   $this->web = $web;
	}
	function setemail($email)
	{
	   $this->email = $email;
	}
	function setcuenta($cuenta)
	{
	   $this->cuenta = $cuenta;
	}
	function setobservaciones($observaciones)
	{
	   $this->observaciones = $observaciones;
	}	
	function setrubro($rubro)
	{
	   $this->rubro = $rubro;
	}
	function setnombrebanco($nombrebanco)
	{
	   $this->nombrebanco = $nombrebanco;
	} 
	//--- fin de la funcion set
	
	//--------------------------------------------------------------------
//       Metodo consultar Registro de usuarios
//--------------------------------------------------------------------
	function visitas_webservices($valor)
	{
		$dia=date("z")."  ";
		//echo $dia;
		//echo $valor;
		//if(($valor/54321)==($dia+1)){
		
	$bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;

	  $sql      = "SELECT * FROM tvisitas_empresa";
	
	  $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;

	  if ($row = $bd->proximafila($cursor))
	  {
			DO
			{
				
				$filas [$contador]["cid_clien"] = $row["cid_clien"];			
				$filas [$contador]["cid_vende"] = $row["cid_vende"];	
			  	$filas [$contador]["dfecha_v"] = $row["dfecha_v"];
			  	$filas [$contador]["mobservaci"] = $row["mobservaci"];
				$filas [$contador]["cid_status"] = $row["cid_status"];
				$filas [$contador]["lsincronizado"] = $row["lsincronizado"];
						
			// $filas [$contador][1] = $row["cid_linea"];
			  //	$filas [$contador][2] = $row["cdescripci"];
				   
			   $contador++;
			}
			WHILE ($row = $bd->proximafila($cursor));
	   }
	    $json='{"visitas": '.trim(array2json($filas)).' }';
		//if(!ob_start("ob_gzhandler")) ob_start();
	    echo prettyPrint($json);
		
	   
	   
	   
	   $bd->cerrar_bd();
	   return $filas;
	   
	  
		//}
	}
  function consultar($codigo)
	{
	  $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;

	  $sql      = "SELECT * FROM tclientes  WHERE trim(cid_clien) = '$codigo'";
	  $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;
	  
	  //if ($row = $bd->proximafila($cursor))
	  //{
			 
		//	 	$filas [$contador][1] = $row["cid_cliente"];
		//	  	$filas [$contador][2] = $row["cnombre"];
 		//	  	$filas [$contador][3] = $row["crif"];
		//	  	$filas [$contador][4] = $row["dfechaalta"];
		//		$filas [$contador][5] = $row["cdireccion"];				
		//	    $filas [$contador][8] = $row["ctelefono"];
		//		$filas [$contador][9] = $row["cfax"];
		//	   	$filas [$contador][10] = $row["cmovil"];
		//	   	$filas [$contador][11] = $row["cweb"];
		//	    $filas [$contador][12] = $row["cemail"];
		//		$filas [$contador][13] = $row["ccuenta"];
		//	   	$filas [$contador][14] = $row["cobservaciones"];			   
		//	   	$filas [$contador][17] = $row["cnombrebanco"]; 
		//		$filas [$contador][18] = $row["capellido"];
		//		$filas [$contador][19] = $row["csexo"];
		//		$filas [$contador][20] = $row["cnacionalidad"];
				
		//	   	$contador++;
	  // }
	   $bd->cerrar_bd();
	   return $cursor;
	}//--- fin de la funcion consultar 
	
	function modificarclientetatus($cedula,$status)
	{
	  $bd       = new control;
 	  if(!$bd->abrir_bd())
	     return 0;
	  else
	  {
	  
	  		$sql= "UPDATE `tclientes` SET `cstatus` = '$status' WHERE cid_cliente = '$cedula' ";
		
		$cursor   = $bd->ejecutar_sql($sql);
	
		$bd->cerrar_bd();
		  if ($cursor>0)
		       return ($cursor);
			else
			   return 0;
		}  	
	}// 
	function clientes_vendedor($vendedor)
	{
	  $bd       = new control;
 	  if(!$bd->abrir_bd())
	     return 0;
	  else
	  {
	  
	  		$sql= "select * from tclientes WHERE trim(cid_vende) = '$vendedor' order by CAST(cid_clien AS DECIMAL)";

		$cursor   = $bd->ejecutar_sql($sql);
		
		
		
		
		
	
		$bd->cerrar_bd();
		  if ($cursor>0)
		       return ($cursor);
			else
			   return 0;
		}  	
	}// 
	
	function clientes_webservices($vendedor)
	{
		$bd       = new control;
 	  if(!$bd->abrir_bd())
	     return 0;
	  else
	  {
		    $contador = 0;
	  
	  		$sql= "select * from tclientes WHERE cid_vende ='$vendedor' order by CAST(cid_clien AS DECIMAL)";

		$cursor   = $bd->ejecutar_sql($sql);
		
		if ($row = $bd->proximafila($cursor))
	  {
			 DO
			 {
			  	$filas [$contador]["cid_clien"] = $row["cid_clien"];			
				$filas [$contador]["cnombre_cl"] = utf8_encode($row["cnombre_cl"]);			
			  	$filas [$contador]["cdir_cli1"] = $row["cdir_cli1"];
			  	$filas [$contador]["cdir_cli2"] = $row["cdir_cli2"];
				$filas [$contador]["cid_ciudac"] = $row["cid_ciudac"];
				$filas [$contador]["cid_estadc"] = $row["cid_estadc"];
				$filas [$contador]["cid_ciudac"] = $row["cid_ciudac"];			   
			    $filas [$contador]["crif_cli"] = $row["crif_cli"];
				$filas [$contador]["ctele_cli"] = $row["ctele_cli"];
			    $filas [$contador]["ccelu_cli"] = $row["ccelu_cli"];
				$filas [$contador]["ce_mail"] = utf8_encode($row["ce_mail"]);
				$filas [$contador]["nsaldo_a"] = utf8_encode($row["nsaldo_a"]);
			   	$filas [$contador]["cid_vende"] = $row["cid_vende"];
			   	$filas [$contador]["lactivo"] = $row["lactivo"];
			    $filas [$contador]["lcredito"] = $row["lcredito"];
				$filas [$contador]["nlimite_c"] = $row["nlimite_c"];
				$filas [$contador]["cid_tipo_p"] = $row["cid_tipo_p"];
				
			   	//echo json_encode($filas[$contador]);
				//echo json_encode( $row["cid_clien"]);
				
			   $contador++;
	   	 }
			WHILE ($row = $bd->proximafila($cursor));
	   }
	 
	   $json='{"clientes": '.trim(array2json($filas)).' }';
	   if(!ob_start("ob_gzhandler")) ob_start();
	  echo prettyPrint($json);
	    
	   $bd->cerrar_bd();
		  if ($contador>0)
		       return ($filas);
			else
			   return 0;
		}  	
	}
	
	
	
	function clientes_administrador()
	{
	  $bd       = new control;
 	  if(!$bd->abrir_bd())
	     return 0;
	  else
	  {
	  
	  		$sql= "select * from tclientes order by CAST(cid_clien AS DECIMAL)";

		$cursor   = $bd->ejecutar_sql($sql);
	
		$bd->cerrar_bd();
		  if ($cursor>0)
		       return ($cursor);
			else
			   return 0;
		}  	
	}// 
	function listado_clientes($nombre)
	{
	  $bd       = new control;
 	  if(!$bd->abrir_bd())
	     return 0;
	  else
	  {
	  
	  		$sql= "select * from tclientes where cnombre_cl like '%$nombre%'";

		$cursor   = $bd->ejecutar_sql($sql);
	
		$bd->cerrar_bd();
		  if ($cursor>0)
		       return ($cursor);
			else
			   return 0;
		}  	
	}// 
		
	//--------------------------------------------------------------------
//       Metodo consultar Cliente
//--------------------------------------------------------------------
  function consultarcliente($campo,$valor)
	{
	  $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;
	if($campo!=""){
	  $sql      = "SELECT * FROM tclientes WHERE $campo LIKE '$valor%'";
      $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;

	  if ($row = $bd->proximafila($cursor))
	  {
			 DO
			 {
			 	$filas [$contador][1] = $row["cid_cliente"];
			  	$filas [$contador][2] = $row["cnombre"];
 			  	$filas [$contador][3] = $row["crif"];
			  	$filas [$contador][4] = $row["dfechaalta"];
				$filas [$contador][5] = $row["cdireccion"];
			   
			    $filas [$contador][8] = $row["ctelefono"];
				$filas [$contador][9] = $row["cfax"];
			   	$filas [$contador][10] = $row["cmovil"];
			   	$filas [$contador][11] = $row["cweb"];
			    $filas [$contador][12] = $row["cemail"];
				$filas [$contador][13] = $row["ccuenta"];
			   	$filas [$contador][14] = $row["cobservaciones"];
				
			   	$filas [$contador][17] = $row["cnombrebanco"]; 
				     $filas [$contador][18] = $row["capellido"];
				   $filas [$contador][19] = $row["csexo"];
				     $filas [$contador][20] = $row["cnacionalidad"];
					  $filas [$contador][21] = $row["cstatus"];
			
			   $contador++;
			   }
			WHILE ($row = $bd->proximafila($cursor));
	   }}
	   $bd->cerrar_bd();
	   return $filas;
	}
	function consultarcliente1($campo)
	{
	 $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;

	  $sql      = "SELECT * FROM tclientes WHERE $campo like '$valor%'";
	  $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;

	  if ($row = $bd->proximafila($cursor))
	  {
			  $filas [$contador][1] = $row["cid_cliente"];
			  	$filas [$contador][2] = $row["cnombre"];
 			  	$filas [$contador][3] = $row["crif"];
			  	$filas [$contador][4] = $row["dfechaalta"];
				$filas [$contador][5] = $row["cdireccion"];
			   
			    $filas [$contador][8] = $row["ctelefono"];
				$filas [$contador][9] = $row["cfax"];
			   	$filas [$contador][10] = $row["cmovil"];
			   	$filas [$contador][11] = $row["cweb"];
			    $filas [$contador][12] = $row["cemail"];
				$filas [$contador][13] = $row["ccuenta"];
			   	$filas [$contador][14] = $row["cobservaciones"];
				
			   	$filas [$contador][17] = $row["cnombrebanco"]; 
				     $filas [$contador][18] = $row["capellido"];
				   $filas [$contador][19] = $row["csexo"];
				     $filas [$contador][20] = $row["cnacionalidad"];
					  $filas [$contador][21] = $row["cstatus"];
			   $contador++;
	   }
	   $bd->cerrar_bd();
	   return $filas;
	}
	
 	
	function estado_cuenta($cliente)
	{
			  $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;
		

	  $sql      = "SELECT * FROM (tclientes left join tdocumentos_cxc on trim(tclientes.cid_clien)=trim(tdocumentos_cxc.cid_clien)) left join ttipos_documentocxc on tdocumentos_cxc.cid_tipo_d=ttipos_documentocxc.cid_tipod WHERE trim(tclientes.cid_clien)='$cliente'";
	  
	
	  $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;
	
	   $bd->cerrar_bd();
	   return $cursor;
	}
	function saldo($cliente)
	{
			  $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;

	  $sql      = "SELECT sum(nsaldo) as saldo FROM (tclientes left join tdocumentos_cxc on trim(tclientes.cid_clien)=trim(tdocumentos_cxc.cid_clien)) left join ttipos_documentocxc on tdocumentos_cxc.cid_tipo_d=ttipos_documentocxc.cid_tipod WHERE trim(tclientes.cid_clien)='$cliente'";
	  $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;
	
	   $bd->cerrar_bd();
	   return $cursor;
	}

}// fin de la clase cliente


//Inicio de clase Usuario
 //--------------------------------------------------------------------
  class usuario
  { 
  

function verificar($cLogin,$cPassword)
{
	
	  $bd       = new control;
	  if(trim($cLogin)<>"" and trim($cPassword)<>"")
	  {
		  if(!$bd->abrir_bd())
			return -1;
			
		  $sql      = "SELECT * FROM tusuarios,tdetalles_usuario WHERE tusuarios.clogin=tdetalles_usuario.clogin and tusuarios.clogin='$cLogin' and ccontrasena='$cPassword'";
	
		  $cursor   = $bd->ejecutar_sql($sql);

		  $contador = 0;					
							   $bd->cerrar_bd();							 
							   return $cursor;		 
			}					
			else
			{
					?>
<script language="JavaScript">
								alert("Error Debe colocar Login y Password ");
								var pagina="index.php"
								location.href=pagina			
					</script>
<?php
		     }
}

     
 
 
//--------------------------------------------------------------------
//       Funci�n incluir usuario
//--------------------------------------------------------------------
	function incluir($Login,$Contrasena,$Nombres,$Apellidos,$id_tipo_usuario,$Status,$cliente,$cargo)
	{
		$bd       = new control;
		if (!$bd->abrir_bd())
		    return 0;
		else
		{
			
			$Datos=$this->razonsocial($cliente);
			$Razon=strtoupper($Datos[0][1]);
			$Rif=strtoupper($Datos[0][2]);
			$Vendedor=strtoupper($Datos[0][3]);
			
		  $sql= "insert into tusuarios(cLogin,cContrasena,cRif,cNombres,cApellidos,cRazonSocial,cid_tipo_usuario,cStatus,cid_vende) values(Ucase('$Login'),Ucase('$Contrasena'),'$Rif',Ucase('$Nombres'),Ucase('$Apellidos'),'$Razon',Ucase('$id_tipo_usuario'),Ucase('$Status'),Ucase('$cliente'))";
		  
		  $cursor   = $bd->ejecutar_sql($sql);
		  	unset($cursor);
		   $sql= "insert into tdetalles_usuario(cLogin,cid_clien,ccargo) values(Ucase('$Login'),Ucase('$cliente'),Ucase('$cargo'))";
		  
		  $cursor   = $bd->ejecutar_sql($sql);
		  $bd->cerrar_bd();
		  if ($cursor>0){
		  		header('Location: http://www.felcas.com.ve/crear_usuarios_consulta.php');
		       return ($cursor);
		  }
			else
			   return 0;
		}  	
	} // fin de la funcion incluir
	// ------------------ funciones set 
	
	function razonsocial($id){
	  $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;

	  $sql      = "SELECT cnombre_cl,crif_cli,cid_vende FROM tclientes WHERE cid_clien = $id";
	  
	  $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;
		if ($row = $bd->proximafila($cursor))
	    {			 
			$filas [$contador][1] = $row["cnombre_cl"];
			$filas [$contador][2] = $row["crif_cli"];
			$filas [$contador][3] = $row["cid_vende"];
			$contador++;
	    }
	  // $bd->cerrar_bd();
	   return $filas;
	}
	
	
		function setcedula($cedula)
	{
	   $this->cedula = $cedula;
	}
	function setnombre($nombre)
	{
	   $this->nombre = $nombre;
	}
	function setapellido($apellido)
	{
	   $this->apellido = $apellido;
	}
	function setdireccion($direccion)
	{
	   $this->direccion = $direccion;
	}
	function setnacionalidad($nacionalidad)
	{
	   $this->nacionalidad = $nacionalidad;
	}
	function settipoUsuario($tipoUsuario)
	{
	   $this->tipoUsuario = $tipoUsuario;
	}
	function setlogin($login)
	{
	   $this->login = $login;
	}
	function setpassword($password)
	{
	   $this->password = $password;
	}
	function setemail($email)
	{
	   $this->email = $email;
	}
	function settelefono($telefono)
	{
	   $this->telefono = $telefono;
	}
	function setpregunta($pregunta)
	{
	   $this->pregunta = $pregunta;
	}
	function setrespuesta($respuesta)
	{
	   $this->respuesta = $respuesta;
	}
	function setrubro($rubro)
	{
	   $this->rubro = $rubro;
	} //--- fin de la funcion set
	
	
  
  function consultar($login)
	{
	  $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;

	  $sql      = "SELECT * FROM tusuarios WHERE clogin = '$login'";
	  //echo $sql;
	  $cursor   = $bd->ejecutar_sql($sql);
	 
	  $contador = 0;
	if ($row = $bd->proximafila($cursor))
	  {		
	 		 DO
			 {	 
			   $filas [$contador][1] = $row["cLogin"];
			   $filas [$contador][2] = $row["cContrasena"];
			  
			   $filas [$contador][3] = $row["cRif"];
			   $filas [$contador][4] = $row["cNombres"];
			   $filas [$contador][5] = $row["cApellidos"];
			   $filas [$contador][6] = $row["cRazonSocial"];
		
			   $contador++;
			   }
			   WHILE ($row = $bd->proximafila($cursor));
	   }
	   $bd->cerrar_bd();
	   return $filas;
	}//--- fin de la funcion consultar 
	function yaexiste($login)
	{
	  $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;

	  $sql      = "SELECT * FROM tusuarios WHERE clogin = '$login'";
	  //echo $sql;
	  $cursor   = $bd->ejecutar_sql($sql);
	 
	  $contador = 0;
	if ($row = $bd->proximafila($cursor))
	  {		
	 		 DO
			 {	 
			
		
			   $contador++;
			   }
			   WHILE ($row = $bd->proximafila($cursor));
	   }
	   $bd->cerrar_bd();
	   
	  if ($contador>0)	  
	  	return true;
	  else
	    return false;
		
	}//--- fin de la funcion consul
	
}// -----------------fin de la clase usuario

 

   class mensaje
  { 
	var $cMensaje;
	
  }

class encuesta  
{
	
	function setid_encuesta($id_encuesta)
	{
	$this->id_encuesta=$id_encuesta;
	}
	function setid_opcion($id_opcion)
	{
	$this->id_opcion=$id_opcion;
	}
	
	function setip($ip)
	{
	$this->ip=$ip;
	}
	
	function setfecha($fecha)
	{
	$this->fecha=$fecha;
	}
	
	function votar()
	{
	
		$bd = new control;
		if (!$bd->abrir_bd())
		    return 0;
		else
		{

		$sql = "INSERT INTO tvotos (nid_encuesta, nid_opcion,cip,dfecha_voto) VALUES ($this->id_encuesta, $this->id_opcion,'$this->ip','$this->fecha')";
		//echo $sql;
		  $cursor   = $bd->ejecutar_sql($sql);
		  $bd->cerrar_bd();
		  
		  if ($cursor>0)
		  {
		  	   header('Location: http://www.felcas.com.ve');
		       return ($cursor);
		  }
			else
			{
			   header('Location: http://www.felcas.com.ve');
			   return 0;
			}
		}  	
	}//fin de function votar
	
	
	function resultado($id_encuesta)
	{
		 $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;

	  $sql      =  "SELECT tvotos.nid_opcion,cdescripcion,count(tvotos.nid_opcion) as 'votos' FROM topciones_encuesta,tvotos WHERE topciones_encuesta.nid_opcion=tvotos.nid_opcion and tvotos.nid_encuesta = $id_encuesta group by tvotos.nid_opcion";
	
	  $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;


	   $bd->cerrar_bd();
	   //return $filas;
		return $cursor;
	
	}//fin de la function resultado
	
	function mostrar_encuesta($id_encuesta)
	{
		 $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;

	  $sql      = "SELECT encuesta.nid_Encuesta as CodEncuesta,cpregunta,nid_opcion,cdescripcion FROM encuesta,topciones_encuesta WHERE encuesta.nid_encuesta=topciones_encuesta.nid_encuesta and encuesta.nid_encuesta = $id_encuesta order by topciones_encuesta.nid_encuesta,nid_opcion";
	  $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;
//echo $sql;
	   $bd->cerrar_bd();
	   return $cursor;
	
	}//fin de la function resultado
	
	function mostrar_pregunta($id_encuesta)
	{
		 $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;

	  $sql      = "SELECT cpregunta FROM encuesta WHERE encuesta.nid_encuesta = $id_encuesta";
	  $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;
		if ($row = $bd->proximafila($cursor))
	    {			 
			$filas [$contador][1] = $row["cpregunta"];
			$contador++;
	    }
	   $bd->cerrar_bd();
	   return $filas;
	
	}//fin de la function resultado
	
	function yavoto($id,$ip,$fecha)
	{
	  $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;

	  $sql      = "SELECT * FROM tvotos WHERE nid_encuesta=$id and cip='$ip' and dfecha_voto='$fecha'";
	
	  $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;
		//echo $sql;
	   $bd->cerrar_bd();
	   if ($cursor>0){
	   	   return true;
	   }
	   else
	   {
		   return false;
	   }
	}
		
}// fin de la clase encuesta



class noticias  
{
	
	function detalle_noticia($id)
	{
		 $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;

	  $sql      = "SELECT id_noticia,titulo_noticia,fecha, contenido_noticia FROM tnoticias where id_noticia='$id' ";
	  $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;

	  if ($row = $bd->proximafila($cursor))
	  {
			 DO
			 {
			 	$filas [$contador][1] = $row["id_noticia"];
			  	$filas [$contador][2] = $row["titulo_noticia"];
 			  	$filas [$contador][3] = $row["fecha"];
				$filas [$contador][4] = $row["contenido_noticia"];
			   	$contador++;
			  }
			WHILE ($row = $bd->proximafila($cursor));
	  
		
	   }
	   $bd->cerrar_bd();
	   return $filas;
	
	
	}//fin de la function resultado
	
	function mostrar_noticias($pag,$tamano)
	{
		 $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;

	  $sql      = "SELECT id_noticia,titulo_noticia,fecha, contenido_noticia FROM tnoticias WHERE status='A' order by fecha DESC LIMIT $pag,$tamano ";
	
	  $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;

	 
	   $bd->cerrar_bd();
	
	  return $cursor;
	
	
	}//fin de la function resultado
	
	
}// fin de la clase noticias

class ofertas 
{
	
	function listadoofertas($pag,$tamano)
	{
		 $bd       = new control;
 	  if(!$bd->abrir_bd())
	    return -1;

	 // $sql      = "select * from tproductos inner join tproductos_precio on  tproductos.cid_produc=tproductos_precio.cid_produc  where tproductos_precio.ctipo_pre='11' and tproductos_precio.nprecio>0 order by cdescripci LIMIT $pag,$tamano ";
	 $sql      = "select * from tproductos inner join tproductos_precio on  tproductos.cid_produc=tproductos_precio.cid_produc  where (tproductos.cclasi3='15' or tproductos.cclasi3='13') and trim(tproductos_precio.ctipo_pre)=' 1'  order by cdescripci LIMIT $pag,$tamano ";
	  $cursor   = $bd->ejecutar_sql($sql);
	  $contador = 0;
	 
//echo $sql;
	  //if ($row = $bd->proximafila($cursor))
	  //{
		//	 DO
		//	 {
			// 	$filas [$contador][1] = $row["id_noticia"];
			//  	$filas [$contador][2] = $row["titulo_noticia"];
 			//  	$filas [$contador][3] = $row["fecha"];
			//	$filas [$contador][4] = $row["contenido_noticia"];
			//   	$contador++;
			//  }
			//WHILE ($row = $bd->proximafila($cursor));
	  
		
	   //}
	   $bd->cerrar_bd();
	   return $cursor;
	
	
	}//fin de la function resultado
	

	
}// fin de la clase noticias
function getRealIP()
{
 
   if( $_SERVER['HTTP_X_FORWARDED_FOR'] != '' )
   {
      $client_ip =
         ( !empty($_SERVER['REMOTE_ADDR']) ) ?
            $_SERVER['REMOTE_ADDR']
            :
            ( ( !empty($_ENV['REMOTE_ADDR']) ) ?
               $_ENV['REMOTE_ADDR']
               :
               "unknown" );
 
      // los proxys van a�adiendo al final de esta cabecera
      // las direcciones ip que van "ocultando". Para localizar la ip real
      // del usuario se comienza a mirar por el principio hasta encontrar 
      // una direcci�n ip que no sea del rango privado. En caso de no 
      // encontrarse ninguna se toma como valor el REMOTE_ADDR
 
      $entries = preg_split('/[, ]/', $_SERVER['HTTP_X_FORWARDED_FOR']);
 
      reset($entries);
      while (list(, $entry) = each($entries))
      {
         $entry = trim($entry);
         if ( preg_match("/^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/", $entry, $ip_list) )
         {
            // http://www.faqs.org/rfcs/rfc1918.html
            $private_ip = array(
                  '/^0\./',
                  '/^127\.0\.0\.1/',
                  '/^192\.168\..*/',
                  '/^172\.((1[6-9])|(2[0-9])|(3[0-1]))\..*/',
                  '/^10\..*/');
 
            $found_ip = preg_replace($private_ip, $client_ip, $ip_list[1]);
 
            if ($client_ip != $found_ip)
            {
               $client_ip = $found_ip;
               break;
            }
         }
      }
   }
   else
   {
      $client_ip =
         ( !empty($_SERVER['REMOTE_ADDR']) ) ?
            $_SERVER['REMOTE_ADDR']
            :
            ( ( !empty($_ENV['REMOTE_ADDR']) ) ?
               $_ENV['REMOTE_ADDR']
               :
               "unknown" );
   }
 
   return $client_ip;
 
}
?>
