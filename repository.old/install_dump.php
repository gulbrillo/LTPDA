<?php echo "<?xml version=\"1.0\" ?>"; ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Installation guide</title>
</head>
<body>
<?php
$CVS_TAG="$Id: install_dump.php,v 1.2 2010/01/14 10:31:48 gerrit Exp $";

/**
 * This script creates a new user which has all the rights that are needed by the web interface.
 * It creates the basic databases for the web interface and inserts a root account.
 */


if(!isset($_GET["page"])) {
	echo "<h1>Dump installation guide</h1>\n";
	echo "<p>This script helps you to install a previously saved database dump. If you never installed this LTPDA interface before, you may want to have a look at <a href=\"install.php\">the normal installation guide</a>.</p>\n";
	
	echo "<form action=\"install_dump.php?page=1\" method=\"post\">\n";
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
	echo "<tr><td style=\"width: 275px\">Create:</td><td><input type=\"submit\" value=\"Create\"></td></tr>\n";
	echo "</table>\n";
	echo "</form>\n";
}
if($_GET["page"]==1) {
	echo "<h1>Dump installation guide</h1>\n";
	if(mysql_connect($_POST["mysql_host"], $_POST["mysql_user"], $_POST["mysql_pass"]) && mysql_select_db("mysql")) {
		echo "<p>Connection to database successful.</p>";
		
		// Just use the given root account
				if($_POST["use_root"]) {
			$mysql_host = $_POST["mysql_host"];
			$mysql_user = $_POST["mysql_user"];
			$mysql_pass = $_POST["mysql_pass"];
				} else {
			// Create a new account.
					if($_POST["mysql_new_pass1"]!=$_POST["mysql_new_pass2"]) echo "<p>Passwords do not match.</p>";
			else {
				$mysql_user = $_POST["mysql_new_user"];
				$mysql_host = $_POST["mysql_host"];
				$mysql_pass = $_POST["mysql_new_pass1"];
				if(!$mysql_user || !$mysql_host || !$mysql_pass) echo "<p class=\"error\">Please fill out all text fields.</p>";
				if(mysql_query("INSERT INTO user (Host, User, Password, Select_priv, Insert_priv, Delete_priv, Update_priv, Grant_priv, Drop_priv, Create_priv, Reload_priv) VALUES (\"$mysql_host\", \"$mysql_user\", password(\"$mysql_pass\"), \"Y\", \"Y\", \"Y\", \"Y\", \"Y\", \"Y\", \"Y\", \"Y\")")) {
					echo "<p>User added.</p>\n";
					mysql_query("FLUSH PRIVILEGES");
				} else { echo "<p>Could not add user.</p>\n"; if($debug) echo "<p class=\"error\">".mysql_error()."</p>\n";}
			}
				}
		
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
		
		echo "<p>Now please supply the .sql file you want to insert.</p>\n";
		echo "<form enctype=\"multipart/form-data\" action=\"install_dump.php?page=2\" method=\"post\">";
		echo "File: <input type=\"file\" name=\"sqlfile\" />\n";
		echo "<input type=\"submit\" value=\"Upload\" />\n";
		echo "</form>";
	} else echo "<p>MySQL connection failed. Maybe you typed the wrong username?</p>\n";
}
if($_GET["page"]==2) {
	echo "<h1>Dump installation guide</h1>\n";
	include("config.inc.php");
	
	
	if(!mysql_connect($mysql_host, $mysql_user, $mysql_pass)) echo "<p>Could not connect to the database. Please check the config file.</p>\n";
	if(!file_exists($_FILES["sqlfile"]["tmp_name"])) echo "<p>Please upload a sql file.</p>\n";
	else {
		$handle = fopen($_FILES["sqlfile"]["tmp_name"], "r");
		if($handle) {
			$data = "";
			while(!feof($handle)) {
				$row = trim(fgets($handle));
				if(substr($row, 0, 23)=="# Admin database name: ") $daba = trim(substr($row ,23));
				if(substr($row, 0, 1)!="#") $data .= $row;
			}
			$sqlCommand = explode(";", $data);
			foreach($sqlCommand as $current) {
				if(trim($current)!="" && !mysql_query($current)) echo "<p>".mysql_error()."</p>\n";
			}
			fclose($handle);
			unlink($_FILES["sqlfile"]["tmp_name"]);
			
			echo "<p>Found admin database: \"$daba\"</p>\n";
			echo "<p>The data file has been read, you can now try to <a href=\"index.php\">login</a>.</p>\n";
		} else "<p>Could not open sql file.</p>\n";
	}
	
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
	$new_config .= "\$debug = 0;\n\n";
	$new_config .= "?>\n";
		
	// Now we have to modify the config.inc.php
	if(!$handle = fopen("config.inc.php", "w")) echo "<p>Could not open \"config.inc.php\".</p>\n";
	if(fwrite($handle, $new_config)) echo "<p>New config.inc.php written.</p>\n";
	else echo "<p>Could not write to \"config.inc.php\".</p>\n";

}
?>
</body>
</html>

