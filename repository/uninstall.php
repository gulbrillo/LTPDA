<?php
include("config.inc.php"); // some constants
include("passtest.inc.php"); // checks the User/Password

$title = "Uninstall";

// $CVS_TAG="$Id: uninstall.php,v 1.4 2011/06/14 10:07:16 mauro Exp $";
include("header.inc.php");

if($passtest && $connected) {
	echo "<h1>$title</h1>";
	if($is_admin) {
		if($_POST["confirm"]!="YES") {
			echo "<p>This page helps you to uninstall the ltpda databases. It deletes ALL DATA and ALL USERS that are listet on this interface. If you really want to do this, please enter an uppertype yes into the text field below and press uninstall.<p>\n";
			echo "<form action=\"uninstall.php\" method=\"post\">\n";
			echo "<input type=\"text\" value=\"\" name=\"confirm\" /> <input type=\"submit\" name=\"submit_button\" value=\"Uninstall\" />\n";
			echo "</form>\n";
		} else {
			$query = mysql_query("SELECT user.User, user.Host FROM mysql.user AS user, users WHERE user.User=users.username");
			while($row = mysql_fetch_row($query)) {
                             $rv = mysql_query(sprintf("DROP USER '%s'@'%s'",
                                                       mysql_real_escape_string($row[0]),
                                                       mysql_real_escape_string($row[1])));
                             if (!$rv)
                                  echo "<p class=\"error\">Error!</p>";
			}
			$query = mysql_query("SELECT db_name FROM available_dbs");
			while($row = mysql_fetch_row($query)) {
                             $rv = mysql_query(sprintf("DROP DATABASE `%s`", 
                                                       mysql_real_escape_string($row[0])));
                             if (!$rv)
                                  echo "<p class=\"error\">Error!</p>";
			}
			mysql_query("DROP DATABASE `$mysql_db`");
		}
	} else echo "<p class=\"error\">Sorry, you do not have the rights to view this page.</p>";
} else include("login.inc.php");

include("footer.inc.php");
?>
