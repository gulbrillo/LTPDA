<?php
include("config.inc.php"); // some constants
include("passtest.inc.php"); // checks the User/Password

$title = "Options";

if(!isset($_GET["action"])) $_GET["action"] = "";
if(!isset($_POST["robot_ext_plot_path"])) $_POST["robot_ext_plot_path"] = "";
if(!isset($_POST["robot_path"])) $_POST["robot_path"] = "";
if(!isset($_POST["robot_plot_path"])) $_POST["robot_plot_path"] = "";
if(!isset($_POST["robot_gnuplot_format_string"])) $_POST["robot_gnuplot_format_string"] = "";
if(!isset($_POST["robot_gnuplot_extension"])) $_POST["robot_gnuplot_extension"] = "";
if(!isset($_POST["robot_gnuplot_path"])) $_POST["robot_gnuplot_path"] = "";
if(!isset($_POST["robot_download_gnuplot_format_string"])) $_POST["robot_download_gnuplot_format_string"] = "";
if(!isset($_POST["robot_download_gnuplot_extension"])) $_POST["robot_download_gnuplot_extension"] = "";

// $CVS_TAG="$Id: options.php,v 1.28 2012/01/26 15:56:17 gerrit Exp $";
include("header.inc.php");

if($passtest && $connected) {
	echo "<h1>$title</h1>";
	if($is_admin) {
		#if($_GET["action"]=="optimize_databases") {
		#	$query = mysql_query("SELECT db_name FROM available_dbs ORDER BY db_name");
		#	while($row = mysql_fetch_array($query, MYSQL_NUM)) {
		#		mysql_select_db($row[0]);
		#		$subquery = mysql_query("SHOW TABLES");
		#		while($subrow = mysql_fetch_array($subquery, MYSQL_NUM)) {
		#			if(!mysql_query("OPTIMIZE TABLE ".mysql_real_escape_string($subrow[0]))) echo "<p class=\"error\">".mysql_error()."</p>\n";
		#		}
		#	}
		#	mysql_select_db($mysql_database);
		#	echo "<p class=\"success\">Optimizing done.</p>\n";
		#}
				
		if($_POST["robot_path"]!="") {
			$error = 0;
			$fields = array("robot_path", "robot_ext_plot_path", "robot_plot_path", "robot_gnuplot_path", "robot_gnuplot_format_string", "robot_gnuplot_extension", "robot_download_gnuplot_format_string", "robot_download_gnuplot_extension");
			foreach($fields as $field) {
				$error += save_field($field);
			}
			if(!$error) echo "<p class=\"success\">Saved.</p>\n";
		}
				
		$query = mysql_query("SELECT name, value FROM options WHERE name LIKE 'robot%'");
		while($row = mysql_fetch_row($query)) {
			switch($row[0]) {
				case "robot_path":
					$robot_path = $row[1];
					break;
				case "robot_plot_path":
					$robot_plot_path = $row[1];
					break;
				case "robot_ext_plot_path":
					$robot_ext_plot_path = $row[1];
					break;
				case "robot_gnuplot_path":
					$robot_gnuplot_path = $row[1];
					break;
				case "robot_gnuplot_format_string":
					$robot_gnuplot_format_string = $row[1];
					break;
				case "robot_gnuplot_extension":
					$robot_gnuplot_extension = $row[1];
					break;
				case "robot_download_gnuplot_format_string":
					$robot_download_gnuplot_format_string = $row[1];
					break;
				case "robot_download_gnuplot_extension":
					$robot_download_gnuplot_extension = $row[1];
					break;
			}
		}
	
		#echo "<h2>Optimize tables</h2>";
		#echo "<p>If a lot of data was deleted, the mysql tables might still have a lot of unused data and can be defragmented. For more information, see <a href=\"http://dev.mysql.com/doc/refman/5.0/en/optimize-table.html\">the mysql documentation</a>. To optimize all tables right now, <a href=\"options.php?action=optimize_databases\">click here</a>.</p>\n";
		echo "<h2>E-Mail texts</h2>\n";
		echo "<p>You can change the text of emails that inform about a new account <a href=\"edit_mail_text.php\">here</a>.</p>\n";
		echo "<h2>Path to plots and robot</h2>\n";
		
		echo "<form action=\"options.php\" method=\"post\">\n";
		echo "<fieldset>\n";
		print_field("text", "Robot path:", "robot_path", $robot_path);
		print_field("text", "Plot path:", "robot_plot_path", $robot_plot_path);
		print_field("text", "External plot path:", "robot_ext_plot_path", $robot_ext_plot_path);
		print_field("text", "Gnuplot path:", "robot_gnuplot_path", $robot_gnuplot_path);
		print_field("text", "Gnuplot Format:", "robot_gnuplot_format_string", $robot_gnuplot_format_string);
		print_field("text", "Plot extension:", "robot_gnuplot_extension", $robot_gnuplot_extension);
		print_field("text", "Download format:", "robot_download_gnuplot_format_string", $robot_download_gnuplot_format_string);
		print_field("text", "Download plot extension:", "robot_download_gnuplot_extension", $robot_download_gnuplot_extension);
		print_field("submit", "", "save_button", "Save");
		echo "</fieldset>\n";
		echo "</form>\n";
		
		#echo "<h2>Database dump</h2>\n";
		#echo "<p>You can generate a database dump with all users and their rights but no data. This way, you can set up a new test machine with the same configuration.</p>\n";
		#echo "<p><span style=\"font-weight: bold; color: #990000;\">Warning:</span> If you generate a dump this way and install it back to this machine, you will lose all data!</p>\n";
		#echo "<p><a href=\"download_dump.php\">Download dump</a> (you can right-click on this link and download this to a .sql file)</p>\n";
		echo "<h2>Uninstall</h2>\n";
		echo "<p>If you want to uninstall all databases and users, you can use the <a href=\"uninstall.php\">uninstaller</a>.</p>\n";
	} else echo "<p class=\"error\">Sorry, you do not have the rights to view this page.</p>";
} else include("login.inc.php");

include("footer.inc.php");

function print_field($type, $label, $name, $value)
{
	echo "<div class=\"input_row\">";
	echo "<span class=\"input_label\">";
	echo $label;
	echo "</span><span class=\"input_field\">";
	echo "<input type=\"$type\" name=\"$name\" value=\"$value\" size=\"40\" />";
	echo "</span>";
	echo "</div>\n";
}

function save_field($name)
{
	$value = $_POST[$name];
	$query = mysql_query("INSERT INTO `options` (name, value) VALUES ('$name', '$value') ON DUPLICATE KEY UPDATE value='$value'");
	if(!$query) {
		echo "<p class='error'>Unable to save field $name. - ".mysql_error()."</p>\n";
		return 1;
	} 
	return 0;
}
?>
