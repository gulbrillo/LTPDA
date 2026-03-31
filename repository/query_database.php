<?php
include("config.inc.php"); // some constants
include("passtest.inc.php"); // checks the User/Password

/**
TODO:
- add mysql_real_escape_string()
- test UTF-8
*/

// if(isset($_GET["preselect"]) && $_GET["preselect"]!="") preselectSet($_GET["preselect"]);

if(isset($_GET["db"])) $database = $_GET["db"];
else $database = "";
if(isset($_GET["page"])) $page = $_GET["page"]+0;
else $page = 0;
if(isset($_GET["order"])) $order = $_GET["order"];
else $order = "";
if(isset($_GET["direction"])) $direction = $_GET["direction"];
else $direction = "ASC";


$title = "Database: " . $database;
if(isset($_POST["fields"]) || isset($_GET["page"])) $need_full_page = true;
// $need_full_page = true;
include("header.inc.php");

if($passtest && $connected) {
	echo "<h1>$database</h1>";
	
	mysql_query("USE $database");
	
	// Test if View button was clicked
	if(isset($_POST["fields"]) || isset($_GET["page"])) {
		
		
		if($page>0) {
			// Restore session data
			$fields = $_SESSION["fields"];
			$condition_connections = $_SESSION["condition_connections"];
			$condition_fields = $_SESSION["condition_fields"];
			$condition_operators = $_SESSION["condition_operators"];
			$condition_values = $_SESSION["condition_values"];
			$database = $_SESSION["database"];
			$show_delete = $_SESSION["show_delete"];
			$quick_filter = $_SESSION["quick_filter"];
			mysql_query("USE $database");
		} else {
			
			// Read the data
			$fields = isset($_POST["fields"]) ? $_POST["fields"] : array();
			$condition_connections = isset($_POST["condition_connections"]) ? $_POST["condition_connections"] : array();
			$condition_fields = isset($_POST["condition_fields"]) ? $_POST["condition_fields"] : array();
			$condition_operators = isset($_POST["condition_operators"]) ? $_POST["condition_operators"] : array();
			$condition_values = isset($_POST["condition_values"]) ? $_POST["condition_values"] : array();
			if(isset($_POST["show_delete"]) && $_POST["show_delete"]==1) $show_delete = true;
			else $show_delete = false;
			if(isset($_POST["quick_filter"])) $quick_filter = $_POST["quick_filter"];
			else $quick_filter = "";
			
			// First field is not initialized, because there is no input field for it.
			$condition_connections[0] = "";
			
			// Tidy up the condition fields, they might not be numbered from 0 to count(), some might be missing
			$temp = remove_empty($condition_connections, $condition_fields, $condition_operators, $condition_values);
			$condition_connections = $temp[0];
			$condition_fields = $temp[1];
			$condition_operators = $temp[2];
			$condition_values = $temp[3];
			
			// Save the data to the session
			$_SESSION["fields"] = $fields;
			$_SESSION["condition_connections"] = $condition_connections;
			$_SESSION["condition_values"] = $condition_values;
			$_SESSION["condition_operators"] = $condition_operators;
			$_SESSION["condition_fields"] = $condition_fields;
			$_SESSION["database"] = $database;
			$_SESSION["show_delete"] = $show_delete;
			$_SESSION["quick_filter"] = $quick_filter;
		}
		
		// if quick_filter is changed, reset it again
		if(isset($_POST["quick_filter"])) {
			$quick_filter = $_POST["quick_filter"];
			$_SESSION["quick_filter"] = $quick_filter;
		}
		
		$tables = tables_from_fields($fields, $condition_fields);
		$query_begin = create_query($fields, $tables);
		$count_query = create_query($fields, $tables, true);
		
		$query_where = create_where($condition_connections, $condition_fields, $condition_operators, $condition_values, $quick_filter);
		
		$query_order = create_order($order, $direction);
		
		if(isset($_POST["limit"])) $limit = $_GET["limit"]+0;
		else $limit = 50;
		
		if($page>0) $limit_start = (($page - 1) * 50).",";
		else $limit_start = "";
		
		$query_limit = " LIMIT $limit_start $limit";
		
		$result = mysql_query($query_begin.$query_where.$query_order.$query_limit);
		if(!$result && $debug) echo "<p>MySQL reported an error: ".mysql_error()."</p>\n";
		
		// The executed query
		if($debug) echo "<p>".$query_begin.$query_where.$query_order.$query_limit."</p>\n";
		
		$count_result = mysql_query($count_query.$query_where);
		if($count_result) $num_rows = mysql_result($count_result, 0, 0);
		else $num_rows = 0;
		
		// The count to count the rows
		// echo "<p>".$count_query.$query_where."</p>\n";
		
		echo "<form action=\"query_database.php?db=$database&amp;page=1\" method=\"post\">";
		echo "[<a href=\"query_database.php?db=$database\">Edit query</a> | <a href=\"custom_query.php?db=$database\">Edit query manually</a>] | ";
		echo "Filter: <input type=\"text\" name=\"quick_filter\" value=\"$quick_filter\" /></form>\n";
		
		
		write_javascript($database);
		
		if($show_delete) echo "<form action=\"delete_object.php\" method=\"post\">\n";
		
		$rows_per_page = 50;
		write_navigation($page, $rows_per_page, $num_rows, $order, $direction);
		
		echo "<table class=\"datatable\">\n";
		write_table_header($result, $page, $order, $direction, $show_delete);
		write_table_data($result, $show_delete);
		echo "</table>";
		
		write_navigation($page, $rows_per_page, $num_rows, $order, $direction);
		$_SESSION["querytext"] = $query_begin.$query_where.$query_limit;
		
		if($show_delete) {
			echo "<input type=\"hidden\" name=\"database\" value=\"$database\" />\n";
			echo "<input type=\"submit\" name=\"submit_delete\" value=\"Delete selected objects\" />\n";
			echo "</form>\n";
		}
	} else {
		
		// ------------------------- Form ---------------------------------------
		
		if(isset($_GET["reset"])) {
			unset($_SESSION["fields"]);
			unset($_SESSION["condition_connections"]);
			unset($_SESSION["condition_fields"]);
			unset($_SESSION["condition_operators"]);
			unset($_SESSION["condition_values"]);
			unset($_SESSION["quick_filter"]);
		} 
		
		$preselected_fields = isset($_SESSION["fields"]) ? $_SESSION["fields"] : array("objmeta.created", "objmeta.obj_type", "objmeta.name", "objmeta.version", "objmeta.experiment_title", "objmeta.experiment_desc", "objmeta.analysis_desc");
		$condition_connections = isset($_SESSION["condition_connections"]) ? $_SESSION["condition_connections"] : array();
		$condition_fields = isset($_SESSION["condition_fields"]) ? $_SESSION["condition_fields"] : array();
		$condition_operators = isset($_SESSION["condition_operators"]) ? $_SESSION["condition_operators"] : array();
		$condition_values = isset($_SESSION["condition_values"]) ? $_SESSION["condition_values"] : array();
		$quick_filter = isset($_SESSION["quick_filter"]) ? $_SESSION["quick_filter"] : "";
		
		// Show form for query
		$tables = array("objs", "objmeta", "ao", "miir", "mfir", "tsdata", "fsdata", "xydata", "cdata", "transactions");
		$fields = array();
		foreach($tables as $table) {
			$query = mysql_query("SHOW COLUMNS FROM `$table`");
			while($row = mysql_fetch_row($query)) {
				if($row[0]!="obj_id" && $row[0]!="xml" && $table.".".$row[0]!="transactions.id") {
					$fields[] = $table.".".$row[0];
				}
			}
		}
		
		echo "<form action=\"query_database.php?db=$database\" method=\"post\">\n";
		
		echo "<fieldset><legend>Columns &amp; Conditions</legend>\n";
		echo "<div class=\"field_list\">\n";
		echo "<select name=\"fields[]\" size=\"28\" multiple=\"multiple\">\n";
		echo create_fields($fields, false, $preselected_fields);
		echo "</select>\n";
		echo "</div>\n";
		
		echo "<div class=\"condition_list\" id=\"condition_list\">\n";
		echo "Quick filter meta data by one word: <input type=\"text\" name=\"quick_filter\" value=\"$quick_filter\" /><br /><hr />\n";
		for($i=0; $i<count($condition_fields); $i++) {
			if(isset($condition_fields[$i]) && $condition_fields[$i]!="") {
				$str_number = "".$i;
				while(strlen($str_number)<4) $str_number = "0".$str_number;
				
				$options = create_fields($fields, true, array($condition_fields[$i]));
				$operators = create_operators($condition_fields[$i], $condition_operators[$i]);
				
				echo "<div id=\"condition_$str_number\" class=\"condition_block\">\n";
				if($i!=0) {
					$connections = create_connections($condition_connections[$i]);
					echo "<select name=\"condition_connections[$i]\" id=\"condition_connection_$str_number\">$connections</select>\n";
				}
				echo "<select name=\"condition_fields[$i]\" id=\"condition_field_$str_number\" onchange=\"javascript:selectOperator('$str_number', '$database')\" >$options</select>\n";
				echo "<select name=\"condition_operators[$i]\" id=\"condition_operator_$str_number\" class=\"condition_operator_select\">$operators</select>\n";
				echo "<input type=\"text\" name=\"condition_values[$i]\" id=\"condition_value_$str_number\" value=\"$condition_values[$i]\" />\n";
				echo " <a href=\"javascript:removeCondition('condition_$str_number')\"><img src=\"images/minus.png\" alt=\"minus\" title=\"Remove condition\" /></a>\n</div>\n";
				// old image: <img src=\"images/delete.png\" alt=\"Delete\" title=\"Remove condition\" />
				
			}
		}
		$options = str_replace("\"", "\'", create_fields($fields, true, array()));
		echo "<div id=\"condition_add\" class=\"condition_block\"><a href=\"javascript:addCondition('$options', '$database')\"><img src=\"images/plus.png\" alt=\"plus\" title=\"Add condition\" /></a>\n</div>\n";
		// old image: <img src=\"images/add24.png\" alt=\"Plus\" title=\"Add condition\" class=\"condition_add\" />
		echo "</div>\n</fieldset>\n";
		
		echo "<fieldset><legend>View</legend>";
		echo "<input type=\"hidden\" name=\"condition_count\" value=\"".count($condition_fields)."\" id=\"condition_count\" /> \n";
		echo "<input type=\"submit\" name=\"submit_data\" value=\"View\" />";
		echo "<input type=\"checkbox\" name=\"show_delete\" value=\"1\" /> Show delete boxes";
		echo "</fieldset>\n";
		echo "</form>\n";
		echo "<p>[ <a href=\"query_database.php?db=$database&amp;reset=true\">Reset</a> ]</p>\n";
	}
	
} else include("login.inc.php");

include("footer.inc.php");

function is_clean($field)
{
	$regexp = '/^[a-zA-Z0-9_\-\.]*$/';
	return preg_match($regexp, $field);
}

function remove_empty($conns, $fields, $ops, $vals)
{
	$new_fields = array();
	$new_ops = array();
	$new_vals = array();
	$new_conns = array();
	for($i=0; $i<100; $i++) {
		if(isset($fields[$i]) && $fields[$i]!="") {
			$new_fields[] = $fields[$i];
			$new_ops[] = $ops[$i];
			$new_vals[] = $vals[$i];
			$new_conns[] = $conns[$i];
		}
	}
	return array($new_conns, $new_fields, $new_ops, $new_vals);
}

// Returns all selected tables without "objs"
function tables_from_fields($fields, $condition_fields)
{
	$tables = array();
	foreach($fields as $field) {
		$temp = explode(".", $field);
		$table = $temp[0];
		if($table!="objs" && $table!="") $tables[] = $table;
	}
	foreach($condition_fields as $field) {
		$temp = explode(".", $field);
		$table = $temp[0];
		if($table!="objs" && $table!="") $tables[] = $table;
	}
	sort($tables);
	$tables = array_unique($tables);
	return $tables;
}

function create_query($fields, $tables, $count_only=false)
{
	$connects = array();
	foreach($tables as $table) {
		$connects[] = $table.".obj_id=objs.id";
	}
	
	$query = "SELECT ";
	if($count_only) $query .= "COUNT(*)";
	else {
		$query .= "objs.id, ";
		$query .= implode($fields, ", ");
	}
	$query .= " FROM objs ";
	
	foreach($tables as $table) {
		$query .= "LEFT JOIN $table ON objs.id=$table.obj_id ";
	}
	
	/* Old version:
	$query .= " FROM objs INNER JOIN ";
	$query .= implode($tables, ", ");
	$query .= ") ON (";
	$query .= implode($connects, " AND ");
	$query .= ")";
	*/
	
	return $query;
}

function create_where($connections, $fields, $operators, $values, $quick_filter)
{
	$condition = " WHERE ";
	
	if($quick_filter!="") {
		$condition .= "CONCAT_WS(' ', objmeta.obj_type, objmeta.name, objmeta.version, objmeta.ip, objmeta.hostname, objmeta.os, objmeta.experiment_title, objmeta.experiment_desc, objmeta.analysis_desc, objmeta.quantity, objmeta.additional_authors, objmeta.additional_comments, objmeta.keywords, objmeta.author) LIKE '%".mysql_real_escape_string($quick_filter)."%' ";
		$first = false;
	} else $first = true;
	
	for($i=0; $i<count($fields); $i++) {
		if($operators[$i]=="lt") $op = "<";
		elseif($operators[$i]=="gt") $op = ">";
		else $op = $operators[$i];
			
		if(!is_numerical($fields[$i])) $values[$i] = "'" . $values[$i] . "'";
			
		if($first) $condition .= ($fields[$i] . " " . $op . " " . $values[$i]." ");
		else $condition .= ($connections[$i]." " . $fields[$i] . " " . $op . " " . $values[$i]." ");
		$first = false;
	}
	if($first) return ""; // If $first is still true, there are no condition
	return $condition;
}

function create_order($order, $direction)
{
	if($direction!="ASC" && $direction!="DESC" && $direction!="") return "";
	if($order=="" || !is_clean($order)) return "";
	return " ORDER BY ".$order." ".$direction;
}

function is_numerical($field)
{
	$temp = explode(".", $field);
	$table = $temp[0];
	$field = $temp[1];
	$result = mysql_query("SHOW COLUMNS FROM $table WHERE field='$field'");
	if($result) {
		$type = mysql_result($result, 0, 1);
		if(substr($type, 0, 6)=="bigint") return true;
		if(substr($type, 0, 3)=="int") return true;
		if(substr($type, 0, 7)=="tinyint") return true;
		if(substr($type, 0, 6)=="double") return true;
		if(substr($type, 0, 5)=="float") return true;
	}
	return false;
}


function write_javascript($database)
{
	// The JavaScript to get to the data view
	echo "\n<script type=\"text/javascript\">\n<!--\n";
	echo "function load_view(number) {\n";
	echo "window.location=\"show_new_data.php?db=$database&id=\"+number;\n";
	echo "}\n";
	echo "-->\n</script>\n\n";
}

function write_table_header($result, $page, $current_order, $current_direction, $show_delete=false)
{
	if($page==0) $page = 1;
	echo "<tr>";
	for($i=0; $i<mysql_num_fields($result); $i++) {
		$field = mysql_fetch_field($result, $i);
		
		$order = $field->table.".".$field->name;
		$fieldname = $field->name;
		if($fieldname=="id" && $field->table=="objs") $fieldname = "obj_id";
		$direction = "ASC";
		if($current_order==$order) {
			if($current_direction=="DESC") $direction = "ASC";
			else $direction = "DESC";
		}
		
		echo "<th class=\"dataheader\"><a href='query_database.php?page=$page&amp;order=$order&amp;direction=$direction'>".$fieldname."</a></th>";
	}
	if($show_delete) echo "<th class=\"dataheader\">Delete</th>";
	echo "</tr>\n";
}

function write_table_data($result, $show_delete=false)
{
	$i = 0;
	while($row = mysql_fetch_row($result)) {
		$onClick = "onclick=\"load_view('".$row[0]."')\"";
		echo "<tr class=\"showdata\">";
		foreach($row as $field) {
			if(strlen($field)>100) $field = substr($field, 0, 100)."...";
			echo "<td $onClick class=\"datafield\">$field</td>";
		}
		if($show_delete) {
			echo "<td class=\"datafield\"><input type=\"checkbox\" name=\"delete_ids[$i]\" value=\"".$row[0]."\"></td>";
		}
		echo "</tr>\n";
		$i++;
	}
}

function create_fields($fields, $with_obj_id, $preselected_fields)
{
	$t = explode(".", $fields[0]);
	$table = $t[0];
	$last_table = $table;
	$options = "<optgroup label=\"$table\">";
	foreach($fields as $field) {
		$t = explode(".", $field);
		$table = $t[0];
		if($last_table!=$table) $options .= "</optgroup><optgroup label=\"$table\">";
		$selected = in_array($field, $preselected_fields) ? "selected=\"selected\"" : ""; // Preselect last selection 
		if($with_obj_id || $field!="objs.id") $options .= "<option $selected value=\"$field\">$field</option>\n";
		$last_table = $table;
	}
	$options .= "</optgroup>\n";
	return $options;
}

function create_operators($field, $preselected_operator)
{
	$option_string = "";
	// First element is the value that is posted, second element is the value that is displayed. See: "gt" -> "&gt;"
	if(is_numerical($field)) $options = array(array("=", "="), array("lt", "&lt;"), array("gt", "&gt;"));
	else $options = array(array("REGEXP", "REGEXP"), array("LIKE", "LIKE"),
					array("=", "="), array("lt", "&lt;"), array("gt", "&gt;"));
	
	foreach($options as $set) {
		$selected = $preselected_operator==$set[0] ? "selected='selected'" : ""; 
		$option_string .= "<option $selected value='$set[0]'>$set[1]</option>\n";
	}
	
	return $option_string;
}

function create_connections($preselected_connection)
{
	$option_string = "";
	$connections = array("AND", "OR", "XOR");
	foreach($connections as $connection) {
		$selected = ($connection==$preselected_connection) ? "selected='selected'" : "";
		$option_string .= "<option $selected value='$connection'>$connection</option>";
	}
	return $option_string;
}

function write_navigation($current_page, $rows_per_page, $num_rows, $order, $direction)
{
	if($current_page==0) $current_page = 1;
	
	$num_pages = ceil($num_rows / $rows_per_page);
	
	$begin = $current_page - 5;
	if(($num_rows - 10) < $begin) $begin = $num_pages - 9;
	if($begin < 1) $begin = 1;
	
	$end = $current_page + 5;
	if($end < ($begin + 10)) $end = $begin + 9;
	if($end > $num_pages) $end = $num_pages;
	
	echo "<p><a href=\"query_database.php?page=1&amp;order=$order&amp;direction=$direction\">|&lt;</a> ";
	for($i=$begin; $i<=$end; $i++) {
		if($i == $current_page) echo "$i ";
		else echo "<a href=\"query_database.php?page=$i&amp;order=$order&amp;direction=$direction\">$i</a> ";
	}
	echo "<a href=\"query_database.php?page=$num_pages&amp;order=$order&amp;direction=$direction\">&gt;|</a></p>\n";
}
