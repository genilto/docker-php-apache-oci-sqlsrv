<html>
<head>
<title>Testandop Conexões</title>
</head>
<body>
<p>
<center>
<b>SEU CONTAINER ESTA RODANDO!</b><br>
Configure as variáveis presentes em public/index.php para testar as conexões.<br>
Testando conexões:<br><br>
</center>
<?php

$ORACLE_HOST = "localhost";
$ORACLE_PORT = "1616";
$ORACLE_SERVICE_NAME = "TST";
$ORACLE_INSTANCE_NAME = "TST";
$ORACLE_USER = "scott";
$ORACLE_PASSWORD = "tiger";

$SQLSRV_HOST = "localhost";
$SQLSRV_PORT = "1433";
$SQLSRV_DATABASE = "database";
$SQLSRV_USER = "user";
$SQLSRV_PASSWORD = "pwd";

$dbstr ="(DESCRIPTION =(ADDRESS = (PROTOCOL = TCP)(HOST=$ORACLE_HOST)(PORT = $ORACLE_PORT))
(CONNECT_DATA =
(SERVER = DEDICATED)
(SERVICE_NAME = $ORACLE_SERVICE_NAME)
(INSTANCE_NAME = $ORACLE_INSTANCE_NAME)))";

echo "Conectando em oracle: ";
$conn = oci_connect($ORACLE_USER, $ORACLE_PASSWORD, $dbstr) or die (ocierror());
if ($conn) {
  echo "ok";
}
echo "<br><br>";
echo "Conectando em sql server: ";

/* Connect using Windows Authentication. */  
try {
  $conn = new PDO("sqlsrv:Server=$SQLSRV_HOST,$SQLSRV_PORT;Database=$SQLSRV_DATABASE", $SQLSRV_USER, $SQLSRV_PASSWORD);
  $conn->setAttribute( PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION );
  if ($conn) {
    echo "ok";
  } else {
    echo "error";
  }

} catch(Exception $e) {
  print_r( $e->getMessage() );
}
?>
</p>
<body>
</html>