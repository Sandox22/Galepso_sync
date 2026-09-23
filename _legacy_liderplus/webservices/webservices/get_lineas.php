<?php
include("../Librerias/misclases.php");
$listado= new articulo();
$productos=$listado->lineas_webservices($_POST['id']);
?>