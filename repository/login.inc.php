<?php
// $CVS_HEADER = "$Id: login.inc.php,v 1.9 2011/07/06 12:52:55 gerrit Exp $";

if(isset($_POST["ltpda_user"])) $ltpda_user = $_POST["ltpda_user"];
else $ltpda_user = "";

if(isset($_SERVER["REQUEST_URI"])) $req_uri = $_SERVER["REQUEST_URI"];
else $req_uri = "";

if(isset($_SESSION["user"])) $session_user = $_SESSION["user"];
else $session_user = "";

if(isset($_SESSION["passwd"])) $session_passwd = $_SESSION["passwd"];
else $session_passwd = "";

if(isset($_POST["ltpda_login_button"])) $ltpda_login_button = $_POST["ltpda_login_button"];
$ltpda_login_button = "";

echo "<form action=\"".$req_uri."\" method=\"post\">\n";
echo "<table>\n";
echo "<tr><td>Username:</td><td><input type=\"text\" name=\"ltpda_user\" value=\"".$ltpda_user."\" /></td></tr>\n";
echo "<tr><td>Password:</td><td><input type=\"password\" name=\"ltpda_password\" /></td></tr>\n";
echo "<tr><td>Login:</td><td><input type=\"submit\" name=\"ltpda_login_button\" value=\"Login\" /></td></tr>\n";
echo "</table>";
if($ltpda_login_button =="Login" && !$passtest) echo "<p>Your username/password combination does not match.</p>\n";
echo "</form>\n";
echo "<p class=\"small\"><a href=\"forgot_password.php\">Forgot your password?</a></p>\n";

echo "<p><a href=\"http://validator.w3.org/check?uri=referer\"><img src=\"http://www.w3.org/Icons/valid-xhtml10-blue\" alt=\"Valid XHTML 1.0 Strict\" height=\"31\" width=\"88\" /></a>\n";
echo " <a href=\"http://jigsaw.w3.org/css-validator/\"><img style=\"border:0;width:88px;height:31px\" src=\"http://www.w3.org/Icons/valid-css-blue.png\" alt=\"Valid CSS!\" /></a></p>\n";
unset($session_user);
unset($session_passwd);
?>
