<?php
include("config.inc.php"); // some constants
include("passtest.inc.php"); // checks the User/Password

$title = "Create a new user";
// $CVS_TAG="$Id: create_user.php,v 1.31 2012/02/08 16:47:26 gerrit Exp $";
include("header.inc.php");

if(!isset($_POST["username"])) $_POST["username"] = "";
if(!isset($_POST["given_name"])) $_POST["given_name"] = "";
if(!isset($_POST["family_name"])) $_POST["family_name"] = "";
if(!isset($_POST["email"])) $_POST["email"] = "";
if(!isset($_POST["telephone"])) $_POST["telephone"] = "";
if(!isset($_POST["institution"])) $_POST["institution"] = "";
if(!isset($_POST["save_data"])) $_POST["save_data"] = "";

if($passtest && $connected) {
	echo "<h1>$title</h1>";
	if($is_admin) {
		
		$new_username = $_POST["username"];
		$given_name = $_POST["given_name"];
		$family_name = $_POST["family_name"];
		$email = $_POST["email"];
		$telephone = $_POST["telephone"];
		$institution = $_POST["institution"];
		
		
		
		// start with a blank password
		$password = "";
		// define possible characters
		$possible = "0123456789bcdfghjkmnpqrstvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"; 
		// set up a counter
		$i = 0;
		
		for($i=0; $i < 8; $i++) {
    		// pick a random character from the possible ones
			$char = substr($possible, mt_rand(0, strlen($possible)-1), 1);
			$password .= $char;
		}
		// Check if theres data to save:
		if($_POST["save_data"]=="Save") {
			$user_exists = 0;
			
			// Check if all fields have a value.
			$not_all_values_entered = 6;
			if(!$new_username) echo "<p class=\"error\">The username field is not optional.</p>";
			else $not_all_values_entered--;
			if(!preg_match('/^[a-z0-9_.]+$/iD', $new_username)) echo "<p class=\"error\">The username has to be alphanumerical (it may contain an underscore dash or dot).</p>";
			else $not_all_values_entered--;
			if(!$given_name) echo "<p class=\"error\">The given name field is not optional.</p>";
			else $not_all_values_entered--;
			if(!$family_name) echo "<p class=\"error\">The family name field is not optional.</p>";
			else $not_all_values_entered--;
			if(!$institution) echo "<p class=\"error\">The institution field is not optional.</p>";
			else $not_all_values_entered--;
			if(!$email) echo "<p class=\"error\">The email field is not optional.</p>";
			else $not_all_values_entered--;
			
			// Check if the user is already in the database
			$query = mysql_query("SELECT COUNT(*) FROM users WHERE username=\"".mysql_real_escape_string($new_username)."\"");
			if(mysql_result($query, 0, 0)) {
				$user_exists = 1;
				echo "<p class=\"error\">The user already exists.</p>";
			}
			
			// Check if the user is already in the mysql user table (e.g. created by another program)
			mysql_select_db("mysql");
			$query = mysql_query("SELECT COUNT(*) FROM user WHERE User=\"".mysql_real_escape_string($new_username)."\"");
			if(mysql_result($query, 0, 0)) {
				$user_exists = 1;
				echo "<p class=\"error\">The user already exists in the internal mysql user table. Please choose another name.</p>";
			}
			mysql_select_db($mysql_database);
			
			// Now create the user ("!not all values" seems a bit odd, but was the cheapest way :)):
			if(!$user_exists && !$not_all_values_entered) {
                             foreach (array("localhost", "%") as $host) {
                                  $rv = mysql_query(sprintf("CREATE USER '%s'@'%s' IDENTIFIED BY '%s'", 
                                                            mysql_real_escape_string($new_username),
                                                            mysql_real_escape_string($host),
															mysql_real_escape_string($password)));
                                  if (!$rv) {
									   									 echo "<p class=\"error\">Cannot create user. ".mysql_error()."</p>";
								  									}
                             }
                             $rv = mysql_query(sprintf("INSERT INTO users (username, given_name, family_name,
                                                                           email, telephone, institution, is_admin)
                                                        VALUES ('%s', '%s', '%s', '%s', '%s', '%s', 0)",
                                                       mysql_real_escape_string($new_username),
                                                       mysql_real_escape_string($given_name),
                                                       mysql_real_escape_string($family_name),
                                                       mysql_real_escape_string($email),
                                                       mysql_real_escape_string($telephone),
                                                       mysql_real_escape_string($institution)));
                             if($rv) {
                                  $userid = mysql_insert_id();
                                  
                                  echo "<p class=\"success\">Data saved. User will be notified by email.</p>\n<p>Please go to the <a href=\"edit_user.php?id=$userid\">edit page</a> and check, if everything ist correct.</p>\n";
                                  
                                  $query = mysql_query("SELECT value FROM options WHERE name=\"mail_text\"");
                                  $mail_text = mysql_result($query, 0, 0);
                                  $query = mysql_query("SELECT value FROM options WHERE name=\"mail_subject\"");
                                  $mail_subject = mysql_result($query, 0, 0);
                                  $query = mysql_query("SELECT value FROM options WHERE name=\"admin_mail\"");
                                  $admin_mail = mysql_result($query, 0, 0);
                                  
                                  $mail_text = str_replace("%username%", $new_username, $mail_text);
                                  $mail_text = str_replace("%password%", $password, $mail_text);
					
                                  $mail_headers = "From: $admin_mail\nReply-To: $admin_mail\nMime-Version: 1.0\nContent-Type: text/plain; charset=utf-8\nContent-Transfer-Encoding: 8bit\n";
					
                                  // Send the email with the user password
                                  mail($email, $mail_subject, $mail_text, $mail_headers);
                             } else {
                                  echo "<p class=\"error\">Data could not be saved.</p>\n";
                                  if($debug) echo "<p class=\"error\">".mysql_error()."</p>\n";
                             }
			}
		} else {
			$query = mysql_query("SELECT institution FROM users ORDER BY id DESC LIMIT 1");
			if($query) $institution = mysql_result($query, 0, 0);
			else $institution = "";
			
			echo "<form action=\"create_user.php\" method=\"post\">\n";
			echo "<table>\n";
			echo "<tr><td>Username:</td><td><input type=\"text\" name=\"username\" title=\"This will be the login name for the user. You cannot change this later.\" /></td></tr>\n";
			echo "<tr><td>Given name:</td><td><input type=\"text\" name=\"given_name\" title=\"The given name of the new user. This can be changed by the user or an admin later.\" /></td></tr>\n";
			echo "<tr><td>Family name:</td><td><input type=\"text\" name=\"family_name\" title=\"The family name of the new user. This can be changed by the user or an admin later.\" /></td></tr>\n";
			echo "<tr><td>Email:</td><td><input type=\"text\" name=\"email\"  title=\"The email address of the new user. This can be changed by the user or an admin later.\" /></td></tr>\n";
			echo "<tr><td>Telephone:</td><td><input type=\"text\" name=\"telephone\"  title=\"The telephone number of the new user. This is optional.\" /></td></tr>\n";
			echo "<tr><td>Institution:</td><td><input type=\"text\" name=\"institution\" value=\"$institution\" title=\"The institution where the user works.\" /></td></tr>\n";
			echo "<tr><td>Submit:</td><td><input type=\"submit\" name=\"save_data\" value=\"Save\" title=\"Add this user to the database. Some additional configuration can be done afterwards.\" /></td></tr>\n";
			echo "</table>\n";
			echo "</form>\n";
		}
	} else echo "<p class=\"error\">Sorry, you do not have the rights to view this page.</p>\n";
} else include("login.inc.php");

include("footer.inc.php");
?>
