<?php
include("config.inc.php"); // some constants
include("passtest.inc.php"); // checks the User/Password

$title = "Data view";
// $CVS_TAG="$Id: show_new_data.php,v 1.14 2012/01/25 18:26:03 gerrit Exp $";
$need_full_page=true;
//$onLoad = "showPlot('$db', '$obj_id')";
include("header.inc.php");

if($passtest && $connected) {
	
	$db = $_GET["db"];
	// $table = $_GET["table"];
	$id = $_GET["id"]+0;
	if(!preg_match('/^[a-z0-9_-]+$/iD', $db)) $db = "";
	
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
		echo "<h1>Data view</h1>\n";
		echo "<h3>Database: $db</h3>\n";
		
		$tables = array("temp", "objmeta", "objs", "miir", "mfir", "bobjs", "ao", "cdata", "fsdata", "tsdata", "xydata");
		
		// if(array_search($table, $tables)) {
			$obj_id = $id;
			
			$query = mysql_query("SELECT obj_type, DATE_FORMAT(created, \"%d.%m.%Y, %H:%i:%s\"), version, ip, hostname, os, submitted, experiment_title, experiment_desc, analysis_desc, quantity, additional_authors, additional_comments, keywords, reference_ids, validated, vdate, name, author FROM $db.objmeta WHERE obj_id=".$obj_id);
			$object_type = mysql_result($query, 0, 0);
			$created = mysql_result($query, 0, 1);
			$version = mysql_result($query, 0, 2);
			$ip = mysql_result($query, 0, 3);
			$hostname = mysql_result($query, 0, 4);
			$os = mysql_result($query, 0, 5);
			$submitted = mysql_result($query, 0, 6);
			$experiment_title = mysql_result($query, 0, 7);
			$experiment_desc = mysql_result($query, 0, 8);
			$analysis_desc = mysql_result($query, 0, 9);
			$quantity = mysql_result($query, 0, 10);
			$additional_authors = mysql_result($query, 0, 11);
			$additional_comments = mysql_result($query, 0, 12);
			$keywords = mysql_result($query, 0, 13);
			$reference_ids = mysql_result($query, 0, 14);
			$validated = mysql_result($query, 0, 15);
			$vdate = mysql_result($query, 0, 16);
			$obj_name = mysql_result($query, 0, 17);
			$author = mysql_result($query, 0, 18);

			$data_type = "N/A";
			if($object_type=="ao") {
				$query = mysql_query("SELECT data_type FROM $db.ao WHERE obj_id=$obj_id");
				if(mysql_num_rows($query)) $data_type = mysql_result($query, 0, 0);
			}
			
			$query = mysql_query("SELECT hash FROM $db.objs WHERE id=$obj_id");
			if(mysql_num_rows($query)) $hash = mysql_result($query, 0, 0);
			else $hash = "N/A";
			
			$query = mysql_query("SELECT value FROM options WHERE name=\"robot_plot_path\"");
			if(mysql_num_rows($query)) $path = mysql_result($query, 0, 0);
			$query = mysql_query("SELECT value FROM options WHERE name=\"robot_ext_plot_path\"");
			if(mysql_num_rows($query)) $ext_plot_path = mysql_result($query, 0, 0);
			$query = mysql_query("SELECT value FROM options WHERE name=\"robot_path\"");
			if(mysql_num_rows($query)) $robot_path = mysql_result($query, 0, 0);
			$query = mysql_query("SELECT value FROM options WHERE name=\"robot_gnuplot_extension\"");
			if(mysql_num_rows($query)) $plot_extension = mysql_result($query, 0, 0);
			$query = mysql_query("SELECT value FROM options WHERE name=\"robot_download_gnuplot_extension\"");
			if(mysql_num_rows($query)) $download_extension = mysql_result($query, 0, 0);
			
			$path = str_replace("%database%", $db, $path);
			$ext_plot_path = str_replace("%database%", $db, $ext_plot_path);
			if(!file_exists($path)) mkdir($path, 0755, true);
			
			$id_string = $obj_id."";
			while(strlen($id_string)<6) $id_string = "0".$id_string;
			$filename_main = $db."_".$id_string."_".$hash."_main.".$plot_extension;
			$filename_phase = $db."_".$id_string."_".$hash."_phase.".$plot_extension;
			$filename_error = $db."_".$id_string."_".$hash."_error.log";
			$filename_main_pdf = $db."_".$id_string."_".$hash."_main.".$download_extension;
			$filename_phase_pdf = $db."_".$id_string."_".$hash."_phase.".$download_extension;
			$filename_meta = $db."_".$id_string."_".$hash.".txt";
			
			// Download links
			echo "<div id=\"linklist\">ID: $obj_id<br />";
			$query = mysql_query("SELECT SUBSTR(xml, 1, 6) FROM $db.objs WHERE id=$obj_id");
			if(mysql_result($query, 0, 0)!="binary" && mysql_result($query, 0, 0)!="") $is_plottable = true;
			else $is_plottable = false;
			
			if($is_plottable){
				echo "<a href=\"download_xml.php?type=xml&amp;db=$db&amp;id=".$obj_id."\"><img src=\"images/download_xml.png\" height=\"64px\" width=\"64px\" alt=\"Download XML data\" title=\"Download XML data\" /></a><br />";
				
			}

			$query = mysql_query("SELECT COUNT(*) FROM $db.bobjs WHERE obj_id=$obj_id");
			if(mysql_result($query, 0, 0)>0) {
				echo "<a href=\"download_xml.php?type=bin&amp;db=$db&amp;id=".$obj_id."\"><img src=\"images/download_bin.png\" height=\"64px\" width=\"64px\" alt=\"Download binary data\" title=\"Download binary data\" /></a>";
			}
			if($is_plottable) {
				echo "<span id=\"downloadPlot\">\n";
				if(file_exists($path."/".$filename_main_pdf) && filesize($path."/".$filename_main_pdf)>2) echo " <a href=\"$ext_plot_path/$filename_main_pdf\"><img src=\"images/download_plot.png\" height=\"64px\" width=\"64px\" alt=\"Download plot\" title=\"Download plot\" /></a><br />";
				// If ao, show link to generate downloadable plot
				elseif($object_type=="ao" && $data_type!="cdata") echo "<a href=\"javascript:showDownload('$db', '$obj_id')\">Generate downloadable plot</a>";
			}
			
			echo "</span>\n";
			echo "</div>\n";
			
			echo "<table>\n";
			echo "<tr class=\"dataview\"><td class=\"data_desc\">Object ID:</td><td class=\"data_value\">$obj_id</td></tr>\n";
			echo "<tr class=\"dataview\"><td class=\"data_desc\">Object name:</td><td class=\"data_value\">$obj_name</td></tr>\n";
			echo "<tr class=\"dataview\"><td class=\"data_desc\">Object type:</td><td class=\"data_value\">$object_type</td></tr>\n";
			if($object_type=="ao") echo "<tr class=\"dataview\"><td class=\"data_desc\">Data type:</td><td class=\"data_value\">$data_type</td></tr>\n";
			echo "<tr class=\"dataview\"><td class=\"data_desc\">Created:</td><td class=\"data_value\">$created</td></tr>\n";
			echo "<tr class=\"dataview\"><td class=\"data_desc\">Version:</td><td class=\"data_value\">$version</td></tr>\n";
			echo "<tr class=\"dataview\"><td class=\"data_desc\">Submitter IP:</td><td class=\"data_value\">$ip</td></tr>\n";
			echo "<tr class=\"dataview\"><td class=\"data_desc\">Submission time:</td><td class=\"data_value\">$submitted</td></tr>\n";
			echo "<tr class=\"dataview\"><td class=\"data_desc\">Submitter Hostname:</td><td class=\"data_value\">$hostname</td></tr>\n";
			echo "<tr class=\"dataview\"><td class=\"data_desc\">Submitter OS:</td><td class=\"data_value\">$os</td></tr>\n";
			echo "<tr class=\"dataview\"><td class=\"data_desc\">Experiment title:</td><td class=\"data_value\">$experiment_title</td></tr>\n";
			echo "<tr class=\"dataview\"><td class=\"data_desc\">Experiment description:</td><td class=\"data_value\">$experiment_desc</td></tr>\n";
			echo "<tr class=\"dataview\"><td class=\"data_desc\">Analysis description:</td><td class=\"data_value\">$analysis_desc</td></tr>\n";
			echo "<tr class=\"dataview\"><td class=\"data_desc\">Quantity:</td><td class=\"data_value\">$quantity</td></tr>\n";
			echo "<tr class=\"dataview\"><td class=\"data_desc\">Additional authors:</td><td class=\"data_value\">$additional_authors</td></tr>\n";
			echo "<tr class=\"dataview\"><td class=\"data_desc\">Additional comments:</td><td class=\"data_value\">$additional_comments</td></tr>\n";
			echo "<tr class=\"dataview\"><td class=\"data_desc\">Keywords:</td><td class=\"data_value\">$keywords</td></tr>\n";
			echo "<tr class=\"dataview\"><td class=\"data_desc\">Reference IDs:</td><td class=\"data_value\">$reference_ids</td></tr>\n";
			echo "<tr class=\"dataview\"><td class=\"data_desc\">Validated:</td><td class=\"data_value\">$validated</td></tr>\n";
			echo "<tr class=\"dataview\"><td class=\"data_desc\">Validation date:</td><td class=\"data_value\">$vdate</td></tr>\n";
			echo "<tr class=\"dataview\"><td class=\"data_desc\">Author:</td><td class=\"data_value\">$author</td></tr>\n";
			
			// Diplay data type specific stuff
			if($object_type=="ao" && $data_type == "fsdata") {
				$query = mysql_query("SELECT xunits, yunits, fs FROM $db.fsdata WHERE obj_id=$obj_id");
				if(mysql_num_rows($query)) {
					echo "<tr class=\"dataview\"><td class=\"data_desc\">X units:</td><td class=\"data_value\">".mysql_result($query, 0, 0)."</td></tr>";
					echo "<tr class=\"dataview\"><td class=\"data_desc\">Y units:</td><td class=\"data_value\">".mysql_result($query, 0, 1)."</td></tr>";
					echo "<tr class=\"dataview\"><td class=\"data_desc\">FS:</td><td class=\"data_value\">".mysql_result($query, 0, 2)."</td></tr>";
				}
			} elseif($object_type=="ao" && $data_type == "tsdata") {
				$query = mysql_query("SELECT xunits, yunits, fs, nsecs, DATE_SUB(t0, INTERVAL ROUND(toffset / 1000) SECOND) FROM $db.tsdata WHERE obj_id=$obj_id");
				if(mysql_num_rows($query)) {
					echo "<tr class=\"dataview\"><td class=\"data_desc\">X units:</td><td class=\"data_value\">".mysql_result($query, 0, 0)."</td></tr>";
					echo "<tr class=\"dataview\"><td class=\"data_desc\">Y units:</td><td class=\"data_value\">".mysql_result($query, 0, 1)."</td></tr>";
					echo "<tr class=\"dataview\"><td class=\"data_desc\">FS:</td><td class=\"data_value\">".mysql_result($query, 0, 2)."</td></tr>";
					echo "<tr class=\"dataview\"><td class=\"data_desc\">Number of seconds:</td><td class=\"data_value\">".mysql_result($query, 0, 3)."</td></tr>";
					echo "<tr class=\"dataview\"><td class=\"data_desc\">t<sub>0</sub>:</td><td class=\"data_value\">".mysql_result($query, 0, 4)."</td></tr>";
				}
			} elseif($object_type=="ao" && $data_type == "cdata") {
				$query = mysql_query("SELECT yunits FROM $db.cdata WHERE obj_id=$obj_id");
				if(mysql_num_rows($query)) {
					echo "<tr class=\"dataview\"><td class=\"data_desc\">Y units:</td><td class=\"data_value\">".mysql_result($query, 0, 0)."</td></tr>";
				}
			} elseif($object_type=="ao" && $data_type == "xydata") {
				$query = mysql_query("SELECT xunits, yunits FROM $db.xydata WHERE obj_id=$obj_id");
				if(mysql_num_rows($query)) {
					echo "<tr class=\"dataview\"><td class=\"data_desc\">X units:</td><td class=\"data_value\">".mysql_result($query, 0, 0)."</td></tr>";
					echo "<tr class=\"dataview\"><td class=\"data_desc\">Y units:</td><td class=\"data_value\">".mysql_result($query, 0, 1)."</td></tr>";
				}
			}
			
			
			// Show the collection
			echo "<tr class=\"dataview\"><td class=\"data_desc\">Objects in this collection:</td><td class=\"data_value\">";
			$result = mysql_query("SELECT obj_id FROM $db.collections2objs WHERE id=(SELECT id FROM $db.collections2objs WHERE obj_id=$obj_id)");
			if(!$result) echo mysql_error();
			while($row = mysql_fetch_row($result)) {
				echo "<a href=\"show_new_data.php?db=$db&amp;id=$row[0]\">$row[0]</a> ";
			}
			echo "</td></tr>\n";
			
			
			// Last transactions
			$query = mysql_query("SELECT COUNT(*) FROM $db.users, $db.transactions WHERE users.id=transactions.user_id AND transactions.obj_id=$obj_id");
			$num_results = mysql_result($query, 0, 0);
			if($num_results>0) {
				if(isset($_GET["transactions"]) && $_GET["transactions"]=="show_all") $limit = "";
				else $limit = " LIMIT 15";
				$query = mysql_query("SELECT users.given_name, users.family_name, users.email, transactions.transdate, transactions.direction FROM `$mysql_database`.`users` , `$db`.`transactions` WHERE users.id=transactions.user_id AND transactions.obj_id=$obj_id $limit");
				echo "<tr class=\"dataview\"><td class=\"data_desc\">Transactions:</td><td class=\"data_value\">";
				while($row = mysql_fetch_array($query, MYSQL_NUM)) {
					echo $row[3]." <a href=\"mailto:".$row[2]."\">".$row[1].", ".$row[0]."</a> - ".$row[4]."<br />";
				}
				if($limit!="" && $num_results>15) echo "<a href=\"show_data.php?db=$db&amp;table=$table&amp;id=$id&amp;transactions=show_all\">Show all</a>";
				echo "</td></tr>\n";
				
			}
			
			# Generate plot
			if($object_type=="ao" && $data_type!="cdata" && $is_plottable) {
			    
				if(file_exists($path."/".$filename_main)) {
					echo "<tr class=\"dataview\"><td class=\"data_desc\">Plot:</td><td class=\"data_value\">";
					echo "<img src=\"".$ext_plot_path."/".$filename_main."\" alt=\"main plot - id $obj_id\" title=\"$experiment_title\"/>";
					echo "</td></tr>";
				} else {
					echo "<tr class=\"dataview\"><td class=\"data_desc\">Plot:</td><td class=\"data_value\" id=\"plot_field\">";
					echo "<img src=\"images/ajax-loader.gif\" alt=\"AJAX-Loader\" />";
					echo "</td></tr>";
				}
				
				# Display the phase
				if(file_exists($path."/".$filename_phase)) {
					echo "<tr class=\"dataview\"><td class=\"data_desc\">Plot:</td><td class=\"data_value\">";
					echo "<img src=\"".$ext_plot_path."/".$filename_phase."\" alt=\"phase plot - id $obj_id\" title=\"$experiment_title\"/>";
					echo "</td></tr>";
				}
			
				# Check for error log
				if(file_exists($path."/".$filename_error) && filesize($path."/".$filename_error)>2) {
					echo "<tr class=\"dataview\"><td class=\"data_desc\">Plot:</td><td class=\"data_value\">";
					echo "<b>The plot robot generated an error:</b><br>\n";
					$file = fopen($path."/".$filename_error, 'r');
					while(!feof($file)) {
						echo fgets($file)."<br />";
					}
					fclose($file);
					echo "</td></tr>\n";
				}
			
			    // Display first 10 values and other info from the meta data file
    			if(file_exists($path."/".$filename_meta)) {
    				$file = fopen($path."/".$filename_meta, "r");
    				while(!feof($file)) {
    					$line = fgets($file);
    					$linedata = explode("=", $line);
    					if($line!="") echo "<tr class=\"dataview\"><td class=\"data_desc\">".$linedata[0].":</td><td class=\"data_value\">".$linedata[1]."</td></tr>\n";
    				}
    			}
			}
			
			
			echo "</table>\n";
			
			echo "<script type=\"text/javascript\">showPlot('$db', '$obj_id');</script>";
		
		/*	
		} else {
			echo "<h3>Table: $table</h3>\n";
			$query = mysql_query("SELECT * FROM ".mysql_real_escape_string($db).".".mysql_real_escape_string($table)." WHERE id=$id");
			$columns = mysql_num_fields($query);
			for($i=0; $i<$columns; $i++) {
				echo "<p><b>".mysql_field_name($query, $i).":</b> ".prepare_text(mysql_result($query, 0, $i))."</p>";
			}
		}
		*/
	}
	
} else include("login.inc.php");

include("footer.inc.php");

function prepare_text($text)
{
	$text = substr($text, 0, 40000);
	$text = str_replace("<", "&lt;", $text);
	$text = str_replace(">", "&gt;", $text);
	return $text;
}
?>
