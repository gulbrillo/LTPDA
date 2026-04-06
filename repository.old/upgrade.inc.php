<?php
// $CVS_TAG="$Id: upgrade.inc.php,v 1.15 2012/01/20 07:40:24 gerrit Exp $";

// upgrade from database layout version 2.0 to 2.1
function upgrade_20_21()
{
     global $mysql_database;

     // for each database
     $query = mysql_query("SELECT db_name FROM available_dbs");
     while ($database = mysql_fetch_row($query)) {
          mysql_query("USE `".mysql_real_escape_string($database[0])."`");
          // add uuid column
          $rv = mysql_query("ALTER TABLE `objs` ADD `uuid` TEXT NOT NULL
                             COMMENT 'Unique Global Identifier for this object'");
          if (!$rv) 
               return mysql_error();
     }
    mysql_query("USE `".$mysql_database."`");

    return 0;
}

// upgrade from database layout version 2.1 to 2.2
function upgrade_21_22()
{
     global $mysql_database;

     $tables = array();
     $tables[] = array("table" => "fsdata", "field" => "fs");
     $tables[] = array("table" => "mfir", "field" => "fs");
     $tables[] = array("table" => "miir", "field" => "fs");
     $tables[] = array("table" => "tsdata", "field" => "fs");
     $tables[] = array("table" => "tsdata", "field" => "nsecs");
     
     // for each database
     $query = mysql_query("SELECT db_name FROM available_dbs");
     while ($database = mysql_fetch_row($query)) {
          mysql_query("USE `".mysql_real_escape_string($database[0])."`");
		
          foreach ($tables as $table) {
               $subquery = mysql_query(sprintf("SHOW FULL COLUMNS FROM `%s` LIKE '%s'", 
                                               $table["table"], $table["field"]));
               $comment = mysql_result($subquery, 0, 8);
               // change int columns to double columns
               $rv = mysql_query(sprintf("ALTER TABLE `%s` CHANGE `%s` `%s` DOUBLE COMMENT '%s'",
                                         $table["table"], $table["field"], $table["field"],
                                         mysql_real_escape_string($comment)));
               if (!$rv) 
                    return mysql_error();
          }
    }
    mysql_query("USE `".$mysql_database."`");

    return 0;
}

// upgrade from database layout version 2.2 to 2.3
function upgrade_22_23()
{
     global $mysql_database;

     // for each database
     $query = mysql_query("SELECT db_name FROM available_dbs");
     while ($database = mysql_fetch_row($query)) {
          mysql_query("USE `".mysql_real_escape_string($database[0])."`");

          // add obj_id index
          $rv = mysql_query("ALTER TABLE `bobjs` ADD INDEX object_index(`obj_id`)");
          if (!$rv) 
               return mysql_error();

          // add author column
          $rv = mysql_query("ALTER TABLE `objmeta`
                             ADD COLUMN `author` TEXT DEFAULT NULL
                             COMMENT 'Author of the object' AFTER `vdate`");
     }
     mysql_query("USE `".$mysql_database."`");

    return 0;
}
    
// upgrade from database layout version 2.3 to 2.4
function upgrade_23_24()
{
     global $mysql_database;

     $query = mysql_query("DESCRIBE available_dbs");
     while ($field = mysql_fetch_row($query)) {
          if ($field[0] == "version") {
               // available_dbs table already contains version column
               return;
          }
     }
     // add version column to available_dbs
     $rv = mysql_query("ALTER TABLE `available_dbs` 
                        ADD COLUMN `version` INT DEFAULT 1
                        COMMENT 'version of the database layout'");
     if (!$rv)
          return mysql_error();
     
     mysql_query("USE `".$mysql_database."`");

     return 0;
}

// upgrade from database layout version 2.4 to 2.5
function upgrade_24_25()
{
     global $mysql_database;
	 global $_SERVER;

     // consolidate privileges: there is no need to specify grants
     // both for 'localhost' and for '%' hosts. drop privileges
     // granted for 'localhost'
     add_wildcard_access();

     // drop privileges granted explicitly on transactions tables
     $rv = mysql_query("DELETE mysql.tables_priv FROM mysql.tables_priv, users
                        WHERE mysql.tables_priv.User=users.username AND mysql.tables_priv.Table_name='transactions'");
     if (!$rv)
          return mysql_error();

     // tell mysql to reload grant tables
     $rv = mysql_query("FLUSH PRIVILEGES");
     if (!$rv)
          return mysql_error();

	//echo "Dropping unnessecary user_access und user_hosts tables...<br />";
     // drop unused tables
     $rv = mysql_query("DROP TABLE IF EXISTS user_access");
     if (!$rv)
          return mysql_error();
     $rv = mysql_query("DROP TABLE IF EXISTS user_hosts");
     if (!$rv)
          return mysql_error();

	//echo "Dropping password field from users<br />";
     // drop password column from users table in administrative
     // database: authentication is done using mysql database
     $rv = mysql_query("SHOW COLUMNS FROM users WHERE field='password'");
     if (mysql_num_rows($rv) > 0) {
          $rv = mysql_query("ALTER TABLE users DROP COLUMN password");
          if (!$rv)
               return mysql_error();
     }

     // for each database
	//echo "Creating users views...<br />";
    /*
 	$query = mysql_query("SELECT db_name FROM available_dbs");
     while ($database = mysql_fetch_row($query)) {
          if(!mysql_select_db($database[0])) {
			  echo "<p class='error'>Could not switch to database $database</p>";
			  return mysql_error();
		  }

          // drop users table
          $rv = mysql_query("DROP TABLE IF EXISTS `users`");
          if (!$rv)
               return mysql_error();

          // replace with a view
          $rv = mysql_query(sprintf("CREATE VIEW `users` 
                                     AS SELECT id, username FROM `%s`.users",
                                    mysql_real_escape_string($mysql_database)));
          if (!$rv) 
               return mysql_error();
     }
     mysql_select_db($mysql_database);
	*/
	
	// echo "Adding insert access to transactions table...<br />";
	// Add insert access to transactions table for every user who has at least read access to the database
	$query = mysql_query("SELECT db_name FROM available_dbs");
    while ($database = mysql_fetch_row($query)) {
		$db = $database[0];
		$result = mysql_query("SELECT username FROM users LEFT JOIN mysql.db ON mysql.db.User=users.username WHERE mysql.db.Db='$db' AND (mysql.db.Select_priv='Y' OR mysql.db.Insert_priv='Y' OR mysql.db.Update_priv='Y' OR mysql.db.Delete_priv='Y')");
		if(!$result) echo mysql_error();
		if(!mysql_num_rows($result)) echo "<p>No users found.</p>\n";
		while($row=mysql_fetch_row($result)) {
			$user = $row[0];
			$result_grant = mysql_query("GRANT INSERT ON `$db`.transactions TO '$user'@'%'");
			if(!$result_grant) echo mysql_error();
		}
	}
	// tell mysql to reload grant tables
    $rv = mysql_query("FLUSH PRIVILEGES");
    if (!$rv) return mysql_error();

	// echo "Creating default options for robot...<br />";

	// Create default options for the plot robot
	$result = mysql_query("INSERT INTO `options` (`name`, `value`) VALUES ('robot_gnuplot_format_string', 'png size 1024,768')");
	if(!$result) return mysql_error();
	mysql_query("INSERT INTO `options` (`name`, `value`) VALUES ('robot_gnuplot_extension', 'png')");
	mysql_query("INSERT INTO `options` (`name`, `value`) VALUES ('robot_gnuplot_path', '/usr/bin/env gnuplot')");
	mysql_query(sprintf("INSERT INTO `options` (`name`, `value`) VALUES ('robot_plot_path', '%s')",	$_SERVER["DOCUMENT_ROOT"]."/plots/%database%"));
	mysql_query(sprintf("INSERT INTO `options` (`name`, `value`) VALUES ('robot_ext_plot_path', '%s')",	"http://".$_SERVER["HTTP_HOST"].substr($_SERVER["PHP_SELF"], 0, strrpos($_SERVER["PHP_SELF"], "/"))."/plots/%database%"));
	mysql_query("DELETE FROM `options` WHERE name='plot_path'");
	
	// Change default download format on Ubuntu to postscript, because gnuplot on Ubuntu does not create pdf files
	$ausgabe = exec("uname -a");
	if(preg_match("/Ubuntu/i", $ausgabe)) {
		mysql_query("INSERT INTO `options` (`name`, `value`) VALUES ('robot_download_gnuplot_format_string', 'postscript color')");
		mysql_query("INSERT INTO `options` (`name`, `value`) VALUES ('robot_download_gnuplot_extension', 'ps')");
	} else {
		mysql_query("INSERT INTO `options` (`name`, `value`) VALUES ('robot_download_gnuplot_format_string', 'pdf color')");
		mysql_query("INSERT INTO `options` (`name`, `value`) VALUES ('robot_download_gnuplot_extension', 'pdf')");
	}
	
	// Change filename of plot robot
	$robot_path = $_SERVER["DOCUMENT_ROOT"]."/ltpda_robot.rb";
	mysql_query("UPDATE `options` SET value='$robot_path' WHERE name='robot_path'");

    return 0;
}

function add_wildcard_access()
{
	global $mysql_database;
	
	$error = 0;
	// Get all combinations of at least read access 
	$access_query = mysql_query("SELECT users.username, user_access.db_name,
		                                user_access.select_priv, user_access.insert_priv,
		                                user_access.update_priv, user_access.delete_priv 
		                                FROM users, user_access");
	
	// Put everything in an array, because database will be switched after that.
	$access_list = array();
	while($row = mysql_fetch_row($access_query)) {
		array_push($access_list, $row);
	}
	
	// Switch to mysql database
	mysql_select_db("mysql");
	
	foreach($access_list as $access_combination) {
		$username = $access_combination[0];
		$db_name = $access_combination[1];
		$select_priv = $access_combination[2] ? "Y" : "N";
		$insert_priv = $access_combination[3] ? "Y" : "N";
		$update_priv = $access_combination[4] ? "Y" : "N";
		$delete_priv = $access_combination[5] ? "Y" : "N";
		
		// Delete all previous access entries
		$query = mysql_query("DELETE FROM db WHERE user='$username' AND db='$db_name'");
		
		// Add a new entry with a host wildcard
		$querytext = "INSERT INTO db (User, Db, Host, Select_priv, Insert_priv, Update_priv, Delete_priv)
		                      VALUES ('$username', '$db_name', '%',
			                          '$select_priv', '$insert_priv', '$update_priv', '$delete_priv')";
		$query = mysql_query($querytext);
		
		if(!$query) {
			echo "<p class='error'>".mysql_error()." - $querytext</p>";
			$error++;
		}
	}
	
	mysql_select_db($mysql_database);
	
	return $error;
}

function set_schema_version($ver)
{
     // set the new schema version
     $rv = mysql_query("INSERT INTO options (name, value)
                        VALUES ('version', '$ver')
                        ON DUPLICATE KEY UPDATE value='$ver'");
     if (!$rv) {
          echo "<p class=\"error\">$error</p>";
          return $error;
     }

     return 0;
}

function upgrade_db_schema()
{
     // get current database schema version
     $query = mysql_query("SELECT value FROM options WHERE name='version'");
     if (mysql_num_rows($query) > 0)
          $version = mysql_result($query, 0, 0) + 0;
     else 
          $version = 1.0;

     echo "<p>Current version: $version</p>";

     if ($version < 2.1) {
          echo "<p>Updating table definitions from 2.0 to 2.1...</p>";
          $error = upgrade_20_21();
          if ($error) {
               echo "<p class=\"error\">$error</p>";
               return $error;
          }
          set_schema_version(2.1);
     }
     
     if ($version < 2.2) {
          echo "<p>Updating table definitions from 2.1 to 2.2...</p>";
          $error = upgrade_21_22();
          if ($error) {
               echo "<p class=\"error\">$error</p>";
               return $error;
          }
          set_schema_version(2.2);
     }
     
     if ($version < 2.3) {
          echo "<p>Updating table definitions from 2.2 to 2.3...</p>";
          $error = upgrade_22_23();
          if ($error) {
               echo "<p class=\"error\">$error</p>";
               return $error;
          }
          set_schema_version(2.3);
     }
     
     if ($version < 2.4) {
          echo "<p>Updating table definitions from 2.3 to 2.4...</p>";
          $error = upgrade_23_24();
          if ($error) {
               echo "<p class=\"error\">$error</p>";
               return $error;
          }
          set_schema_version(2.4);
     }
     
     if ($version < 2.5) {
          echo "<p>Updating table definitions from 2.4 to 2.5...</p>";
          $error = upgrade_24_25();
          if ($error) {
               echo "<p class=\"error\">$error</p>";
               return $error;
          }
          set_schema_version(2.5);
     }

     return 0;
}

?>
