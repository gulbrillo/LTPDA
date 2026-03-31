<?php
include("config.inc.php"); // some constants
include("passtest.inc.php"); // checks the User/Password

// $CVS_TAG="$Id: layout_update_help.php,v 1.3 2012/01/26 19:06:48 gerrit Exp $";

$title = "How to run the layout update";
include("header.inc.php");

if($passtest && $connected) {
	echo "<h1>$title</h1>";
?>
	<p>This version of the LTPDA repository uses a new database layout. The conversion can take some time and therefore must be done via a terminal.</p>
	
	<ol>
	<li>Open a terminal and log into the server.</li>
	<li>Change to the ltpda directory (e.g. <tt>/var/www/ltpdarepo</tt>)</li>
	<li>run the upgrade script: <tt>ruby db_layout_update.rb</tt></li>
	</ol>
	<p>Depending on the size of you databases, the conversion can take up to several hours.</p>
	
	<h2>Disk space</h2>
	<p>On a test server with around 40GB of databases (3 databases with ~9.5GB and 2 with ~5.5GB) the upgrade took about 11 hours. It is a good idea to run the upgrade at night or at a weekend. During the upgrade, you need enough free space on the partition that contains the mysql databases (e.g. <tt>/var/lib/mysql</tt>). A free disk space of about twice the size of your largest database is recommended. You can have a look at the upgrade process on the test server on the chart below.</p>
	<h2>Access to MySQL</h2>
	<p>It is recommended not to connect to the database with the toolbox during the upgrade process. To make sure mysql can only be accessed from the local machine you can set <tt>bind-address = 127.0.0.1</tt> in the mysql config file (<tt>/etc/mysql/my.cnf</tt>). Do not forget to reload the config. On most distributions you can use <tt>service mysql reload</tt> for this.</p>
	<img src="images/disk_space.png" alt="Disk space plot over time" />
<?php
} else include("login.inc.php");

include("footer.inc.php");
?>
