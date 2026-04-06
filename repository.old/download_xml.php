<?php
include("config.inc.php"); // some constants
include("passtest.inc.php"); // checks the User/Password

// $CVS_TAG="$Id: download_xml.php,v 1.11 2012/01/05 10:09:16 gerrit Exp $";

// These are the variables 
$data_type = $_GET["type"];
$database = $_GET["db"];
$id = $_GET["id"]+0;

// Check, if there are weird symbols in the given variables
if(!preg_match('/^[a-z0-9_]+$/iD', $database)) $database = "";
if(!preg_match('/^[a-z0-9_]+$/iD', $table)) $table = "";


$connected = mysql_connect($mysql_host, $mysql_user, $mysql_pass);
if($connected) mysql_select_db($mysql_database);


if($passtest && $connected) {
	
	// Check if the user has access to this XML-File
	$query = mysql_query("SELECT select_priv FROM mysql.db WHERE user='".$_SESSION["user"]."' AND db=\"".mysql_real_escape_string($database)."\"");
	if(!$query && $debug) echo "<p class=\"error\">".mysql_error()."</p>\n";
	if(mysql_num_rows($query)) $can_access = mysql_result($query, 0, 0);
	
	// Change to that db:
	mysql_select_db($database);
	
	if($is_admin || $can_access) {
		if($data_type=="bin") $query = mysql_query("SELECT mat FROM `$database`.`bobjs` WHERE obj_id=$id");
		else $query = mysql_query("SELECT xml FROM `$database`.`objs` WHERE id=$id");
		
		// If the query is not correct (wrong parameters given)
		if(!$query) {
			// Just display a normal webpage with an error message
			$title = "Data cannot be read";
			include("header.inc.php");
			echo "<h1>The data cannot be read.</h1>\n";
			echo "<p>The data you specified cannot be found. Are you sure it exists?<br /><b>Database:</b> $database<br /><b>ID:</b> $id</p>\n";
			include("footer.inc.php");
		} else {
			
			// Here we have the actual xml data:
			$result = mysql_result($query, 0, 0);
			
			// Write a transaction:
			$query = mysql_query("INSERT INTO transactions (obj_id, user_id, transdate, direction) VALUES ($id, $passtest, \"".date("Y-m-d H:i:s")."\", \"download\")");
			
			// Now we check, how to name the file:
			$query = mysql_query("SELECT obj_type FROM objmeta WHERE obj_id=$id");
			$type = mysql_result($query,0,0);
			
			// The filename is given in the http header:
			if($data_type=="bin") {
				$filename = $database."_".$table."_".$type."_".$id.".mat";
				header("Content-type: application/octet-stream");
				header("Content-Disposition: attachment; filename=\"$filename\"");
			} else {
				$filename = $database."_".$table."_".$type."_".$id.".xml";
				header("Content-type: text/xml");
				header("Content-Disposition: attachment; filename=\"$filename\"");
			}
			
			// Output the data:
			echo $result;
		}
	} else {
		// Just display a normal webpage with an error message
		$title = "Data cannot be read";
		include("header.inc.php");
		echo "<h1>The data cannot be read.</h1>\n";
		echo "<p>You do not have the rights to view this data.</p>\n";
		include("footer.inc.php");
	}
} else {
	// Just display a normal webpage with an error message
	$title = "Data cannot be read";
	include("header.inc.php");
	echo "<h1>The data cannot be read.</h1>\n";
	echo "<p>You do not have the rights to view this data.</p>\n";
	include("footer.inc.php");
}
?>
