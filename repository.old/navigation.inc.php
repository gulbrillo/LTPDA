<?php
// $CVS_TAG="$Id: navigation.inc.php,v 1.5 2011/06/14 10:07:15 mauro Exp $";
// ************* Navigate through all other tables *********
$pages = (($datasets - ($datasets % $show_rows)) / $show_rows) +1;
// Set the minimum number shown:
if($_GET["page"]<11) $min = 1;
else $min = $_GET["page"] - 10;
// Set the maximum number shown:
if($pages>$_GET["page"]+10) $max = $_GET["page"]+10;
else $max = $pages;
echo "<a href=\"$php_page?db=$database&amp;page=1&amp;order=$query_order&amp;direction=$query_order_direction#table\"><img src=\"images/first.png\" height=\"22px\" width=\"22px\" alt=\"First\" title=\"First\" /></a>\n";
if($_GET["page"]>1) echo "<a href=\"$php_page?db=$database&amp;page=".($_GET["page"]-1)."&amp;order=$query_order&amp;direction=$query_order_direction#table\"><img src=\"images/previous.png\" height=\"22px\" width=\"22px\" alt=\"Previous\" title=\"Previous\" /></a>\n";
if($min>1) echo "...\n";
for($i=$min; $i<=$max; $i++) {
	echo "<a href=\"$php_page?db=$database&amp;page=$i&amp;order=$query_order&amp;direction=$query_order_direction#table\" class=\"greatlink\">$i</a>\n";
}
if($max<$pages) echo "...\n";
if($_GET["page"]<$pages) echo "<a href=\"$php_page?db=$database&amp;page=".($_GET["page"]+1)."&amp;order=$query_order&amp;direction=$query_order_direction#table\"><img src=\"images/next.png\" height=\"22px\" width=\"22px\" alt=\"Next\" title=\"Next\" /></a>\n";
echo "<a href=\"$php_page?db=$database&amp;page=$pages&amp;order=$query_order&amp;direction=$query_order_direction#table\"><img src=\"images/last.png\" height=\"22px\" width=\"22px\" alt=\"Last\" title=\"Last\" /></a>\n";
// *********************************************************
?>
