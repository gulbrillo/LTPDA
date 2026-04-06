<?php
include("config.inc.php"); // some constants
include("passtest.inc.php"); // checks the User/Password

$title = "Edit mail text";
// $CVS_TAG="$Id: edit_mail_text.php,v 1.11 2011/07/19 13:26:08 gerrit Exp $";
include("header.inc.php");

if($passtest && $connected) {
	
	if($is_admin) {
		
		// Write the data:
		if(isset($_POST["text_submit"]) && $_POST["text_submit"]=="Save") {
			$mail_text = $_POST["mail_text"];
			$mail_subject = $_POST["mail_subject"];
			$mail_text_reset = $_POST["mail_text_reset"];
			$mail_subject_reset = $_POST["mail_subject_reset"];
			$admin_mail = $_POST["admin_mail"];
			
			if(!strstr($mail_text, "%username%")) echo "<p>WARNING: You did not use the variable %username%</p>\n";
			if(!strstr($mail_text, "%password%")) echo "<p>WARNING: You did not use the variable %password%</p>\n";
			
			// update all options
			$query = mysql_query("INSERT INTO `options` (`name`, `value`) VALUES (\"mail_text\", \"".mysql_real_escape_string($mail_text)."\") ON DUPLICATE KEY UPDATE value=\"".mysql_real_escape_string($mail_text)."\"");
			if(!$query) {
				echo "<p class=\"error\">Could not save the mail text.</p>\n";
				if($debug) echo "<p class=\"error\">".mysql_error()."</p>\n";
			}
			$query = mysql_query("INSERT INTO `options` (`name`, `value`) VALUES (\"mail_subject\", \"".mysql_real_escape_string($mail_subject)."\") ON DUPLICATE KEY UPDATE value=\"".mysql_real_escape_string($mail_subject)."\"");
			if(!$query) {
				echo "<p class=\"error\">Could not save the mail subject.</p>\n";
				if($debug) echo "<p class=\"error\">".mysql_error()."</p>\n";
			}
			$query = mysql_query("INSERT INTO `options` (`name`, `value`) VALUES (\"admin_mail\", \"".mysql_real_escape_string($admin_mail)."\") ON DUPLICATE KEY UPDATE value=\"".mysql_real_escape_string($admin_mail)."\"");
			if(!$query) {
				echo "<p class=\"error\">Could not save the mail address of the admin.</p>\n";
				if($debug) echo "<p class=\"error\">".mysql_error()."</p>\n";
			}
			$query = mysql_query("INSERT INTO `options` (`name`, `value`) VALUES (\"mail_text_reset\", \"".mysql_real_escape_string($mail_text_reset)."\") ON DUPLICATE KEY UPDATE value=\"".mysql_real_escape_string($mail_text_reset)."\"");
			if(!$query) {
				echo "<p class=\"error\">Could not save the mail text for the password reset text.</p>\n";
				if($debug) echo "<p class=\"error\">".mysql_error()."</p>\n";
			}
			$query = mysql_query("INSERT INTO `options` (`name`, `value`) VALUES (\"mail_subject_reset\", \"".mysql_real_escape_string($mail_subject_reset)."\") ON DUPLICATE KEY UPDATE value=\"".mysql_real_escape_string($mail_subject_reset)."\"");
			if(!$query) {
				echo "<p class=\"error\">Could not save the mail subject for the password reset text.</p>\n";
				if($debug) echo "<p class=\"error\">".mysql_error()."</p>\n";
			}
			
			echo "<p class=\"success\">Done.</p>\n";
		}
		
		// ******** Output ***********
		
		$query = mysql_query("SELECT value FROM options WHERE name=\"mail_subject\"");
		if($query && mysql_num_rows($query)) $mail_subject = mysql_result($query, 0, 0);
		
		$query = mysql_query("SELECT value FROM options WHERE name=\"mail_text\"");
		if($query && mysql_num_rows($query)) $mail_text = mysql_result($query, 0, 0);
		
		$query = mysql_query("SELECT value FROM options WHERE name=\"mail_subject_reset\"");
		if($query && mysql_num_rows($query)) $mail_subject_reset = mysql_result($query, 0, 0);
		
		$query = mysql_query("SELECT value FROM options WHERE name=\"mail_text_reset\"");
		if($query && mysql_num_rows($query)) $mail_text_reset = mysql_result($query, 0, 0);
		
		$query = mysql_query("SELECT value FROM options WHERE name=\"admin_mail\"");
		if($query && mysql_num_rows($query)) $admin_mail = mysql_result($query, 0, 0);
		
		echo "<p>When a new user is created, he will receive an email with his login data. Here you can change the text of the email. Please make sure, that all variables (%password%, %username%) are in the text. They will be replaced by their actual values when sending the email.</p>\n";
		echo "<form action=\"edit_mail_text.php\" method=\"post\">\n";
		echo "Mail address of the admin: <input type=\"text\" size=\"50\" name=\"admin_mail\" value=\"$admin_mail\" /><br />";
		echo "<fieldset><legend>Mail text for a new account</legend>\n";
		echo "Subject: <input type=\"text\" size=\"50\" name=\"mail_subject\" value=\"$mail_subject\" /><br />";
		echo "<textarea cols=\"60\" rows=\"10\" name=\"mail_text\">$mail_text</textarea><br />\n";
		echo "<input type=\"submit\" name=\"text_submit\" value=\"Save\">";
		echo "\n";
		echo "<legend>Mail text for a password reset</legend>\n";
		echo "Subject: <input type=\"text\" size=\"50\" name=\"mail_subject_reset\" value=\"$mail_subject_reset\" /><br />";
		echo "<textarea cols=\"60\" rows=\"10\" name=\"mail_text_reset\">$mail_text_reset</textarea><br />\n";
		echo "<input type=\"submit\" name=\"text_submit\" value=\"Save\">";
		echo "</fieldset>\n";
		echo "</form>\n";
	}
	
} else include("login.inc.php");

include("footer.inc.php");
?>
