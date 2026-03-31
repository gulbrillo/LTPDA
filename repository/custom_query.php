<?php
include("config.inc.php"); // some constants
include("passtest.inc.php"); // checks the User/Password

$database = $_GET["db"];

$title = "Database: " . $database;

if(!isset($_POST["query_password"])) $_POST["query_password"] = "";
if(!isset($_POST["query_data"])) $_POST["query_data"] = "";
if(!isset($_POST["query_submit"])) $_POST["query_submit"] = "";


// Set page width to 100% if query gets executed (as long as the password is corect :))
if($_POST["query_password"] && $_POST["query_data"]) $need_full_page = true;

// $CVS_TAG="$Id: custom_query.php,v 1.11 2011/12/01 12:44:08 gerrit Exp $";
include("header.inc.php");

if($passtest && $connected) {
	echo "<h1>$title</h1>";
	
	// Just to be sure.
	if(!preg_match('/^[a-z0-9_-]+$/iD', $database)) $database = "";
	$query = mysql_query("SELECT COUNT(*) FROM available_dbs WHERE db_name=\"".mysql_real_escape_string($database)."\"");
	if(!$query || !mysql_result($query, 0, 0)) die("<p class=\"error\">Could not find database.</p>\n");
	
	//$query = mysql_query("SELECT select_priv FROM user_access WHERE user_id=".$passtest." AND db_name=\"".mysql_real_escape_string($database)."\"");
	//if(!$query && $debug) echo "<p class=\"error\">".mysql_error()."</p>\n";
	//if(mysql_num_rows($query)) $can_access = mysql_result($query, 0, 0);
	//else $can_access = false;
	//if(!$can_access) "<p class=\"error\">Warning: You might not have sufficient rights to access this database!</p>\n";
	
	if(!$_POST["query_data"] || !$_POST["query_password"]) {
		$query_data = "";
		if($_SESSION["querytext"]) $query_data = $_SESSION["querytext"];
		
		// if query was changed, but password forgotten:
		if($_POST["query_data"]!="") $query_data = $_POST["query_data"];
		
		echo "<form action=\"custom_query.php?db=$database\" method=\"post\">\n";
		echo "<table>";
		echo "<tr><td>Your password:</td><td><input type=\"password\" name=\"query_password\" /></td></tr>\n";
		echo "<tr><td>Query:</td><td><textarea name=\"query_data\" rows=\"8\" cols=\"40\">$query_data</textarea></td></tr>\n";
		echo "<tr><td>Execute:</td><td><input type=\"submit\" value=\"Continue\" name=\"query_submit\" /></td></tr>\n";
		echo "</table>";
		echo "</form>\n";
		if($_POST["query_submit"]=="Continue" && !$_POST["query_password"]) echo "<p>Please enter your password.</p>";
		if($_POST["query_submit"]=="Continue" && !$_POST["query_data"]) echo "<p>Please enter a valid mysql query.</p>";
	} else {
		$query_data = $_POST["query_data"];
		$query_password = $_POST["query_password"];
		$_SESSION["querytext"] = $query_data;
		
		
		$query = mysql_query("SELECT username FROM users WHERE id=$passtest");
		$username = mysql_result($query, 0, 0);
		
		mysql_close($connected);
		$connected = mysql_connect($mysql_host, $username, $query_password);
		if(!$connected) {
			echo "<p class=\"error\">Could not connect to database. Maybe you misspelled the password?</p>";
			include("footer.inc.php");
			die();
		}
		if(!mysql_select_db($database)) echo "<p class=\"error\">Could not select database $database.</p>";
		
		
		if(substr($query_data, 0, 6)=="SELECT" || substr($query_data, 0, 11)=="SHOW TABLES" || substr($query_data, 0, 8)=="DESCRIBE") {
			echo "<p><span class=\"small\">Executed query: $query_data [<a href=\"custom_query.php?db=$database\">Edit query</a>]</span></p>";
			$query = mysql_query($query_data);
			if($query) {
				echo "<table class=\"datatable\">\n<tr>";
				for($i=0; $i<mysql_num_fields($query); $i++) echo "<th class=\"dataheader\">".mysql_field_name($query, $i)."</th>";
				echo "</tr>\n";
				while($row = mysql_fetch_array($query, MYSQL_NUM)) {
					echo "<tr>";
					foreach($row as $col) {
						$col = str_replace("<", "&lt;", $col);
						$col = str_replace(">", "&gt;", $col);
						echo "<td class=\"datafield\">".$col."</td>";
					}
					echo "</tr>\n";
				}
				echo "</table>\n";
			}
		} elseif(substr($query_data ,0, 6)=="INSERT") {
			echo "<p><span class=\"small\">Executed query: $query_data [<a href=\"custom_query.php?db=$database\">Edit query</a>]</span></p>";
			$query = mysql_query($query_data);
			if($query) echo "<p class=\"success\">Query successfully executed.</p>\n";
			else echo "<p class=\"error\">Query could not be executed: ".mysql_error()."</p>\n";
		}
	}
	
} else include("login.inc.php");

include("footer.inc.php");
?>
