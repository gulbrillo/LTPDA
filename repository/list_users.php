<?php
include("config.inc.php"); // some constants
include("passtest.inc.php"); // checks the User/Password

$title = "Users";
// $CVS_TAG="$Id: list_users.php,v 1.17 2012/01/25 18:25:36 gerrit Exp $";
include("header.inc.php");

if(isset($_GET["sort"])) $sort = $_GET["sort"];
else $sort = "";

if(!$sort || !preg_match('/^[a-z0-9_]+$/iD', $sort)) $sort = "family_name";

if($passtest && $connected) {
	echo "<h1>$title</h1>";
	if($is_admin) {
		$query = mysql_query("SELECT id, username, family_name, given_name, email, is_admin FROM users ORDER BY $sort");
		echo "<table>\n";
		echo "<tr><th><a href=\"list_users.php?sort=username\">username</a></th><th><a href=\"list_users.php?sort=family_name\">family name</a></th><th><a href=\"list_users.php?sort=given_name\">given name</a></th><th><a href=\"list_users.php?sort=email\">email</a></th><th>Access to these DBs</th><th>administer</th></tr>\n";
		while($row = mysql_fetch_array($query, MYSQL_NUM)) {
			
			// Prevent the admin from deleted himself
			if($row[0]!=$passtest) $delete_user = "<a href=\"delete_user.php?username=".$row[1]."\"><img src=\"images/delete_user.png\" alt=\"delete user\" title=\"delete this user\" width=\"22\" height=\"22\" /></a>";
			else $delete_user = "<img src=\"images/delete_user_grey.png\" alt=\"no delete\" title=\"You cannot delete yourself.\" width=\"22\" height=\"22\" />";
			
			// Every second row in another color
			$i = 0;
			if($i++ % 2 == 0) $class="class=\"row_one\"";
			else $class="class=\"row_two\"";
			if($row[5]) $class="class=\"row_admin\"";
			
			// Get the databases, the user can access:
			$subquery = mysql_query(sprintf("SELECT Db FROM mysql.db, available_dbs
                                                         WHERE Db=db_name AND Select_priv='Y' AND User='%s'",
                                                        mysql_real_escape_string($row[1])));
            if (!$subquery) echo mysql_error();
			$access_to_dbs = "";
			while($access_db = mysql_fetch_array($subquery, MYSQL_NUM)) $access_to_dbs .= ", ".$access_db[0];
			$access_to_dbs = substr($access_to_dbs, 2);
			
			echo "<tr $class><td><a href=\"edit_user.php?id=".$row[0]."\" title=\"edit this user\">".$row[1]."</a></td><td>".$row[2]."</td><td>".$row[3]."</td><td>".$row[4]."</td><td>$access_to_dbs</td><td align=\"center\"><a href=\"edit_user.php?id=".$row[0]."\"><img title=\"edit this user\" alt=\"edit user\" src=\"images/edit.png\" width=\"22\" height=\"22\" /></a>$delete_user</td></tr>\n";
		}
		echo "</table>\n";
		echo "<a href=\"create_user.php\">Create new user</a>\n";
	} else echo "<p class=\"error\">Sorry, you do not have the rights to view this page.</p>\n";
} else include("login.inc.php");

include("footer.inc.php");
?>
