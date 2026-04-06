
<?php
include("config.inc.php"); // some constants
include("passtest.inc.php"); // checks the User/Password

$title = $main_page;
// $CVS_TAG="$Id: main.php,v 1.3 2011/06/14 10:07:16 mauro Exp $";
include("header.inc.php");

if($connected) {
	echo "<h1>$title</h1>";
	echo "You're in. Here be more text.";
}

include("footer.inc.php");

?>
