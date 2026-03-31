<?php
// $CVS_TAG="$Id: passtest.inc.php,v 1.14 2012/01/05 10:09:16 gerrit Exp $";
session_start();

/**
 * Connects to the MySQL server and checks credentials in the mysql.user table.
 * If true, it sets "passtest" to the user id. If not, passtest is 0.
 */

if(isset($_POST["ltpda_login_button"])) {
    $login = $_POST["ltpda_login_button"];
} else $login = "";

// When we want to logout:
if(isset($_GET["logout"]) && $_GET["logout"]=="true") { unset($_SESSION["user"]); unset($_SESSION["passwd"]); }
else {
	if(!isset($_SESSION["user"])) $_SESSION["user"] = "";
	if(!isset($_SESSION["passwd"])) $_SESSION["passwd"] = "";
}


$passtest = 0;
$is_admin = 0;

$connection = mysql_connect($mysql_host, $mysql_user, $mysql_pass);
if($connection) {
	if(mysql_select_db($mysql_database)) {
		
		if($login=="Login") {
			$user = $_POST["ltpda_user"];
			$passwd = $_POST["ltpda_password"];
		} else {
			$user = isset($_SESSION["user"]) ? $_SESSION["user"] : "";
			$passwd = isset($_SESSION["passwd"]) ? $_SESSION["passwd"] : "";
		}
		
        // check password
        $query = mysql_query(sprintf("SELECT User FROM mysql.user, users
                                              WHERE User=username AND User='%s' 
                                              AND user.Password=PASSWORD('%s')",
                                             mysql_real_escape_string($user),
                                             mysql_real_escape_string($passwd)));
        if(!$query && $debug) echo "<p class=\"error\">".mysql_error()."</p>";

        if (mysql_num_rows($query) > 0) {

             $user = mysql_result($query, 0, 0);

             // get user id and administrator status
             $query = mysql_query(sprintf("SELECT id, is_admin FROM users
                                           WHERE username='%s'",
                                          mysql_real_escape_string($user)));
             if(!$query && $debug) echo "<p class=\"error\">".mysql_error()."</p>";
             $passtest = mysql_result($query, 0, 0);
             $is_admin = mysql_result($query, 0, 1);

             // store the variables in a session
             if($login=="Login") {
                  $_SESSION["user"] = $user;
                  $_SESSION["passwd"] = $passwd;
             }
        } else if($login=="Login") echo "<p class=\"error\">User not found.</p>\n";
	} else {
		echo "<p class=\"error\">$mysql_database_fail</p>\n";
		if($debug) echo "<p class=\"error\">".mysql_error()."</p>";
	}
} else {
	echo "<p class=\"error\">$mysql_connection_fail</p>\n";
}
mysql_close($connection);
?>