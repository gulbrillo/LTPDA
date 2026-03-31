<?php
if(!$connected) {
	// If $connection is true but $connected not, the fault must be a wrong password (or a database inconsistency).
			if($connection && $login=="Login") echo "<p class=\"error\">The username/password combination you supplied seems to be incorrect.</p>\n";
}
// $CVS_HEADER="$Id: footer.inc.php,v 1.7 2011/06/14 10:07:16 mauro Exp $";

?>
</div>
</body>
</html>