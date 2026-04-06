<?php
include("config.inc.php"); // some constants
include("passtest.inc.php"); // checks the User/Password

$db_name = $_GET["db"]; // POST XOR GET ist used...

$title = "Delete database";
// $CVS_TAG="$Id: delete_database.php,v 1.11 2011/06/14 10:07:15 mauro Exp $";
include("header.inc.php");

if($passtest && $connected) {
	echo "<h1>$title</h1>";
	if($is_admin) {
		if($db_name) {
			if($_GET["confirm"]=="true") {
                             $error = 0;
                             $rv = mysql_query(sprintf("DELETE FROM available_dbs WHERE db_name='%s'",
                                                       mysql_real_escape_string($db_name)));
                             if (!$rv) {
                                  $error = mysql_error();
                                  echo "<p class=\"error\">$error</p>\n";
                             }
                             $rv = mysql_query(sprintf("DROP DATABASE `%s`",
                                                       mysql_real_escape_string($db_name)));
                             if (!$rv) {
                                  $error = mysql_error();
                                  echo "<p class=\"error\">$error</p>\n";
                             }
                             $rv = mysql_query(sprintf("DELETE FROM mysql.db WHERE Db='%s'",
                                                       mysql_real_escape_string($db_name)));
                             if (!$rv) {
                                  $error = mysql_error();
                                  echo "<p class=\"error\">$error</p>\n";
                             }
                             $rv = mysql_query("FLUSH PRIVILEGES");
                             if (!$rv) {
                                  $error = mysql_error();
                                  echo "<p class=\"error\">$error</p>\n";
                             }
                             if (!$error) {
                                  echo "<p class=\"success\">Database \"$db_name\" successfully deleted.</p>";
                                  echo "<p>Back to <a href=\"index.php\">main menu</a> or <a href=\"list_dbs.php\">db list</a>.</p>\n";
                             } else {
                                  echo "<p class=\"error\">Could not delete database.</p>\n";
                             }
			} else {
                             echo "<p>Are you sure you want to delete the database \"$db_name\" permanently?</p>\n";
                             echo "<p>[<a href=\"delete_database.php?db=$db_name&amp;confirm=true\">YES</a>][<a href=\"index.php\">NO</a>]</p>\n";
			}
		} else echo "<p class=\"error\">No database selected. Please call this page with a valid database id.</p>";
	}
} else include("login.inc.php");

include("footer.inc.php");
?>
