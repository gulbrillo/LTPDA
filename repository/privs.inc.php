<?php

// $CVS_TAG="$Id: privs.inc.php,v 1.4 2012/01/26 11:51:31 gerrit Exp $";

function setpriv($perm, $grant, $username, $db, $host)
{
	if ($grant) {
		$rv = mysql_query(sprintf("GRANT %s ON `%s`.* TO '%s'@'%s'",
                                    $perm,
                                    mysql_real_escape_string($db),
                                    mysql_real_escape_string($username),
                                    mysql_real_escape_string($host)));
        if (!$rv) {
            echo "<p class=\"error\">".mysql_error()."</p>\n";
            return 1;
        }
		$rv = mysql_query(sprintf("GRANT INSERT ON `%s`.transactions TO '%s'@'%s'",
                                    mysql_real_escape_string($db),
                                    mysql_real_escape_string($username),
                                    mysql_real_escape_string($host)));
		if (!$rv) {
			echo "<p class=\"error\">".mysql_error()."</p>\n";
			return 1;
		}

	} else {
		// Check if user actually has that rights
		$result = mysql_query(sprintf("SELECT %s_priv-1 FROM mysql.db AS db WHERE user='%s' AND host='%s'",
																						$perm, $username, $host));
		if(mysql_result($result, 0, 0)==1) {
		
			$rv = mysql_query(sprintf("REVOKE %s ON `%s`.* FROM '%s'@'%s'",
                                    $perm,
                                    mysql_real_escape_string($db),
                                    mysql_real_escape_string($username),
                                    mysql_real_escape_string($host)));
			if (!$rv) {
        		echo "<p class=\"error\"> revoke".mysql_error()."</p>\n";
            	return 1;
        	}
		}
    }
    return 0;
}

?>
