<?php
include("config.inc.php"); // some constants
include("passtest.inc.php"); // checks the User/Password

$title = "Edit database description";
// $CVS_TAG="$Id: edit_database.php,v 1.6 2011/06/14 10:07:16 mauro Exp $";
include("header.inc.php");

if($passtest && $connected) {
	
	if($is_admin) {
		// Check for weird characters:
		$database = trim($_GET["db"]);
		if(!preg_match('/^[a-z0-9_-]+$/iD', $database)) $database = "";
		if($database=="") echo "<p class=\"error\">No database given. Did you use a valid link to this page?</p>\n";
		
		echo "<h1>Edit database $database</h1>\n";
		
		// Save all data
		if($_POST["submit_database"]=="Save") {
			$database_name = $_POST["database_name"];
			$database_description = $_POST["database_description"];
			$query = mysql_query("UPDATE available_dbs SET name=\"".mysql_real_escape_string($database_name)."\", description=\"".mysql_real_escape_string($database_description)."\" WHERE db_name=\"".mysql_real_escape_string($database)."\"");
			if($query) echo "<p class=\"success\">Data saved.</p>\n";
			else if($debug) echo "<p class=\"error\">".mysql_error()."</p>\n";
		}
		
		// Get the data:
		$query = mysql_query("SELECT name, description FROM available_dbs WHERE db_name=\"".mysql_real_escape_string($database)."\"");
		if($query) {
			$database_name = mysql_result($query, 0, 0);
			$database_description = mysql_result($query, 0, 1);
		} else if($debug) echo "<p class=\"error\">".mysql_error()."</p>";
		
		// Display the data
		echo "<form action=\"edit_database.php?db=$database\" method=\"post\">\n";
		echo "<fieldset><legend>Database description</legend>\n";
		echo "<table>\n";
		echo "<tr><td>Formatted Name:</td><td><input type=\"text\" name=\"database_name\" value=\"$database_name\" size=\"30\" /></td></tr>\n";
		echo "<tr><td>Description:</td><td><textarea name=\"database_description\" cols=\"30\" rows=\"8\">$database_description</textarea></td></tr>\n";
		echo "<tr><td>Save:</td><td><input type=\"submit\" name=\"submit_database\" value=\"Save\" /></td></tr>\n";
		echo "</table>\n";
		echo "</fieldset>\n";
		echo "<form>\n";
	}
} else include("login.inc.php");

include("footer.inc.php");
?>
