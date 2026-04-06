<?php

include("config.inc.php"); // some constants
include("passtest.inc.php"); // checks the User/Password

$username = $_GET["username"];
if(!preg_match('/^[a-z0-9_.]+$/iD', $username)) $username = "";

$title = "Delete user";
// $CVS_TAG="$Id: delete_user.php,v 1.17 2012/02/08 16:47:26 gerrit Exp $";
include("header.inc.php");

if($passtest && $connected) {
	echo "<h1>$title</h1>";
	if($is_admin) {
		$query = mysql_query("SELECT id FROM users WHERE username=\"".mysql_real_escape_string($username)."\"");
		if(mysql_num_rows($query)==0) {
			echo "<p class=\"error\">User is not in database.</p>\n";
			$user_not_found = true;
		} else {
			$user_id = mysql_result($query, 0, 0);
			
			if(isset($_GET["confirm"]) && $_GET["confirm"]=="true") {

                             $error = 0;
                             $query = mysql_query(sprintf("SELECT user.User, user.Host
                                                           FROM mysql.user WHERE user.User='%s'",
                                                          mysql_real_escape_string($username)));
                             while($row = mysql_fetch_row($query)) {
                                  $rv = mysql_query(sprintf("DROP USER '%s'@'%s'",
                                                            mysql_real_escape_string($row[0]),
                                                            mysql_real_escape_string($row[1])));
                                  if (!$rv) {
                                       $error = mysql_error();
                                       echo "<p class=\"error\">Could not delete user: $error</p>";
                                  }
                             }
                             $rv = mysql_query(sprintf("DELETE FROM users WHERE id=%d", $user_id));
                             if (!$rv) {
                                  $error = mysql_error();
                                  echo "<p class=\"error\">Could not delete user: $error</p>";
                             }
														 mysql_query("FLUSH PRIVILEGES");
                             if (!$error) {
                                  echo "<p class=\"success\">User \"$username\" successfully deleted.</p>";
                                  echo "<p>Back to <a href=\"index.php\">main menu</a> or <a href=\"list_users.php\">user list</a>.</p>\n";
                             }
			} else {
				$query = mysql_query("SELECT username, given_name, family_name FROM users WHERE id=".$user_id);
				echo "<p>Are you sure you want to delete this user?</p>\n";
				echo "<p><b>".mysql_result($query, 0, 0)." (".mysql_result($query, 0, 2).", ".mysql_result($query, 0,1).")</b></p>\n";
				echo "<p>[<a href=\"delete_user.php?username=$username&amp;confirm=true\">YES</a>][<a href=\"list_users.php\">NO</a>]</p>\n";
			}
		}
	}
} else include("login.inc.php");

include("footer.inc.php");
?>
