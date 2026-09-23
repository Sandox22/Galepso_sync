<?php
include("../Librerias/misclases.php");
$clientes= new clientes();
$visitas=$clientes->visitas_webservices($_POST['id']);

?>