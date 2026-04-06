<?php
include("config.inc.php"); // some constants
include("passtest.inc.php"); // checks the User/Password

include("privs.inc.php");

$title = "Edit database rights";
// $CVS_TAG="$Id: edit_rights.php,v 1.14 2011/09/06 11:13:43 gerrit Exp $";
include("header.inc.php");

if($passtest && $connected) {
	
	$database = trim($_GET["db"]);
	if(!preg_match('/^[a-z0-9_-]+$/iD', $database)) $database = "";
	if($database=="") echo "<p class=\"error\">No database given. Did you use a valid link to this page?</p>\n";
	$query = mysql_query("SELECT name FROM available_dbs WHERE db_name=\"".mysql_real_escape_string($database)."\"");
	if($query && mysql_num_rows($query)) $database_name = mysql_result($query, 0, 0);
	
	echo "<h1>$title: $database_name</h1>\n";
	
	// Save the changes...
	if($_POST["submit_add_read"]) {
             $selected = $_POST["users_not_read"];
             if(count($selected)) {
                  foreach($selected as $current) { 
                       setpriv('SELECT', 1, $current, $database, '%');
                  }
             }
	}
	if($_POST["submit_add_write"]) {
		$selected = $_POST["users_not_write"];
		if(count($selected)) {
                     foreach($selected as $current) {
                          setpriv('INSERT', 1, $current, $database, '%');
                     }
		}
	}
	if($_POST["submit_del_read"]) {
		$selected = $_POST["users_read"];
		if(count($selected)) {
                     foreach($selected as $current) {
                          setpriv('SELECT', 0, $current, $database, '%');
                     }
		}
	}
	if($_POST["submit_del_write"]) {
		$selected = $_POST["users_write"];
		if(count($selected)) {
                     foreach($selected as $current) {
                          setpriv('INSERT', 0, $current, $database, '%');
                     }
		}
	}

	echo "<form action=\"edit_rights.php?db=$database\" method=\"post\">\n";
	echo "<fieldset><legend>Read access</legend>\n";
	echo "<table>\n<tr><th>Read access</th><th>Action</th><th>No read access</th></tr>\n";
	echo "<tr><td>";
	
	$query = mysql_query(sprintf("SELECT DISTINCT users.given_name, users.family_name, users.id, users.username
                                      FROM users, mysql.db
                                      WHERE users.username = User AND Db = '%s'
                                      AND Select_priv = 'Y'", mysql_real_escape_string($database)));
        if(!$query)
             echo "erorr";
	if(!$query && $debug) echo "<p>".mysql_error()."</p>\n";
        echo "<select name=\"users_read[]\" size=\"8\" multiple=\"multiple\">";
	while($row = mysql_fetch_array($query, MYSQL_NUM)) {
		if($row[0]=="" && $row[1]=="") $current_name = $row[3];
		elseif($row[0]=="") $current_name = $row[1];
		elseif($row[1]=="") $current_name = $row[0];
		else $current_name = $row[1].", ".$row[0];
		echo "<option value=\"".$row[3]."\">".$current_name."</option>";
	}
	
	echo "</select></td><td>";
	echo "<input type=\"submit\" size=\"8\" name=\"submit_add_read\" value=\"&lt;&lt; Add\" /><br />";
	echo "<input type=\"submit\" size=\"8\" name=\"submit_del_read\" value=\"Del &gt;&gt;\" />";
	echo "</td><td>";
	echo "<select name=\"users_not_read[]\" size=\"8\" multiple=\"multiple\">";

	$query = mysql_query(sprintf("SELECT users.given_name, users.family_name, users.id, users.username
                                      FROM users WHERE users.username NOT IN (SELECT User FROM mysql.db
                                                                              WHERE Db = '%s' AND Select_priv = 'Y')", 
                                     mysql_real_escape_string($database)));
	if(!$query && $debug) echo "<p>".mysql_error()."</p>\n";
	while($row = mysql_fetch_array($query, MYSQL_NUM)) {
		if($row[0]=="" && $row[1]=="") $current_name = $row[3];
		elseif($row[0]=="") $current_name = $row[1];
		elseif($row[1]=="") $current_name = $row[0];
		else $current_name = $row[1].", ".$row[0];
		echo "<option value=\"".$row[3]."\">".$current_name."</option>";
	}
	
	echo "</select></td></tr>\n";
	echo "</table>";
	echo "</fieldset>\n";
	
	echo "<fieldset><legend>Write access</legend>\n";
	echo "<table>\n<tr><th>Write access</th><th>Action</th><th>No write access</th></tr>\n";
	echo "<tr><td><select name=\"users_write[]\" size=\"8\" multiple=\"multiple\">";

	$query = mysql_query(sprintf("SELECT DISTINCT users.given_name, users.family_name, users.id, users.username
                                      FROM users, mysql.db
                                      WHERE users.username = User AND Db = '%s'
                                      AND Insert_priv = 'Y'", mysql_real_escape_string($database)));
	if(!$query && $debug) echo "<p>".mysql_error()."</p>\n";
	while($row = mysql_fetch_array($query, MYSQL_NUM)) {
		if($row[0]=="" && $row[1]=="") $current_name = $row[3];
		elseif($row[0]=="") $current_name = $row[1];
		elseif($row[1]=="") $current_name = $row[0];
		else $current_name = $row[1].", ".$row[0];
		echo "<option value=\"".$row[3]."\">".$current_name."</option>";
	}
	
	echo "</select></td><td>";
	echo "<input type=\"submit\" size=\"8\" name=\"submit_add_write\" value=\"&lt;&lt; Add\" /><br />";
	echo "<input type=\"submit\" size=\"8\" name=\"submit_del_write\" value=\"Del &gt;&gt;\" />";
	echo "</td><td>";
	echo "<select name=\"users_not_write[]\" size=\"8\" multiple=\"multiple\">";

	$query = mysql_query(sprintf("SELECT users.given_name, users.family_name, users.id, users.username
                                      FROM users WHERE users.username NOT IN (SELECT User FROM mysql.db
                                                                              WHERE Db = '%s' AND Insert_priv = 'Y')", 
                                     mysql_real_escape_string($database)));
	while($row = mysql_fetch_array($query, MYSQL_NUM)) {
		if($row[0]=="" && $row[1]=="") $current_name = $row[3];
		elseif($row[0]=="") $current_name = $row[1];
		elseif($row[1]=="") $current_name = $row[0];
		else $current_name = $row[1].", ".$row[0];
		echo "<option value=\"".$row[3]."\">".$current_name."</option>";
	}
	
	echo "</select></td></tr>\n";
	echo "</table>";
	echo "</fieldset>\n";
	
	echo "</form>\n";

} else include("login.inc.php");

include("footer.inc.php");
?>
