<?php
include("config.inc.php"); // some constants
include("passtest.inc.php"); // checks the User/Password

// $CVS_TAG="$Id: contact.php,v 1.10 2012/01/05 10:09:16 gerrit Exp $";

$title = "About";
include("header.inc.php");

if($passtest && $connected) {
	echo "<h1>$title</h1>";
	
	echo "<p>Interface version: ".$custom_version."</p>";
	
	echo "<p>If you found a bug or have feature request, you can file them at the <a href=\"https://ed.fbk.eu/ltpda/mantis/\">Mantis Bugtracker</a>.</p>";
	
	// ******************************************************************
	
	// You can provide additional contact information here like this:
	// echo "<p>Some text</p>";
	
	// ******************************************************************
	
	// List the first administrator here:
	$query = mysql_query("SELECT given_name, family_name, email FROM users WHERE is_admin=1 ORDER BY id LIMIT 1");
	if(mysql_num_rows($query)) echo "<p>Administration: ".mysql_result($query,0,0)." ".mysql_result($query,0,1)." (<a href=\"mailto:".mysql_result($query,0,2)."\">".mysql_result($query,0,2)."</a>)</p>\n";
	
	// Web interface:
	echo "<p>Web interface: Gerrit Visscher (<a href=\"mailto:gerrit@visscher.de\">gerrit@visscher.de</a>)</p>\n";
	
	
	// Ressources:
	echo "<p style=\"font-size: small;\">";
	echo "Plus-sign to add condition: http://kyo-tux.deviantart.com/<br />";
	echo "</p>";
} else include("login.inc.php");

include("footer.inc.php");
?>
