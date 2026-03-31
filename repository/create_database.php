<?php
include("config.inc.php"); // some constants
include("passtest.inc.php"); // checks the User/Password

include("privs.inc.php");

$title = "Create a new database";
// $CVS_TAG="$Id: create_database.php,v 1.29 2012/01/26 13:22:49 gerrit Exp $";
include("header.inc.php");

if(!isset($_POST["create_button"])) $_POST["create_button"] = "";
if(!isset($_POST["user_button"])) $_POST["user_button"] = "";
if(!isset($database_name)) $database_name = "";
if(!isset($database_long_name)) $database_long_name = "";
if(!isset($database_description)) $database_description  = "";

if($passtest && $connected) {
	echo "<h1>$title</h1>";
	if(!$_POST["create_button"] && !$_POST["user_button"]) {
		echo "<p>Here you can create a new database.</p>\n";
		echo "<form action=\"create_database.php\" method=\"post\">\n";
		echo "<table>\n";
		echo "<tr><td>Internal database name:</td><td><input type=\"text\" size=\"30\" name=\"database_name\" value=\"$database_name\" /></td><td>This is the name, which you will see in MatLab. It is the MySQL-Name. (only alphanumerical + underscore allowed)</td></tr>\n";
		echo "<tr><td>Formatted database name:</td><td><input type=\"text\" size=\"30\" name=\"database_long_name\" value=\"$database_long_name\" /></td><td>This is the name, that the web interface will display. It may contain spaces and can be written nicely formatted.</td></tr>\n";
		echo "<tr><td>Database description:</td><td><textarea cols=\"30\" rows=\"4\" name=\"database_description\">$database_description</textarea></td><td>Here you can type a free text describing the database.</td></tr>\n";
		echo "<tr><td>Create:</td><td><input type=\"submit\" name=\"create_button\" value=\"Create\" /></td><td></td></tr>\n";
		echo "</table>\n";
		echo "</form>\n";
	} elseif($_POST["create_button"]) {
		// Check if interface has the rights to create a view
		$result = mysql_query("SELECT Create_view_priv-1 FROM mysql.user WHERE User='$mysql_user'");
		$has_create_view_right = mysql_result($result, 0, 0);
		
		if(!$has_create_view_right) echo "<p class=\"error\">The web interface does not have enough rights to create a new database. It needs the 'create_view_priv'. Maybe you did not run the upgrade script yet?</p>\n";
		
		if($is_admin) {
			$error = 0;
			
			// Create it now:
			
			$database_name = mysql_real_escape_string($_POST["database_name"]);
			$database_long_name = mysql_real_escape_string($_POST["database_long_name"]);
			$database_description = mysql_real_escape_string($_POST["database_description"]);
			if(!preg_match('/^[a-z0-9_]+$/iD', $database_name)) {
				echo "<p class=\"error\">The internal name must only contain alphanumerical charaters or an underscore.</p>\n";
				$database_name="";
			}
			
			// Do not create empty database
			$big_query = "";
			if($database_name!="") {
				if($file = fopen("aorepo_db.sql", "r")) {
					while(!feof($file)) {
						$line = fgets($file, 4096);
						$line = trim($line);
						if(substr($line, 0, 1)!="#") $big_query .= $line."\n";
					}
					fclose($file);
				}
			
				// create the database now
				if(!mysql_query("CREATE DATABASE `$database_name`")) {
					echo "<p class=\"error\">".mysql_error()."</p>";
					$error = 1;
				} 
				else {
					if(mysql_query("USE `$database_name`")) {
						$query_array = explode(";", $big_query);
						while($row = array_shift($query_array)) {
							if(trim($row)!="" && !mysql_query($row)) {
								$error++;
								if($debug) echo "<p class=\"error\">".mysql_error()." on query: ".$row."</p>\n";
							}
						}
                                                // create users view
                                                $rv = mysql_query(sprintf("CREATE VIEW `users` 
                                                                   AS SELECT id, username FROM `%s`.users",
                                                                          mysql_real_escape_string($mysql_database)));
                                                if (!$rv) {
                                                     $error++;
                                                     if($debug) echo "<p class=\"error\">Cannot create view: ".mysql_error()."</p>\n";
                                                }
                                        }
                                }
			} else {
				echo "<p class=\"error\">Please supply a database name.</p>\n";
				$error = 1;
			}
			mysql_select_db($mysql_database);
			if($error) echo "<p class=\"error\">Database '$database_name' not successfully created.</p>\n";
			else {
				if(!mysql_query("INSERT INTO available_dbs (db_name, name, description, version) VALUES (\"$database_name\", \"$database_long_name\", \"$database_description\", 2)")) {
					echo "<p class=\"error\">Could not make database available for use.</p>\n";
					if($debug) echo "<p class=\"error\">".mysql_error()."</p>\n";
				}
				echo "<p class=\"success\">Successfully created database $database_name</p>\n";
				echo "<p>If you wish, you can select some users you want to give access to the new database.</p>\n";
				echo "<form action=\"create_database.php\" method=\"post\">\n";
				echo "<select size=\"8\" multiple=\"multiple\" name=\"users[]\">";
				$query = mysql_query("SELECT id, family_name, given_name, username FROM users ORDER BY family_name");
				while($row = mysql_fetch_array($query, MYSQL_NUM)) {
					echo "<option value=\"".$row[0]."\">".$row[1].", ".$row[2]." (".$row[3].")</option>";
				}
				echo "</select><br />\n";
				echo "<input type=\"checkbox\" name=\"write\" value=\"1\" /> Give also write permission<br />\n";
				echo "<input type=\"hidden\" name=\"database_name\" value=\"$database_name\" />\n";
				echo "<input type=\"submit\" name=\"user_button\" value=\"Add users\" />\n";
				echo "</form>\n";
				echo "<p>Back to <a href=\"index.php\">main menu</a>.</p>\n";
			}
		}
	} else {
		$users = $_POST["users"];
		if(!$users) $users = array();
		$error = 0;
		foreach($users as $user) {
                     if($user) {
                          // get username
                          $query = mysql_query(sprintf('SELECT username FROM users WHERE id = %d', $user));
                          $username = mysql_result($query, 0, 0);

                          $error += setpriv('SELECT', 1, $username, $_POST["database_name"], '%');
                          if(isset($_POST["write"]) && $_POST["write"])
                               $error += setpriv('INSERT', 1, $username, $_POST["database_name"], '%');
                     }
                }
		if(!$error) {
                     echo "<p class=\"success\">Done.</p>";
                     echo "<p>You can now go back to the <a href=\"index.php\">main menu</a>.</p>";
                }
	}
} else include("login.inc.php");

include("footer.inc.php");
?>
