<?php

include("config.inc.php"); // some constants
include("passtest.inc.php"); // checks the User/Password

// $CVS_TAG="$Id: download_dump.php,v 1.4 2011/06/14 10:07:16 mauro Exp $";

$connected = mysql_connect($mysql_host, $mysql_user, $mysql_pass);
if($connected) mysql_select_db($mysql_database);


if($passtest && $connected) {
	if($is_admin) {
		
		// Give a filename and different content-type. A download-window should appear:
		$filename = "ltpda_dump_".date("YmdHis").".sql";
		header("Content-type: text/plain");
		header("Content-Disposition: attachment; filename=\"$filename\"");
		
		// Generate some meta information:
		$query = mysql_query("SELECT COUNT(*) FROM databases");
		echo "# ##############################################################\n";
		echo "# LTPDA Dump\n";
		echo "# Version".substr($CVS_TAG, 0, strlen($CVS_TAG)-2)."\n";
		echo "# \n";
		echo "# Creation date: ".date("Y-m-d H:i:s")."\n";
		echo "# Created by: ".$_SESSION["user"]."\n";
		echo "# Admin database name: $mysql_database\n";
		echo "# \n";
		echo "# ##############################################################\n";
		
		// Also recreate the mysql user:
		if($dump_ltpda_admin) {
			mysql_select_db("mysql");
			$query = mysql_query("SELECT Host, Password FROM user WHERE User=\"$mysql_user\"");
			while($row = mysql_fetch_array($query, MYSQL_NUM)) {
				echo "INSERT INTO user (Host, Username, Password, Select_priv, Insert_priv, Update_priv, Delete_priv, Create_priv, Drop_priv, Reload_priv, Grant_priv) VALUE (\"".mysql_real_escape_string($row[0])."\", \"$mysql_user\", \"".mysql_real_escape_string($row[1])."\", \"Y\", \"Y\", \"Y\", \"Y\", \"Y\", \"Y\", \"Y\", \"Y\");\n\n";
			}
		}
		
		// List all LTPDA databases:
		$query = mysql_query("SELECT db_name FROM available_dbs ORDER BY db_name");
		while($row = mysql_fetch_array($query, MYSQL_NUM)) $dbs[] = $row[0];
		// Add the web interface database:
		$dbs[] = $mysql_database;
		
		// echo all the "create database" and "create tables"
		foreach($dbs as $current) {
			echo "\nDROP DATABASE IF EXISTS `".$current."`;\n";
			echo "CREATE DATABASE `".$current."`;\n";
			echo "USE `".$current."`;\n";
			mysql_select_db($current);
			$query = mysql_query("SHOW TABLES");
			while($table = mysql_fetch_array($query, MYSQL_NUM)) {
				//This is a nice function of mysql:
				$subquery = mysql_query("SHOW CREATE TABLE ".mysql_real_escape_string($table[0]));
				echo mysql_result($subquery, 0, 1).";\n";
			}
			echo "\n############################################################\n";
		}
		
		// Now generate all inserts for the data
		echo "\n\n#\n";
		echo "# Data of web interface tables:\n";
		echo "#\n";
		$query = mysql_query("SHOW TABLES");
		
		// Do this for every table...
		while($table = mysql_fetch_array($query, MYSQL_NUM)) {
			$subquery = mysql_query("SELECT * FROM `".mysql_real_escape_string($table[0]))."`";
			echo "\n\nINSERT INTO `".$table[0]."` VALUES ";
			
			$output = "";
			
			// ...for every row...
			while($row = mysql_fetch_array($subquery, MYSQL_NUM)) {
				$output .= "(";
				// ...for every column...
				for($i=0; $i<mysql_num_fields($subquery); $i++) {
					
					// Here be errors:
					if(isText(mysql_field_type($subquery, $i))) $output .= "\"".mysql_real_escape_string($row[$i])."\"";
					else $output .= $row[$i];
					if($i<mysql_num_fields($subquery)-1) $output .= ", ";
				}
				$output .= "), ";
			}
			$output = substr($output, 0, strlen($output)-2);
			echo $output.";";
		}
	}
} else echo "Not logged in.";

function isText($field)
{
	switch($field) {
		case "text": return true; break;
		case "varchar": return true; break;
		case "char": return true; break;
		case "int": return false; break;
		case "bigint": return false; break;
		case "smallint": return false; break;
		case "tinyint": return false; break;
		case "double": return false; break;
		default: return true;
	}
}

?>
