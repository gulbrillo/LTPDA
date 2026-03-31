<?php
include("config.inc.php"); // some constants
include("passtest.inc.php"); // checks the User/Password

$title = "Database index";
// $CVS_TAG="$Id: list_dbs.php,v 1.11 2012/01/05 11:21:08 gerrit Exp $";
include("header.inc.php");

if($passtest && $connected) {
	
	echo "<h1>$title</h1>";
	
	if($is_admin) {
		$query = mysql_query("SELECT db_name, name, description, id FROM available_dbs");
		if(!$query && $debug) echo "<p class=\"error\">".mysql_error()."</p>\n";
		
		$i = 0;
		echo "<table>\n<tr><th>Name</th><th>Stored objects</th><th>Internal name</th><th>Description</th><th>Administer</th></tr>\n";
		while($row = mysql_fetch_array($query, MYSQL_NUM)) {
			$subquery = mysql_query("SELECT COUNT(*) FROM ".mysql_real_escape_string($row[0]).".objs");
			if($subquery) $stored_objs = mysql_result($subquery, 0, 0);
			else if($debug) echo "<p class=\"error\">".mysql_error()."</p>\n";
			if($i++%2) echo "<tr class=\"row_one\">";
			else echo "<tr class=\"row_two\">";
			echo "<td><a href=\"query_database.php?db=".$row[0]."\">".$row[0]."</a></td>";
			echo "<td class=\"right\">$stored_objs</td>";
			echo "<td>".$row[1]."</td>";
			echo "<td>".$row[2]."</td>";
			echo "<td><a href=\"edit_database.php?db=".$row[0]."\"><img src=\"images/edit.png\" alt=\"edit database\" title=\"Edit this database\" height=\"22\" width=\"22\" /></a> <a href=\"edit_rights.php?db=".$row[0]."\"><img src=\"images/users.png\" alt=\"user rights\" title=\"Edit user rights\" height=\"22\" width=\"22\" /></a> <a href=\"delete_database.php?db=".$row[0]."\"><img src=\"images/delete.png\" alt=\"Delete\" title=\"Delete this database\" height=\"22\" width=\"22\" /></a></td>";
			echo "</tr>\n";
		}
		echo "</table>";
		echo "<a href=\"create_database.php\">Create new database</a>\n";
	} else echo "<p class=\"error\">Sorry, you need to have admin rights to access this page.</p>";
	
} else include("login.inc.php");

include("footer.inc.php");
?>
