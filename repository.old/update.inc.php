<?php
// This file is included once if there is an update.
// $CVS_TAG="$Id: update.inc.php,v 1.28 2012/01/18 19:08:28 gerrit Exp $";

// Write header file if update.inc.php is called directly
if(!isset($hide_headers) || $hide_headers == false) {
	require("config.inc.php");
	require("header.inc.php");
}

require("upgrade.inc.php");

// Lock the update process:
mysql_query("INSERT INTO `options` (`name`, `value`) VALUES (\"update_lock\", \"1\") ON DUPLICATE KEY UPDATE `value`=\"1\"");

// First: Get the version, from where we update
$query = mysql_query("SELECT value FROM options WHERE name=\"version\"");
if(mysql_num_rows($query)>0) $version = mysql_result($query, 0, 0)+0;
else $version = 1.0;
$error = 0;


// First update (from Version 1.0):
if($version<=1.0) {
   // mysql_query("LOCK TABLES");
	$query = mysql_query("ALTER TABLE `options` DROP `id`");
	if(!$query) {
		echo "<p class=\"error\">".mysql_error()."</p>";
		$error++;
	}
	
	$query = mysql_query("ALTER TABLE `options` ADD PRIMARY KEY ( `name` )");
	if(!$query) {
		echo "<p class=\"error\">".mysql_error()."</p>";
		$error++;
	}
	
	$query = mysql_query("ALTER TABLE `options` DROP INDEX `name`");
	if(!$query) {
		echo "<p class=\"error\">".mysql_error()."</p>";
		$error++;
	}
	// mysql_query("UNLOCK TABLES");
}

if($version<1.9) {
	echo "<p>Updating table definitions from 1.0 to 1.9...</p>";
	$big_query = <<<END

ALTER TABLE ao CHANGE id id int unsigned auto_increment;
ALTER TABLE ao CHANGE obj_id obj_id int default NULL;
ALTER TABLE ao CHANGE data_type data_type text default NULL;
ALTER TABLE ao CHANGE data_id data_id int default NULL;
ALTER TABLE ao CHANGE description description text default NULL;
ALTER TABLE ao CHANGE mfilename mfilename text default NULL;
ALTER TABLE ao CHANGE mdlfilename mdlfilename text default NULL;

ALTER TABLE cdata CHANGE id id int unsigned auto_increment;
ALTER TABLE cdata CHANGE xunits xunits text default NULL;
ALTER TABLE cdata CHANGE yunits yunits text default NULL;

ALTER TABLE collections CHANGE id id int unsigned auto_increment;
ALTER TABLE collections CHANGE nobjs nobjs int default NULL;
ALTER TABLE collections CHANGE obj_ids obj_ids text default NULL;

ALTER TABLE fsdata CHANGE id id int unsigned auto_increment;
ALTER TABLE fsdata CHANGE xunits xunits text default NULL;
ALTER TABLE fsdata CHANGE yunits yunits text default NULL;
ALTER TABLE fsdata CHANGE fs fs int default NULL;

ALTER TABLE mfir CHANGE id id int unsigned auto_increment;
ALTER TABLE mfir CHANGE obj_id obj_id int default NULL;
ALTER TABLE mfir CHANGE in_file in_file text default NULL;
ALTER TABLE mfir CHANGE fs fs int default NULL;

ALTER TABLE miir CHANGE id id int unsigned auto_increment;
ALTER TABLE miir CHANGE obj_id obj_id int default NULL;
ALTER TABLE miir CHANGE in_file in_file text default NULL;
ALTER TABLE miir CHANGE fs fs int default NULL;

ALTER TABLE objmeta CHANGE id id int unsigned auto_increment;
ALTER TABLE objmeta CHANGE obj_id obj_id int default NULL;
ALTER TABLE objmeta CHANGE obj_type obj_type text default NULL;
ALTER TABLE objmeta CHANGE name name text default NULL;
ALTER TABLE objmeta CHANGE created created datetime default NULL;
ALTER TABLE objmeta CHANGE version version text default NULL;
ALTER TABLE objmeta CHANGE ip ip text default NULL;
ALTER TABLE objmeta CHANGE hostname hostname text default NULL;
ALTER TABLE objmeta CHANGE os os text default NULL;
ALTER TABLE objmeta CHANGE submitted submitted datetime default NULL;
ALTER TABLE objmeta CHANGE experiment_title experiment_title text default NULL;
ALTER TABLE objmeta CHANGE experiment_desc experiment_desc text default NULL;
ALTER TABLE objmeta CHANGE analysis_desc analysis_desc text default NULL;
ALTER TABLE objmeta CHANGE quantity quantity text default NULL;
ALTER TABLE objmeta CHANGE additional_authors additional_authors text default NULL;
ALTER TABLE objmeta CHANGE additional_comments additional_comments text default NULL;
ALTER TABLE objmeta CHANGE keywords keywords text default NULL;
ALTER TABLE objmeta CHANGE reference_ids reference_ids text default NULL;
ALTER TABLE objmeta CHANGE validated validated tinyint default NULL;
ALTER TABLE objmeta CHANGE vdate vdate datetime default NULL;

ALTER TABLE objs CHANGE id id int unsigned auto_increment;
ALTER TABLE objs CHANGE xml xml longtext default NULL;
ALTER TABLE objs CHANGE hash hash text default NULL;

CREATE TABLE `bobjs` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `obj_id` int(11) default NULL,
  `mat` longblob default NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

ALTER TABLE transactions CHANGE id id int unsigned auto_increment;
ALTER TABLE transactions CHANGE obj_id obj_id int default NULL;
ALTER TABLE transactions CHANGE user_id user_id int default NULL;
ALTER TABLE transactions CHANGE transdate transdate datetime default NULL;
ALTER TABLE transactions CHANGE direction direction text default NULL;

ALTER TABLE tsdata CHANGE id id int unsigned auto_increment;
ALTER TABLE tsdata CHANGE xunits xunits text default NULL;
ALTER TABLE tsdata CHANGE yunits yunits text default NULL;
ALTER TABLE tsdata CHANGE fs fs int default NULL;
ALTER TABLE tsdata CHANGE nsecs nsecs int default NULL;
ALTER TABLE tsdata CHANGE t0 t0 datetime default NULL;

ALTER TABLE users CHANGE id id int unsigned auto_increment;
ALTER TABLE users CHANGE firstname firstname text default NULL;
ALTER TABLE users CHANGE familyname familyname text default NULL;
ALTER TABLE users CHANGE username username text default NULL;
ALTER TABLE users CHANGE email email text default NULL;
ALTER TABLE users CHANGE telephone telephone text default NULL;
ALTER TABLE users CHANGE institution institution text default NULL;

ALTER TABLE xydata CHANGE id id int unsigned auto_increment;
ALTER TABLE xydata CHANGE xunits xunits text default NULL;
ALTER TABLE xydata CHANGE yunits yunits text default NULL;

END;
	$query_array = explode(";", $big_query);
	$error = 0;
	$query = mysql_query("SELECT db_name FROM available_dbs");
	while($database = mysql_fetch_row($query)) {
		mysql_query("USE `".mysql_real_escape_string($database[0])."`");
		$temp_query_array = $query_array;
		while($row = array_shift($temp_query_array)) {
			if(!mysql_query($row)) if(mysql_error()!="Query was empty" && mysql_error()!="") { echo mysql_error(); $error++; }
		}
	}
	mysql_query("USE `".$mysql_database."`");
}

if($version<1.91) {
	echo "<p>Updating table definitions from 1.9 to 1.91...</p>";
	$big_query = <<<END

ALTER TABLE ao CHANGE id id int unsigned auto_increment comment "Unique ID of every data set in this table";
ALTER TABLE ao CHANGE obj_id obj_id int default NULL comment "ID of the object this data set belongs to";
ALTER TABLE ao CHANGE data_type data_type text default NULL comment "Data type of the object, see corresponding table";
ALTER TABLE ao CHANGE data_id data_id int default NULL comment "ID of the data set in the corresponding table";
ALTER TABLE ao CHANGE description description text default NULL comment "Description of the object";
ALTER TABLE ao CHANGE mfilename mfilename text default NULL comment "";
ALTER TABLE ao CHANGE mdlfilename mdlfilename text default NULL comment "";

ALTER TABLE cdata CHANGE id id int unsigned auto_increment comment "Unique ID of every data set in this table";
ALTER TABLE cdata CHANGE xunits xunits text default NULL comment "Units of the x axis";
ALTER TABLE cdata CHANGE yunits yunits text default NULL comment "Units of the y axis";

ALTER TABLE collections CHANGE id id int unsigned auto_increment comment "Unique ID of every data set in this table";
ALTER TABLE collections CHANGE nobjs nobjs int default NULL comment "Number of objects in a collection";
ALTER TABLE collections CHANGE obj_ids obj_ids text default NULL comment "List of objects in a collection";

ALTER TABLE fsdata CHANGE id id int unsigned auto_increment comment "Unique ID of every data set in this table";
ALTER TABLE fsdata CHANGE xunits xunits text default NULL comment "Units of the x axis";
ALTER TABLE fsdata CHANGE yunits yunits text default NULL comment "Units of the y axis";
ALTER TABLE fsdata CHANGE fs fs int default NULL;

ALTER TABLE mfir CHANGE id id int unsigned auto_increment comment "Unique ID of every data set in this table";
ALTER TABLE mfir CHANGE obj_id obj_id int default NULL comment "The ID of the object this data set belongs to";
ALTER TABLE mfir CHANGE in_file in_file text default NULL;
ALTER TABLE mfir CHANGE fs fs int default NULL;

ALTER TABLE miir CHANGE id id int unsigned auto_increment comment "Unique ID of every data set in this table";
ALTER TABLE miir CHANGE obj_id obj_id int default NULL comment "ID of the object this data set belongs to";
ALTER TABLE miir CHANGE in_file in_file text default NULL;
ALTER TABLE miir CHANGE fs fs int default NULL;

ALTER TABLE objmeta CHANGE id id int unsigned auto_increment comment "A unique ID of every data set in this database";
ALTER TABLE objmeta CHANGE obj_id obj_id int default NULL comment "The ID of the object this data set belongs to";
ALTER TABLE objmeta CHANGE obj_type obj_type text default NULL comment "Object type, e.g. ao, mfir, miir";
ALTER TABLE objmeta CHANGE name name text default NULL comment "Name of an object";
ALTER TABLE objmeta CHANGE created created datetime default NULL comment "Creation time of an object";
ALTER TABLE objmeta CHANGE version version text default NULL comment "Version string of an object";
ALTER TABLE objmeta CHANGE ip ip text default NULL comment "IP address of the creator";
ALTER TABLE objmeta CHANGE hostname hostname text default NULL comment "Hostname of the ceator";
ALTER TABLE objmeta CHANGE os os text default NULL comment "Operating system of the creator";
ALTER TABLE objmeta CHANGE submitted submitted datetime default NULL comment "Submission time of an object";
ALTER TABLE objmeta CHANGE experiment_title experiment_title text default NULL comment "Experiment title";
ALTER TABLE objmeta CHANGE experiment_desc experiment_desc text default NULL comment "Experiment description";
ALTER TABLE objmeta CHANGE analysis_desc analysis_desc text default NULL comment "Analysis description";
ALTER TABLE objmeta CHANGE quantity quantity text default NULL comment "Quantity";
ALTER TABLE objmeta CHANGE additional_authors additional_authors text default NULL comment "Additional authors of an object";
ALTER TABLE objmeta CHANGE additional_comments additional_comments text default NULL comment "Additional comments to an object";
ALTER TABLE objmeta CHANGE keywords keywords text default NULL comment "Keywords";
ALTER TABLE objmeta CHANGE reference_ids reference_ids text default NULL comment "Reference IDs";
ALTER TABLE objmeta CHANGE validated validated tinyint default NULL comment "Validated";
ALTER TABLE objmeta CHANGE vdate vdate datetime default NULL comment "Validation time";

ALTER TABLE objs CHANGE id id int unsigned auto_increment comment "Unique ID of every object in this table";
ALTER TABLE objs CHANGE xml xml longtext default NULL comment "Raw XML representation of the object";
ALTER TABLE objs CHANGE hash hash text default NULL comment "MD5 hash of an object";

ALTER TABLE bobjs CHANGE id id int unsigned auto_increment comment "Unique ID of every data set in this table";
ALTER TABLE bobjs CHANGE obj_id obj_id int default NULL comment "ID of the object this data set belongs to";
ALTER TABLE bobjs CHANGE mat mat longblob default NULL comment "Binary version of the object";

ALTER TABLE transactions CHANGE id id int unsigned auto_increment comment "Unique ID of every data set in this table";
ALTER TABLE transactions CHANGE obj_id obj_id int default NULL comment "ID of the object the transaction belongs to";
ALTER TABLE transactions CHANGE user_id user_id int default NULL comment "ID of the User of the transactions";
ALTER TABLE transactions CHANGE transdate transdate datetime default NULL comment "Date and time of the transaction";
ALTER TABLE transactions CHANGE direction direction text default NULL comment "Direction of the transaction";

ALTER TABLE tsdata CHANGE id id int unsigned auto_increment comment "Unique ID of every data set in this table";
ALTER TABLE tsdata CHANGE xunits xunits text default NULL comment "Units of the x axis";
ALTER TABLE tsdata CHANGE yunits yunits text default NULL comment "Units of the y axis";
ALTER TABLE tsdata CHANGE fs fs int default NULL comment "Sample frequency [Hz]";
ALTER TABLE tsdata CHANGE nsecs nsecs int default NULL comment "Number of nanoseconds";
ALTER TABLE tsdata CHANGE t0 t0 datetime default NULL comment "Starting time of the time series";

ALTER TABLE users CHANGE id id int unsigned auto_increment comment "Unique ID of every data set in this table";
ALTER TABLE users CHANGE firstname firstname text default NULL comment "The first name of the user";
ALTER TABLE users CHANGE familyname familyname text default NULL comment "The family name of the user";
ALTER TABLE users CHANGE username username text default NULL comment "The username/login of the user";
ALTER TABLE users CHANGE email email text default NULL comment "The email address of the user";
ALTER TABLE users CHANGE telephone telephone text default NULL comment "Telephone number of the user";
ALTER TABLE users CHANGE institution institution text default NULL comment "Institution of the user";

ALTER TABLE xydata CHANGE id id int unsigned auto_increment comment "Unique ID of every data set in this table";
ALTER TABLE xydata CHANGE xunits xunits text default NULL comment "Units of the x axis";
ALTER TABLE xydata CHANGE yunits yunits text default NULL comment "Units of the y axis";

END;
	$query_array = explode(";", $big_query);
	$error = 0;
	$query = mysql_query("SELECT db_name FROM available_dbs");
	while($database = mysql_fetch_row($query)) {
		echo "Updating database ".$database[0]."<br/>";
		mysql_query("USE `".mysql_real_escape_string($database[0])."`");
		$temp_query_array = $query_array;
		while($row = array_shift($temp_query_array)) {
			if(!mysql_query($row)) if(mysql_error()!="Query was empty" && mysql_error()!="") { echo mysql_error(); $error++; }
		}
	}
	mysql_query("USE `".$mysql_database."`");
}

if($version<2.0) {
	echo "<p>Updating table definitions from 1.91 to 2.0...</p>";
	if(!mysql_query("ALTER TABLE `user_access` ADD `update_priv` TINYINT( 1 ) NOT NULL DEFAULT '0', ADD `delete_priv` TINYINT( 1 ) NOT NULL DEFAULT '0'")) {
		echo "<p class=\"error\">Could not alter table user_access for new privileges.</p>\n";
		$error++;
	}
}

if (!$error)
     // subcessive upgrade steps
     $error = upgrade_db_schema();

// upgrade process may change database. switch back to the right one
mysql_select_db($mysql_database);

// unlock the update process
mysql_query("UPDATE options SET value='0' WHERE name='update_lock'");

if (!$error) 
     echo "<p class=\"success\">Database update successful.</p>";

?>
