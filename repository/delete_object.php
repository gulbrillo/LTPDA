<?php
include("config.inc.php"); // some constants
include("passtest.inc.php"); // checks the User/Password

$title = "Data view";
// $CVS_TAG="$Id: delete_object.php,v 1.9 2012/01/18 19:09:41 gerrit Exp $";
include("header.inc.php");

if($passtest && $connected) {
	
	// Test database
	$database = $_POST["database"];
	if(!preg_match('/^[a-z0-9_-]+$/iD', $database)) $database = "";
	$query = mysql_query("SELECT COUNT(*) FROM available_dbs WHERE db_name=\"".mysql_real_escape_string($database)."\"");
	if(!$query || !mysql_result($query, 0, 0)) die("<p class=\"error\">Could not find database.</p>\n");
	
	// Check if user has delete_priv
	$query = mysql_query(sprintf("SELECT Delete_priv FROM mysql.db
                                      WHERE User='%s' AND Db='%s'",
                                     mysql_real_escape_string($_SESSION["user"]),
                                     mysql_real_escape_string($database)));
	
	if(($is_admin || mysql_result($query, 0, 0)==1) && $database) {
		
		// Get database layout version
		$query = mysql_query("SELECT version FROM available_dbs WHERE db_name=\"".mysql_real_escape_string($database)."\"");
		if($query) $db_version = mysql_result($query, 0, 0);
		else $db_version = 1;
		if($db_version<2) die("This script only works for newer databases. Please finish the upgrade procedure.");
		
		$delete_ids = $_POST["delete_ids"];
		foreach($delete_ids as $delete_id) {
			
			echo "Deleting object with id ".$delete_id."<br />";
			
			$query = mysql_query("DELETE FROM `".$database."`.`objs` WHERE id=".$delete_id);
			
			$query = mysql_query("INSERT INTO `".$database."`.`transactions` (obj_id, user_id, transdate, direction) VALUES ($delete_id, $passtest, \"".date("Y-m-d H:i:s")."\", \"delete\")");
		}
	}
	
} else include("login.inc.php");

include("footer.inc.php");

?>
