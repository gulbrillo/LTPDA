<?php
include("config.inc.php"); // some constants
include("passtest.inc.php"); // checks the User/Password

// $CVS_TAG="$Id: forgot_password.php,v 1.6 2011/06/14 10:07:15 mauro Exp $";

$title = "Forgotten username/password";

include("header.inc.php");

if($connected) {
	echo "<h1>$title</h1>";
	if($_POST["submit_email"]=="Submit") {
		$email = $_POST["email"];
		$given_name = $_POST["given_name"];
		$family_name = $_POST["family_name"];
		
		$query = mysql_query("SELECT email, username, given_name, family_name, id FROM users WHERE LOWER(given_name)=LOWER(\"".mysql_real_escape_string($given_name)."\") AND LOWER(family_name)=LOWER(\"".mysql_real_escape_string($family_name)."\") AND LOWER(email)=LOWER(\"".mysql_real_escape_string($email)."\")");
		
		if($query && mysql_num_rows($query)) {
			
			// Get all the right information:
			$email = mysql_result($query, 0, 0);
			$username = mysql_result($query, 0, 1);
			$given_name = mysql_result($query, 0, 2);
			$family_name = mysql_result($query, 0, 3);
			$id = mysql_result($query, 0, 4);
			$query = mysql_query("SELECT value FROM options WHERE name=\"mail_text_reset\"");
			$mail_text = mysql_result($query, 0, 0);
			$query = mysql_query("SELECT value FROM options WHERE name=\"mail_subject_reset\"");
			$mail_subject = mysql_result($query, 0, 0);
			$query = mysql_query("SELECT value FROM options WHERE name=\"admin_mail\"");
			$admin_mail = mysql_result($query, 0, 0);
			
			// start with a blank password
			$password = "";
			// define possible characters
			$possible = "0123456789bcdfghjkmnpqrstvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
		
			for($i=0; $i < 8; $i++) {
    			// pick a random character from the possible ones
				$char = substr($possible, mt_rand(0, strlen($possible)-1), 1);
				$password .= $char;
			}
			
			// Write all variables
			$mail_text = str_replace("%username%", $username, $mail_text);
			$mail_text = str_replace("%password%", $password, $mail_text);
			$mail_to = "$given_name $family_name <$email>";
			$mail_headers = "From: $admin_mail\nReply-To: $admin_mail\nMime-Version: 1.0\nContent-Type: text/plain; charset=utf-8\nContent-Transfer-Encoding: 8bit\n";
			
                        foreach (array("localhost", "%") as $host) {
                             $rv = mysql_query(sprintf("SET PASSWORD FOR '%s'@'%s' = PASSWORD('%s')",
                                                       mysql_real_escape_string($username),
                                                       mysql_real_escape_string($host),
                                                       $password));
                             if (!$rv) {
                                  echo "<p class=\"error\">Could not change password.</p>\n";
                                  if($debug) echo "<p class=\"error\">".mysql_error()."</p>\n";
                                  break;
                             }
                        }
                        if (!$rv) {
                             echo "<p class=\"error\">Set password failed.</p>";
                        } else {
                             // Send out the email:
                             if(mail($mail_to, $mail_subject, $mail_text, $mail_headers)) echo "<p>A new password has been generated. It has been mailed to you.</p>\n";
                             else echo "<p class=\"error\">Sorry, the email could not be sent out. Please inform an administrator of that problem (".htmlentities($admin_mail).").</p>\n";
                        }
		} else echo "<p class=\"error\">Sorry, your name/email combination could not be found.</p>";
	} else {
		echo "<p>If you forgot your username and password, you can reset it. You have to supply your given name, family name and your email address. Your password will be reset and mailed to you.</p>\n";
		echo "<form action=\"forgot_password.php\" method=\"post\">\n";
		echo "Given name: <input type=\"text\" name=\"given_name\" /><br />\n";
		echo "Family name: <input type=\"text\" name=\"family_name\" /><br />\n";
		echo "Email address: <input type=\"text\" name=\"email\" /><br />\n";
		echo "<input type=\"submit\" name=\"submit_email\" value=\"Submit\" />";
		echo "</form>\n";
	}
}

include("footer.inc.php");
?>
