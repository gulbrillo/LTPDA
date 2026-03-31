<?php

require("version.inc.php");
//$Id = "";
//$CVS_HEADER="$Id: header.inc.php,v 1.26 2012/01/05 11:20:36 gerrit Exp $";

echo "<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n";

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<title><?php echo $title; ?></title>
	<style type="text/css">@import "ltpda.css";</style>
	<link rel="icon" href="images/favicon.png" type="image/png" />
	<script type="text/javascript" src="ajax.js"></script>
</head>
<?php
echo "<body";
if(isset($onLoad)) echo " onLoad=\"$onLoad\"";
echo ">";
 ?>

<div id="head">

<div id="innerhead">
	<img src="images/LisaPF-logo_small.png" width="90" height="90" alt="LISA Logo" />
	<h1>LTPDA</h1>
	<h2>web interface</h2>
	<p>[<a href="index.php">home</a>] [<a href="contact.php">about</a>]<?php if($passtest) echo " [<a href=\"index.php?logout=true\">logout</a>]"; ?></p>
</div>

</div>

<?php

if(!isset($need_full_page)) $need_full_page = "";

if($need_full_page) echo "<div id=\"main_panel_full\">\n\n";
else echo "<div id=\"main_panel_normal\">\n\n";

$connected = mysql_connect($mysql_host, $mysql_user, $mysql_pass);
if($connected) mysql_select_db($mysql_database);
else echo "<p>Cannot connect to MySQL server ($mysql_host). Please check if the server is up and config.inc.php is configured correctly.</p>\n";

?>
