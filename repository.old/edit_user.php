<?php
include("config.inc.php"); // some constants
include("passtest.inc.php"); // checks the User/Password

include("privs.inc.php");

$user_id = $_GET["id"] + 0; // plus 0 to be sure it's a number (prevents SQL-injections)

// Set vars
if(!isset($_POST["db_name"])) $_POST["db_name"] = "";
if(!isset($_POST["database_change"])) $_POST["database_change"] = "";
if(!isset($_POST["save_data"])) $_POST["save_data"] = "";
if(!isset($_POST["isadmin_field"])) $_POST["isadmin_field"] = "";
if(!isset($_POST["hostnames"])) $_POST["hostnames"] = "";

$title = "Edit user";
if($passtest==$user_id) $title = "Your profile";
// $CVS_TAG="$Id: edit_user.php,v 1.27 2012/01/25 18:26:52 gerrit Exp $";
include("header.inc.php");

if($passtest && $connected) {
	echo "<h1>$title</h1>";
	if($is_admin || $passtest==$user_id) {
		
		// Check if theres data to save:
		if($_POST["save_data"]=="Save") {
			
			$given_name = mysql_real_escape_string($_POST["given_name"]);
			$family_name = mysql_real_escape_string($_POST["family_name"]);
			$email = mysql_real_escape_string($_POST["email"]);
			$institution = mysql_real_escape_string($_POST["institution"]);
			$telephone = mysql_real_escape_string($_POST["telephone"]);
			$hostnames = $_POST["hostnames"];
			$passwd1 = mysql_real_escape_string($_POST["passwd1"]);
			$passwd2 = mysql_real_escape_string($_POST["passwd2"]);
			
			$query = mysql_query("UPDATE users SET given_name=\"$given_name\", family_name=\"$family_name\", telephone=\"$telephone\", institution=\"$institution\", email=\"$email\" WHERE id=".$user_id);
			if($query) echo "<p class=\"success\">Personal data saved.</p>\n";
			else {
				echo "<p class=\"error\">Personal data could not be saved.</p>\n";
				if($debug) echo "<p class=\"error\">".mysql_error()."</p>\n";
			}
			if($is_admin && $_POST["isadmin_field"]) $query = mysql_query("UPDATE users SET is_admin=1 WHERE id=".$user_id);
			if($is_admin && !$_POST["isadmin_field"] && $passtest!=$user_id) $query = mysql_query("UPDATE users SET is_admin=0 WHERE id=".$user_id);

			if($passwd1) {
				if($passwd1==$passwd2) {
                                     // get username
                                     $query = mysql_query("SELECT username FROM users WHERE id=".$user_id);
                                     $username = mysql_result($query, 0, 0);
                                     
                                     // set password
                                     foreach (array("localhost", "%") as $host) {
                                          $rv = mysql_query(sprintf("SET PASSWORD FOR '%s'@'%s' = PASSWORD('%s')",
                                                                    mysql_real_escape_string($username),
                                                                    mysql_real_escape_string($host),
                                                                    $passwd1));
                                          if (!$rv) {
                                               echo "<p class=\"error\">Could not change password.</p>\n";
                                               if($debug) echo "<p class=\"error\">".mysql_error()."</p>\n";
                                               break;
                                          }
                                     }
                                     if ($rv) {
                                          echo "<p class=\"success\">Password changed.</p>\n";
                                          if($user_id==$passtest) $_SESSION["passwd"]=$passwd1;
                                     }
                                } else echo "<p class=\"error\">Passwords do not match.</p>\n";
			}
		}
		
		if($_POST["database_change"]=="Save" && $is_admin) {
                     
                        // get username
                        $query = mysql_query("SELECT username FROM users WHERE id=".$user_id);
                        $username = mysql_result($query, 0, 0);

			$db_name = isset($_POST["db_name"]) ? $_POST["db_name"] : "";
			$select_priv = isset($_POST["select_priv"]) ? $_POST["select_priv"] : 0;
			$insert_priv = isset($_POST["insert_priv"]) ? $_POST["insert_priv"] : 0;
			$update_priv = isset($_POST["update_priv"]) ? $_POST["update_priv"] : 0;
			$delete_priv = isset($_POST["delete_priv"]) ? $_POST["delete_priv"] : 0;
			$new_db_name = isset($_POST["new_db_name"]) ? $_POST["new_db_name"] : "";
			$new_select_priv = isset($_POST["new_select_priv"]) ? $_POST["new_select_priv"]+0 : 0;
			$new_insert_priv = isset($_POST["new_insert_priv"]) ? $_POST["new_insert_priv"]+0 : 0;
			$new_update_priv = isset($_POST["new_update_priv"]) ? $_POST["new_update_priv"]+0 : 0;
			$new_delete_priv = isset($_POST["new_update_priv"]) ? $_POST["new_delete_priv"]+0 : 0;

			// Update the rights:
			$error = 0;
			for ($i=0; $i<count($db_name); $i++) {
			             if(isset($db_name[$i])) {
                             $error += setpriv('SELECT', $select_priv[$i]+0, $username, $db_name[$i], '%');
                             $error += setpriv('INSERT', $insert_priv[$i]+0, $username, $db_name[$i], '%');
                             $error += setpriv('UPDATE', $update_priv[$i]+0, $username, $db_name[$i], '%');
                             $error += setpriv('DELETE', $delete_priv[$i]+0, $username, $db_name[$i], '%');
                         }
			}

			// Add a database:
			if (($new_select_priv + $new_insert_priv + $new_update_priv + $new_delete_priv)>0) {
                             $error += setpriv('SELECT', $new_select_priv+0, $username, $new_db_name, '%');
                             $error += setpriv('INSERT', $new_insert_priv+0, $username, $new_db_name, '%');
                             $error += setpriv('UPDATE', $new_update_priv+0, $username, $new_db_name, '%');
                             $error += setpriv('DELETE', $new_delete_priv+0, $username, $new_db_name, '%');
			}

                        if (!$error)
                             echo "<p class=\"success\">Permissions saved.</p>\n";
		}
		
		$query = mysql_query("SELECT username, given_name, family_name, email, is_admin, institution, telephone FROM users WHERE id=".$user_id);
		$username = mysql_result($query, 0, 0);
		$given_name = mysql_result($query, 0, 1);
		$family_name = mysql_result($query, 0, 2);
		$email = mysql_result($query, 0, 3);
		$isadmin_field = mysql_result($query, 0, 4);
		$institution = mysql_result($query, 0, 5);
		$telephone = mysql_result($query, 0, 6);
				
		echo "<h2>Username: $username</h2>\n";
		echo "<form action=\"edit_user.php?id=$user_id\" method=\"post\"><fieldset>\n";
		echo "<table>\n";
		echo "<tr><td>Given name:</td><td><input type=\"text\" name=\"given_name\" value=\"$given_name\" /></td></tr>\n";
		echo "<tr><td>Family name:</td><td><input type=\"text\" name=\"family_name\" value=\"$family_name\" /></td></tr>\n";
		echo "<tr><td>E-mail:</td><td><input type=\"text\" name=\"email\" value=\"$email\" /></td></tr>\n";
		echo "<tr><td>Institution:</td><td><input type=\"text\" name=\"institution\" value=\"$institution\" /></td></tr>\n";
		echo "<tr><td>Telephone:</td><td><input type=\"text\" name=\"telephone\" value=\"$telephone\" /></td></tr>\n";
		echo "<tr><td>Password:</td><td><input type=\"password\" name=\"passwd1\" /></td></tr>\n";
		echo "<tr><td>Confirm:</td><td><input type=\"password\" name=\"passwd2\" /></td></tr>\n";
		
		if($is_admin) {
                     // prevent the admin from deactivting himself:
                     if($user_id == $passtest) $disabled="disabled=\"disabled\"";
                     else $disabled="";
                     
                     if ($isadmin_field) {
                          echo "<tr><td>User is admin:</td><td><input type=\"checkbox\" name=\"isadmin_field\" checked=\"checked\" $disabled /></td></tr>\n";
                     } else {
                          echo "<tr><td>User is admin:</td><td><input type=\"checkbox\" name=\"isadmin_field\" /></td></tr>\n";
                     }
		}
		
		echo "<tr><td>Submit:</td><td><input type=\"submit\" name=\"save_data\" value=\"Save\" /></td></tr>\n";
		echo "</table>\n";
		echo "</fieldset></form>\n";
		
		if($is_admin) {
			echo "<h2>Allowed databases:</h2>\n\n";
			echo "<form action=\"edit_user.php?id=$user_id\" method=\"post\"><fieldset>\n";
			echo "<table style=\"border-spacing: 7px;\">\n";
			echo "<tr><th colspan=\"2\">database</th><th colspan=\"4\">permissions</th></tr>\n";
			echo "<tr><th>mysql</th><th>name</th><th>read</th><th>insert</th><th>update</th><th>delete</th></tr>\n";

                        // use the column-1 trick to convert a N,Y enum to a 0,1 boolean value
                        $query = mysql_query(sprintf("SELECT DISTINCT db.Db, a.name,
                                                      db.Select_priv-1, db.Insert_priv-1, db.Update_priv-1, db.Delete_priv-1
                                                      FROM mysql.db AS db, available_dbs AS a
                                                      WHERE User = '%s' AND a.db_name=db.Db", mysql_real_escape_string($username)));

                        if (!$query)
                             echo "<p class=\"error\">".mysql_error()."</p>\n";

			$i=0;
			while($row = mysql_fetch_array($query, MYSQL_NUM)) {

				if($row[2]) $row[2] = "<input type=\"checkbox\" name=\"select_priv[$i]\" checked=\"checked\" value=\"1\" />";
				else $row[2] = "<input type=\"checkbox\" name=\"select_priv[$i]\" value=\"1\" />";
				
				if($row[3]) $row[3] = "<input type=\"checkbox\" name=\"insert_priv[$i]\" checked=\"checked\" value=\"1\" />";
				else $row[3] = "<input type=\"checkbox\" name=\"insert_priv[$i]\" value=\"1\" />";
				
				if($row[4]) $row[4] = "<input type=\"checkbox\" name=\"update_priv[$i]\" checked=\"checked\" value=\"1\" />";
				else $row[4] = "<input type=\"checkbox\" name=\"update_priv[$i]\" value=\"1\" />";
				
				if($row[5]) $row[5] = "<input type=\"checkbox\" name=\"delete_priv[$i]\" checked=\"checked\" value=\"1\" />";
				else $row[5] = "<input type=\"checkbox\" name=\"delete_priv[$i]\" value=\"1\" />";
				
				
				echo "<tr><td>".$row[0]."<input type=\"hidden\" name=\"db_name[$i]\" value=\"".$row[0]."\" /></td>";
                                echo "<td>".$row[1]."</td>";
                                echo "<td>".$row[2]."</td>";
                                echo "<td>".$row[3]."</td>";
                                echo "<td>".$row[4]."</td>";
                                echo "<td>".$row[5]."</td></tr>\n";
				$i += 1;
			}
			
			echo "<tr><td>add this db:</td><td><select name=\"new_db_name\">";
			$query = mysql_query("SELECT db_name FROM available_dbs WHERE db_name NOT IN (SELECT db FROM `mysql`.`db` WHERE User='".mysql_real_escape_string($username)."' AND (Select_priv='Y' OR Insert_priv='Y' OR Update_priv='Y' OR Delete_priv='Y'))");
			if($query) {
			    while($row=mysql_fetch_array($query, MYSQL_NUM)) echo "<option value=\"".$row[0]."\">".$row[0]."</option>";
		    }
			echo "</select></td><td><input type=\"checkbox\" name=\"new_select_priv\" value=\"1\" /></td><td><input type=\"checkbox\" name=\"new_insert_priv\" value=\"1\" /></td><td><input type=\"checkbox\" name=\"new_update_priv\" value=\"1\" /></td><td><input type=\"checkbox\" name=\"new_delete_priv\" value=\"1\" /></td></tr>\n";
			echo "</table>\n";
			echo "<input type=\"submit\" name=\"database_change\" value=\"Save\" /></fieldset></form>\n";
			
		}
	} else echo "<p class=\"error\">Sorry, you do not have the rights to view this page.</p>\n";
} else include("login.inc.php");

include("footer.inc.php");
?>
