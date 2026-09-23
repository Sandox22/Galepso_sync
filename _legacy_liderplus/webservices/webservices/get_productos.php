<?php
include("../Librerias/misclases.php");
$listado= new articulo();
$productos=$listado->productos_webservices($_POST['id']);
?>