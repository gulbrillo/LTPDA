<?php echo "<?xml version=\"1.0\" ?>"; ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Installation guide</title>
</head>
<body>
<?php
// "$Id: install.php,v 1.44 2012/01/20 07:40:24 gerrit Exp $";

require('version.inc.php');

/**
 * This script creates a new user which has all the rights that are needed by the web interface.
 * It creates the basic databases for the web interface and inserts a root account.
 */


if(!isset($_GET["page"])) {
	echo "<h1>Installation guide</h1>\n";
	echo "<p>This script will guide you through the installation process. If for any reason this installation script does not work, you can read the short <a href=\"readme.html\">install guide</a> and do the installation manually.</p>";
	echo "<p>Before you go on here, please make sure, that \"config.inc.php\" is writeable to the webserver. <a href=\"readme.html#configwrite\">-&gt; See how</a></p>\n";
	echo "<p>At first, you need to provide an existing mysql root account. We need a lot of permissions for the web interface since it creates and drops new databases and adds new users to mysql.</p>\n";
	echo "<p>You can now choose between two options: Let this script create a new user with all needed privileges or just use the given root account. <a href=\"readme.html#rootaccount\">-&gt; More details</a></p>\n";
	
	echo "<form action=\"install.php?page=1\" method=\"post\">\n";
	echo "<fieldset title=\"Existing user\"><legend>Existing user</legend>\n";
	echo "<table>\n";
	echo "<tr><td style=\"width: 275px\">MySQL user with root privileges:</td><td><input type=\"text\" name=\"mysql_user\" value=\"root\" /></td></tr>\n";
	echo "<tr><td style=\"width: 275px\">MySQL password:</td><td><input type=\"password\" name=\"mysql_pass\" /></td></tr>\n";
	echo "<tr><td style=\"width: 275px\">MySQL hostname:</td><td><input type=\"text\" name=\"mysql_host\" value=\"localhost\" /></td></tr>\n";
	echo "</table>\n</fieldset>\n<table>\n";
	echo "<tr><td style=\"width: 275px\">Use root account?</td><td><input type=\"radio\" name=\"use_root\" value=\"1\">use the root account above<br /><input type=\"radio\" name=\"use_root\" value=\"0\" checked=\"checked\" />create a new account (use text fields below)</td></tr>\n";
	echo "</table>\n<fieldset title=\"New user\"><legend>New user</legend>\n<table>\n";
	echo "<tr><td style=\"width: 275px\">New username:</td><td><input type=\"text\" name=\"mysql_new_user\" /></td></tr>\n";
	echo "<tr><td style=\"width: 275px\">New password:</td><td><input type=\"password\" name=\"mysql_new_pass1\" /></td></tr>\n";
	echo "<tr><td style=\"width: 275px\">Confirm new password:</td><td><input type=\"password\" name=\"mysql_new_pass2\" /></td></tr>\n";
	echo "</table>\n";
	echo "</fieldset>\n";
	echo "<input type=\"submit\" value=\"Continue\">";
	echo "</form>\n";
}
if($_GET["page"]==1) {
	echo "<h1>Installation guide</h1>\n";
	if(mysql_connect($_POST["mysql_host"], $_POST["mysql_user"], $_POST["mysql_pass"]) && mysql_select_db("mysql")) {
		echo "<p>Connection to database successful.</p>";
		
		$query = mysql_query("SELECT COUNT(*) FROM user WHERE User=\"".$_POST["mysql_new_user"]."\"");
		if(mysql_result($query, 0, 0)>0 && $_POST["use_root"]==0) die("<p>User already exists. Please choose another username. <a href=\"install.php\">Back</a></p></body></html>\n");
		
		// Just use the given root account
		if($_POST["use_root"]) {
			$mysql_host = $_POST["mysql_host"];
			$mysql_user = $_POST["mysql_user"];
			$mysql_pass = $_POST["mysql_pass"];
			$write_config = 1;
		} else {
			// Create a new account.
			if($_POST["mysql_new_pass1"]!=$_POST["mysql_new_pass2"]) echo "<p>Passwords do not match.</p>";
			else {
				$mysql_user = $_POST["mysql_new_user"];
				$mysql_host = $_POST["mysql_host"];
				$mysql_pass = $_POST["mysql_new_pass1"];
				if(!$mysql_user || !$mysql_host || !$mysql_pass) echo "<p class=\"error\">Please fill out all text fields.</p>";
				if(mysql_query("INSERT INTO user (Host, User, Password, Select_priv, Insert_priv, Delete_priv, Update_priv, Grant_priv, Drop_priv, Create_priv, Reload_priv, Alter_priv, Create_view_priv, ssl_cipher, x509_issuer, x509_subject) VALUES (\"$mysql_host\", \"$mysql_user\", password(\"$mysql_pass\"), \"Y\", \"Y\", \"Y\", \"Y\", \"Y\", \"Y\", \"Y\", \"Y\", \"Y\", \"Y\", \"\", \"\", \"\")")) {
					echo "<p>User added.</p>\n";
					mysql_query("FLUSH PRIVILEGES");
					$write_config = 1;
				} else {
					echo "<p>Could not add user.</p>\n";
					if($debug) echo "<p class=\"error\">".mysql_error()."</p>\n";
					$write_config = 0;
				}
			}
		}
		
		if($write_config) {
			// this is the content of the new config.inc.php
			$new_config = "<?php\n";
			$new_config .= "// The MySQL hostname. In most cases, \"localhost\" should be the best choice\n";
			$new_config .= "\$mysql_host = \"$mysql_host\";\n\n";
			$new_config .= "// The MySQL user. It needs a lot of privileges. Please see documentation.\n";
			$new_config .= "\$mysql_user = \"$mysql_user\";\n\n";
			$new_config .= "// The Password to the username above.\n";
			$new_config .= "\$mysql_pass = \"$mysql_pass\";\n\n";	
			$new_config .= "?>\n";
			
			// Now we have to modify the config.inc.php
			if(!$handle = fopen("config.inc.php", "w")) echo "<p>Could not open \"config.inc.php\".</p>\n";
			if(fwrite($handle, $new_config)) echo "<p>New config.inc.php written.</p>\n";
			else echo "<p>Could not write to \"config.inc.php\".</p>\n";
		
			echo "<p>Now please choose a database name where the data of the web interface can be stored.</p>\n";
			echo "<form action=\"install.php?page=2\" method=\"post\">";
			echo "<table>\n";
			echo "<tr><td>Name:</td><td><input type=\"text\" name=\"mysql_new_daba\" value=\"ltpda_admin\" /></td></tr>\n";
			echo "<tr><td>Submit:</td><td><input type=\"submit\" value=\"Continue\" /></td></tr>\n";
			echo "</table>\n";
			echo "</form>";
		}
	} else echo "<p>MySQL connection failed. Maybe you typed the wrong username?</p>\n";
}
if($_GET["page"]==2) {
	include("config.inc.php");
	echo "<h1>Installation guide</h1>\n";
	if(mysql_connect($mysql_host, $mysql_user, $mysql_pass)) {
		$daba = $_POST["mysql_new_daba"];
		$base_path = $_SERVER["HOME"];
		$big_query = <<<END

CREATE database $daba;
USE $daba;

DROP TABLE IF EXISTS `available_dbs`;
CREATE TABLE `available_dbs` (
 `id` int(10) NOT NULL auto_increment,
 `db_name` varchar(50) NOT NULL,
 `name` varchar(50) NOT NULL,
 `description` text NOT NULL,
 `version` INT DEFAULT 2,
 PRIMARY KEY  (`id`),
 UNIQUE KEY `database` (`db_name`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
 `id` int(11) NOT NULL auto_increment,
 `username` varchar(50) NOT NULL,
 `family_name` varchar(50) NOT NULL,
 `given_name` varchar(50) NOT NULL,
 `email` varchar(80) NOT NULL,
 `institution` varchar(150) NOT NULL,
 `telephone` varchar(50) NOT NULL,
 `is_admin` tinyint(1) NOT NULL,
 PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `options`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `options` (
  `name` varchar(50) NOT NULL,
  `value` text NOT NULL,
  PRIMARY KEY  (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

INSERT INTO `options` (`name`, `value`) VALUES ("robot_gnuplot_format_string", "png size 1024,768");
INSERT INTO `options` (`name`, `value`) VALUES ("robot_gnuplot_extension", "png");
INSERT INTO `options` (`name`, `value`) VALUES ("robot_gnuplot_path", "/usr/bin/env gnuplot");
INSERT INTO `options` (`name`, `value`) VALUES ("robot_plot_path", "$base_path/plots/%database%");
INSERT INTO `options` (`name`, `value`) VALUES ("robot_path", "$base_path/ltpda_robot.rb");

CREATE DATABASE IF NOT EXISTS test;

END;
		$query_array = explode(";", $big_query);
		$error = 0;
		while($row = array_shift($query_array)) {
			if(!mysql_query($row)) { if(mysql_error()!="Query was empty") echo mysql_error(); $error++; }
		}
		
		// Change default download format on Ubuntu to postscript, because gnuplot on Ubuntu does not create pdf files
		$ausgabe = exec("uname -a");
		if(preg_match("/Ubuntu/i", $ausgabe)) {
			mysql_query("INSERT INTO `options` (`name`, `value`) VALUES ('robot_download_gnuplot_format_string', 'postscript color')");
			mysql_query("INSERT INTO `options` (`name`, `value`) VALUES ('robot_download_gnuplot_extension', 'ps')");
		} else {
			mysql_query("INSERT INTO `options` (`name`, `value`) VALUES ('robot_download_gnuplot_format_string', 'pdf color')");
			mysql_query("INSERT INTO `options` (`name`, `value`) VALUES ('robot_download_gnuplot_extension', 'pdf')");
		}
		
                // set version to current version
                $rv = mysql_query(sprintf("INSERT INTO options (name, value)
                                           VALUES ('version', '%s')", 
                                          mysql_real_escape_string($custom_version)));
                if (!$rv) {
                     $error = mysql_error();
                     echo "<p>Error: $error</p>";
                }
				

		// Seems to be ironic, if anything went wrong before, but the query above does produce errors like "empty query"
		// That means, I cannot easily test if all the queries did work.
		echo "<p>Database successfully created.</p>\n";
		
		mysql_query("create database test");
		
		// this is the content of the new config.inc.php
		$new_config = "<?php\n";
		$new_config .= "// The MySQL hostname. In most cases, \"localhost\" should be the best choice\n";
		$new_config .= "\$mysql_host = \"$mysql_host\";\n\n";
		$new_config .= "// The MySQL user. It needs a lot of privileges. Please see documentation.\n";
		$new_config .= "\$mysql_user = \"$mysql_user\";\n\n";
		$new_config .= "// The Password to the username above.\n";
		$new_config .= "\$mysql_pass = \"$mysql_pass\";\n\n";	
		$new_config .= "// The database where the web interface data is stored.\n";
		$new_config .= "\$mysql_database = \"$daba\";\n\n";
		$new_config .= "// Set this to 1 to get more detailed error messages.\n";
		$new_config .= "\$debug = 0;\n";
		$new_config .= "?>\n";
		
		// Now we have to modify the config.inc.php
		if(!$handle = fopen("config.inc.php", "w")) echo "<p>Could not open \"config.inc.php\".</p>\n";
		if(fwrite($handle, $new_config)) echo "<p>New config.inc.php written.</p>\n";
		else echo "<p>Could not write to \"config.inc.php\".</p>\n";
	} else echo "<p>Could not connect to database. Please check \"config.inc.php\" or go back to <a href=\"install.php\">Page 1</a>.</p>\n";
	
	echo "<p>Now we need the URL of this project.</a>";
	echo "<form action=\"install.php?page=3\" method=\"post\">\n";
	echo "<table>\n";
	echo "<tr><td>URL of this project:</td><td><input type=\"text\" size=\"50\" name=\"new_project_url\" value=\"http://".$_SERVER["SERVER_NAME"].substr($_SERVER["PHP_SELF"], 0, strrpos($_SERVER["PHP_SELF"], "/"))."/\" /></td></tr>\n";
	echo "<tr><td>Submit:</td><td><input type=\"submit\" value=\"Create\"></td></tr>\n";
	echo "</table>\n";
	echo "</form>";
}

if($_GET["page"]==3) {
	
	$project_url = $_POST["new_project_url"];
	
	include("config.inc.php");
	
	if(substr($project_url, strlen($project_url)-2, 1)!="/") $project_url = $project_url."/";
	
	if(mysql_connect($mysql_host, $mysql_user, $mysql_pass) && mysql_select_db($mysql_database)) {
		$query = mysql_query("INSERT INTO options (name, value) VALUES (\"mail_text\", \"Hello\nA new account for the LTPDA project has been created for you.\n\nYour login data:\nUsername: %username%\nPassword: %password%\nProject URL: ".mysql_real_escape_string($project_url)."\n\nThe LTPDA project manager\"), (\"mail_subject\", \"New LTPDA-Account\"), (\"project_url\", \"".mysql_real_escape_string($project_url)."\"), (\"mail_text_reset\", \"Hello\nYou asked to reset your password. You can login with this new password now. You can change it on your profile page.\n\nYour login data:\nUsername: %username%\nPassword: %password%\nProject URL: ".mysql_real_escape_string($project_url)."\n\nThe LTPDA project manager\"), (\"mail_subject_reset\", \"LTPDA-Account reset\"), (\"robot_ext_plot_path\", \"".mysql_real_escape_string($project_url)."plots/%database%\")");
		if(!$query) echo "<p>Could not save project descriptions.</p><p>".mysql_error()."</p>";
	} else "<p>Cannot connect to database.</p>";
	
	echo "<p>At last, you need to set up an initial administration account. Please choose a username, password and give some information about you. <a href=\"readme.html#firstaccount\">-&gt; More details</a></p>";
	echo "<form action=\"install.php?page=4\" method=\"post\">\n";
	echo "<table>\n";
	echo "<tr><td>Username:</td><td><input type=\"text\" name=\"new_username\" /></td></tr>\n";
	echo "<tr><td>Password:</td><td><input type=\"password\" name=\"new_password1\" /></td></tr>\n";
	echo "<tr><td>Confirm password:</td><td><input type=\"password\" name=\"new_password2\" /></td></tr>\n";
	echo "<tr><td>Given Name:</td><td><input type=\"text\" name=\"new_given_name\" /></td></tr>\n";
	echo "<tr><td>Family name:</td><td><input type=\"text\" name=\"new_family_name\" /></td></tr>\n";
	echo "<tr><td>E-mail address:</td><td><input type=\"text\" name=\"new_email\" /></td></tr>\n";
	echo "<tr><td>Institution:</td><td><input type=\"text\" name=\"new_institution\" /></td></tr>\n";
	echo "<tr><td>Telephone:</td><td><input type=\"text\" name=\"new_telephone\" /></td></tr>\n";
	echo "<tr><td>Submit:</td><td><input type=\"submit\" value=\"Create\"></td></tr>\n";
	echo "</table>\n";
	echo "</form>\n";
}
if($_GET["page"]==4) {
	include("config.inc.php");
	if(mysql_connect($mysql_host, $mysql_user, $mysql_pass) && mysql_select_db($mysql_database)) {
		$query = mysql_query("SELECT COUNT(*) FROM users WHERE is_admin=1");
		if(mysql_result($query, 0, 0)==0) {
			$username = $_POST["new_username"];
			$password1 = $_POST["new_password1"];
			$password2 = $_POST["new_password2"];
			$given_name = $_POST["new_given_name"];
			$family_name = $_POST["new_family_name"];
			$institution = $_POST["new_institution"];
			$telephone = $_POST["new_telephone"];
			$email = $_POST["new_email"];
			if($password1==$password2) {

                             foreach (array("localhost", "%") as $host) {
                                  $rv = mysql_query(sprintf("CREATE USER '%s'@'%s' IDENTIFIED BY '%s'", 
                                                            mysql_real_escape_string($username),
                                                            mysql_real_escape_string($host),
                                                            mysql_real_escape_string($password1)));
                                  if (!$rv) {
                                       $error = mysql_error();
                                       echo "<p class=\"erorr\">$error</p>";
                                  }
                             }
                             $rv = mysql_query(sprintf("INSERT INTO users (username, given_name, family_name,
                                                                           email, telephone, institution, is_admin)
                                                        VALUES ('%s', '%s', '%s', '%s', '%s', '%s', 1)",
                                                       mysql_real_escape_string($username),
                                                       mysql_real_escape_string($given_name),
                                                       mysql_real_escape_string($family_name),
                                                       mysql_real_escape_string($email),
                                                       mysql_real_escape_string($telephone),
                                                       mysql_real_escape_string($institution)));


                             if($rv)
                                  echo "<p class=\"success\">User added successfully.</p>\n<p>You can go to the <a href=\"index.php\">login page</a> now. It is generally a good idea to delete the \"install.php\", when everything works. Also, change the rights for config.inc.php back to normal (as root: chmod a-w config.inc.php).</p>\n";
                             else 
                                  echo "<p class=\"error\">Could not create user.</p>\n".mysql_error();

                             mysql_query("INSERT INTO options (name, value) VALUES (\"admin_mail\", \"".mysql_real_escape_string("$given_name $family_name <$email>")."\")");
			} else echo "<p class=\"error\">Passwords do not match.</p>\n";
		} else echo "<p>There is already a user with administration rights in the database. For security reasons this script cannot create a second administrator.</p>";
		
	} else "<p>Cannot connect to database.</p>";
}
?>
</body>
</html>
