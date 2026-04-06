<?php
include("config.inc.php"); // some constants

if(isset($_GET["field"])) $tablefield = $_GET["field"];
else die("No field given.");

if(isset($_GET["db"])) $db = $_GET["db"];
else die("No database given.");

$connection = mysql_connect($mysql_host, $mysql_user, $mysql_pass);
if($connection) {
	mysql_query("USE ".$db);
	$temp = explode(".", $tablefield);
	$table = $temp[0];
	$field = $temp[1];
	
	$result = mysql_query(sprintf("SHOW COLUMNS FROM %s WHERE field='%s'", mysql_real_escape_string($table), mysql_real_escape_string($field)));
	if($result) {
		$type = mysql_result($result, 0, 1);
		echo meta_type_of($type);
	} else echo "Cannot find field '$tablefield'";
}

function meta_type_of($type)
{
	if(substr($type, 0, 4)=="text") return "text";
	if(substr($type, 0, 4)=="enum") return "text";
	if(substr($type, 0, 4)=="char") return "text";
	if(substr($type, 0, 7)=="varchar") return "text";
	
	if(substr($type, 0, 4)=="time") return "text";
	if(substr($type, 0, 4)=="date") return "text";
	if(substr($type, 0, 8)=="datetime") return "text";
	
	if(substr($type, 0, 6)=="bigint") return "number";
	if(substr($type, 0, 3)=="int") return "number";
	if(substr($type, 0, 7)=="tinyint") return "number";
	if(substr($type, 0, 6)=="double") return "number";
	if(substr($type, 0, 5)=="float") return "number";
}
