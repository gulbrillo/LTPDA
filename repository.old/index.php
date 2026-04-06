<?php
include("config.inc.php"); // some constants
include("passtest.inc.php"); // checks the User/Password

// $CVS_TAG="$Id: index.php,v 1.30 2012/02/10 12:51:01 hewitson Exp $";

$title = "Main page";
$need_full_page = false;
include("header.inc.php");

if($passtest && $connected) {
	echo "<h1>$title</h1>";
	// echo "<p>Hello $user. Welcome to the ltpda web interface.</p>\n";

		// Test if version field exists
		$query = mysql_query("SHOW COLUMNS FROM available_dbs LIKE 'version'");
		if(mysql_num_rows($query)>0) $version_exists = true;
		else $version_exists = false;

        // list databases to which the user has at least read
        // permission.  the -1 trick is to convert an N,Y enum to a
        // 0,1 boolean
		if($version_exists) $query = mysql_query(sprintf("SELECT Db, name, description,
			   Select_priv-1, Insert_priv-1, Update_priv-1, Delete_priv-1, version
               FROM mysql.db, available_dbs WHERE User='%s' AND Select_priv='Y' AND Db=db_name",
               mysql_real_escape_string($user)));
		else $query = mysql_query(sprintf("SELECT Db, name, description,
			   Select_priv-1, Insert_priv-1, Update_priv-1, Delete_priv-1
               FROM mysql.db, available_dbs WHERE User='%s' AND Select_priv='Y' AND Db=db_name",
               mysql_real_escape_string($user)));

        if (!$query) {
             $error = mysql_error();
             echo "<p class=\"error\">Error: $error</p>";
        }

        // show databases 
	echo "<p>You have access to ".mysql_num_rows($query)." databases:";
        echo "<ul class=\"list\">\n";
        while($row = mysql_fetch_array($query, MYSQL_NUM)) {
             $db = $row[0];
             $name = $row[1];
             $description = $row[2];
             if (!$name) $name = $db;
             $access = '';
             if ($row[3]) $access .= 'read';
             if ($row[4]) $access .= ', write';
             if ($row[5]) $access .= ', update';
             if ($row[6]) $access .= ', delete';
             if(isset($row[7]) && $row[7]==2)
				echo "<li><a href=\"query_database.php?db=$db\" title=\"$description\">$name</a> ($access)</li>\n";
			 else echo "<li>$name ($access)</li>\n";
             
        }
        echo "</ul>\n";

	if($is_admin) {
		echo "<h2>Admin pages:</h2>\n";
		echo "<a href=\"create_user.php\">Create a new user</a><br />\n";
		echo "<a href=\"create_database.php\">Create a new database</a><br />\n";
		echo "<a href=\"list_users.php\">List all users</a><br />\n";
		echo "<a href=\"list_dbs.php\">List all databases</a><br />\n";
		echo "<a href=\"options.php\">General options</a><br />\n";
		$query = mysql_query("SELECT value FROM options WHERE name=\"utp_path\"");
		if(mysql_num_rows($query)!=0 && mysql_result($query, 0, 0)!="") echo "<a href=\"view_utp.php\">View unit test protocolls</a><br />\n";
	}
	echo "<a href=\"edit_user.php?id=$passtest\">Your profile</a><br />\n";
	
	if($is_admin && file_exists("install.php")) echo "<p class=\"error\">Warning: install.php should be removed now.</p>";
	if($is_admin && file_exists("install_dump.php")) echo "<p class=\"error\">Warning: install_dump.php should be removed now.</p>";
	
	// Check, if an update has been done:
	$query = mysql_query("SELECT value FROM options WHERE name=\"version\"");
	if(mysql_num_rows($query)==0 || mysql_result($query, 0, 0)!=$custom_version) {
		
		// Do not send header of the page again:
		$hide_headers = true;
		
		// Check for an update lock (update already running)
		$query = mysql_query("SELECT value FROM options WHERE name=\"update_lock\"");
		if(!mysql_num_rows($query) || mysql_result($query, 0, 0)==0) require("update.inc.php");
		else echo "<p>Info: An update is running at the moment. The database may be slow.</p>";
	}
	if(!$query) echo "<p class=\"error\">".mysql_error()."</p>";
	
	// Check for databases with old layout and display upgrade notice
	$result = mysql_query("SELECT COUNT(*) FROM available_dbs WHERE version<2");
	if($result) {
		if(mysql_result($result, 0, 0)>0) echo "<p><strong>Warning:</strong> Some of the databases still have the old layout. It is strongly recommended you upgrade them by running the ruby update script. <a href=\"layout_update_help.php\">Read how.</a></p>\n";
	}
	else echo "<p class=\"error\">".mysql_error()."</p>";
	
} else include("login.inc.php");

include("footer.inc.php");

?>
