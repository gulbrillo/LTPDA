<?php
include("config.inc.php"); // some constants
include("passtest.inc.php"); // checks the User/Password

$title = "Data view";
// $CVS_TAG="$Id: plot.php,v 1.2 2012/01/18 19:59:23 gerrit Exp $";

$noplot_image = "Plot|<img src=\"images/noplot.png\" alt=\"No plot available\" title=\"No plot available, object not found.\" />";

if(isset($_GET["download"]) && $_GET["download"]=="true") $plot_download = true;
else $plot_download = false;

$connected = mysql_connect($mysql_host, $mysql_user, $mysql_pass);
$db = $_GET["db"];
if(!preg_match('/^[a-z0-9_-]+$/iD', $db)) die($noplot_image);
if($connected) mysql_select_db($db);

if($passtest && $connected) {
	
	$obj_id = $_GET["id"]+0;
	
	if(!$db) die("No database selected...");
	
	// Check if user has the rights:
	$has_rights=0;
	if($is_admin) $has_rights = 1;
	else {
        $query = mysql_query(sprintf("SELECT Select_priv FROM mysql.db
                                          WHERE User='%s' AND Db='%s'",
                                          mysql_real_escape_string($user),
                                          mysql_real_escape_string($db)));
		if($query && mysql_result($query, 0, 0)) $has_rights = 1;
	}
	
	if($has_rights) {
		
		$query = mysql_query("SELECT hash FROM objs WHERE id=$obj_id");
		if($query && mysql_num_rows($query)>0) $hash = mysql_result($query, 0, 0);
		else die($noplot_image);
		
		$query = mysql_query("SELECT experiment_title FROM objmeta WHERE obj_id=$obj_id");
		if($query && mysql_num_rows($query)>0) $title = mysql_result($query, 0, 0);
		else $title = "";
		
		// Get path and meta info
		$query = mysql_query("SELECT value FROM $mysql_database.options WHERE name='robot_plot_path'");
		if($query && mysql_num_rows($query)) $path = mysql_result($query, 0, 0);
		else $path = "./plots/";
		$path = str_replace("%database%", $db, $path);
		
		$query = mysql_query("SELECT value FROM $mysql_database.options WHERE name='robot_path'");
		if($query && mysql_num_rows($query)) $robot_path = mysql_result($query, 0, 0);
		else $robot_path = "./ltpda_robot.rb";
		
		$query = mysql_query("SELECT value FROM $mysql_database.options WHERE name='robot_ext_plot_path'");
		if($query && mysql_num_rows($query)) $robot_ext_plot_path = mysql_result($query, 0, 0);
		else $robot_ext_plot_path = "plots";
		$robot_ext_plot_path = str_replace("%database%", $db, $robot_ext_plot_path);
		
		$query = mysql_query("SELECT value FROM $mysql_database.options WHERE name='robot_gnuplot_extension'");
		if($query && mysql_num_rows($query)) $plot_extension = mysql_result($query, 0, 0);
		else $plot_extension = "png";
		
		$query = mysql_query("SELECT value FROM $mysql_database.options WHERE name='robot_download_gnuplot_extension'");
		if($query && mysql_num_rows($query)) $download_extension = mysql_result($query, 0, 0);
		else $download_extension = "pdf";
		
		$id_string = $obj_id."";
		while(strlen($id_string)<6) $id_string = "0".$id_string;
		$filename_main = $db."_".$id_string."_".$hash."_main.".$plot_extension;
		$filename_phase = $db."_".$id_string."_".$hash."_phase.".$plot_extension;
		$filename_error = $db."_".$id_string."_".$hash."_error.log";
		$filename_main_pdf = $db."_".$id_string."_".$hash."_main.".$download_extension;
		$filename_phase_pdf = $db."_".$id_string."_".$hash."_phase.".$download_extension;
		$filename_meta = $db."_".$id_string."_".$hash.".txt";
		
		// plot
		if(!$plot_download) {
			if(!file_exists($path."/".$filename_main)) {
				$output = system("(/usr/bin/env ruby ".$robot_path." -D '$db' --id $obj_id --title '$title') > ".$path."/".$filename_error);
				#$output = system("/usr/bin/env ruby ".$robot_path." -D '$db' --id $obj_id --title '$title'");
				if($debug && $output) echo "Error message from robot|".$output.".\n";
			}
		
			// if plotting worked, print out the image link
			if(file_exists($path."/".$filename_main)) {
				echo "Plot|<img src=\"$robot_ext_plot_path/".$filename_main."\" alt=\"Plot\" title=\"Plot\" />\n";
			} else echo $noplot_image;
			
			// if plotting worked, print out the image link
			if(file_exists($path."/".$filename_phase)) {
				echo "Phase|<img src=\"$robot_ext_plot_path/".$filename_phase."\" alt=\"Plot\" title=\"Plot\" />\n";
			}
		
			// if the info file exists, parse it and print out meta info
			if(file_exists($path."/".$filename_meta)) {
				$file = fopen($path."/".$filename_meta, "r");
				while(!feof($file)) {
					$line = fgets($file);
					$linedata = explode("=", $line);
					// if($line!="") echo "<tr class=\"dataview\"><td class=\"data_desc\">".$linedata[0].":</td><td class=\"data_value\">".$linedata[1]."</td></tr>\n";
					if(trim($linedata[0])!="") echo $linedata[0]."|".$linedata[1];
				}
				fclose($file);
			}
		}
		
		// if requestet, plot download version of the plot (usually pdf)
		if($plot_download) {
			if(!file_exists($path."/".$filename_main_pdf)) {
				$output = system("(/usr/bin/env ruby ".$robot_path." --download -D '$db' --id $obj_id --title '$title') > ".$path."/".$filename_error);
				if($debug && $output) echo "Error message from robot|".$output."\n";
			}
			
			// Print image tag or else an error message
			if(file_exists($path."/".$filename_main_pdf)) {
				echo "<a href=\"$robot_ext_plot_path/$filename_main_pdf\"><img src=\"images/download_plot.png\" alt=\"Plot for download\" title=\"Download plot\" /></a>\n";
			}
		}
	}
	
} else echo "Not logged in.";

?>
		