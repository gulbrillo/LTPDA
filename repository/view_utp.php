<?php
include("config.inc.php"); // some constants
include("passtest.inc.php"); // checks the User/Password

// require("utp_funcs.inc.php");

$title = "View UTP reports";
// $CVS_TAG="$Id: view_utp.php,v 1.4 2011/06/14 10:07:15 mauro Exp $";
include("header.inc.php");

echo "<h1>$title</h1>\n";

function read_file($filename)
{
	$data = array();
	$base_dir = get_base_dir();
	$filename = $base_dir."/".$filename."/report.txt";
	if(!file_exists($filename)) {
		echo "<p class=\"error\">Could not find file $filename</p>";
		return array();
	}
	$file = fopen($filename, 'r');
	$i=0;
	while(!feof($file)) {
		$line = trim(fgets($file));
		if($line!="") $data[$i++] = explode("\t", $line);
	}
	return $data;
}

function get_base_dir()
{
	$base_dir = "";
	$query = mysql_query("SELECT value FROM options WHERE name=\"utp_path\"");
	if(mysql_num_rows($query)>0) $base_dir = mysql_result($query, 0, 0);
	else return "<p class=\"error\">Not UTPs found. Could not find base directory. Please set this on the <a href=\"options.php\">options</a> page.</p>";
	if(!file_exists($base_dir)) return "<p class=\"error\">Not UTPs found. Base directory does not exist. Please correct this on the <a href=\"options.php\">options</a> page or create this directory.</p>";
	if(!is_dir($base_dir)) "<p class=\"error\">Not UTPs found. Base directory is a file. Please correct this on the <a href=\"options.php\">options</a> page or create a new directory.</p>";
	return $base_dir;
}

function list_test_runs()
{
	$base_dir = get_base_dir();
	
	$i = 0;
	$utps = array();
	if ($dh = opendir($base_dir)) {
		while (($file = readdir($dh)) !== false) {
			if(substr($file, 0, 3)=="utp") {
				$utps[$i][0] = $file;
				$utps[$i++][1] = substr($file, 4, 4)."-".substr($file, 8, 2)."-".substr($file, 10, 2)." ".substr($file, 13, 2).":".substr($file, 15, 2).":".substr($file, 17, 2);
			}
		}
		closedir($dh);
	}
	return $utps;
	
}

function error_count($data, $column, $search)
{
	$errors = 0;
	foreach($data as $set) {
		if($set[$column]==$search && ($set[4]=="0" || $set[5]=="0")) $errors++;
	}
	return $errors;
}

echo "<table class=\"utphidden\"><tr class=\"utphidden\">\n";

if(isset($_GET["test"])) $selected_test = $_GET["test"];
if(isset($_GET["type"])) $selected_type = $_GET["type"];

// *** Test if vars are sane ***
if(strstr($selected_test, "/")) $selected_test="";
// ****************************

$tests = list_test_runs();
if(is_array($tests)) {
	echo "<td valign=\"top\" class=\"utphidden\"><table class=\"utpright\">\n<tr><th>test run</th></tr>\n";
	foreach($tests as $test) {
		if($selected_test==$test[0] || !$selected_test) $class = " class=\"utpselected\"";
		else $class = " class=\"utp\"";
		
		echo "<tr><td$class><a href=\"view_utp.php?test=".$test[0]."\">".$test[1]."</a></td></tr>\n";
	}
	echo "</table></td>\n";
} else echo "<p class=\"error\">$tests</p>\n";

if($selected_test) {
	$data = read_file($selected_test);
	echo "<td class=\"utphidden\"><table class=\"utpright\">\n<tr><th colspan=\"2\">object</th></tr>\n";
	
	$old_type = "";
	foreach($data as $test) {
		// Set the highlight
		if($selected_type==$test[1] || !$selected_type) $class = " class=\"utpselected\"";
		else $class = " class=\"utp\"";
		
		if($old_type!=$test[1]) echo "<tr$class><td$class><a href=\"view_utp.php?test=".$_GET["test"]."&amp;type=".$test[1]."\">".$test[1]."</a></td><td$class>".error_count($data, 1, $test[1])."</td></tr>\n";
		$old_type = $test[1];
	}
	echo "</table></td>\n";
}

if($selected_test && $selected_type) {
	echo "<td valign=\"top\" class=\"utphidden\"><table class=\"utpright\">\n<tr><th colspan=\"2\">type</th></tr>\n";
	$subtype = "";
	foreach($data as $set) {
		// Set the highlight
		if($selected_type==$set[2]) $class = " class=\"utp\"";
		
		if($set[1]==$selected_type && $subtype!=$set[2]) echo "<tr$class><td$class>".$set[2]."</td><td$class>".error_count($data, 2, $set[2])."</td></tr>\n";
		$subtype = $set[2];
	}
	echo "</table></td>\n";
}

echo "</tr></table>\n";

include("footer.inc.php");
?>
