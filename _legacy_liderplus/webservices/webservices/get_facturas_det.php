<?php
include("../Librerias/misclases.php");
$listado= new cxc();
$cuentas=$listado->facturas_det_webservices($_POST['id']);

//$lista_clientes= new clientes();
?>