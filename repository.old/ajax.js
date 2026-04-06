function showPlot(database, id)
{
	if (database=="" || id == "") {
		document.getElementById("plot_field").innerHTML="";
		return;
	}
	
	if (window.XMLHttpRequest) {
		// code for IE7+, Firefox, Chrome, Opera, Safari
		xmlhttp=new XMLHttpRequest();
	} else {
		// code for IE6, IE5
		xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
	}
	
	xmlhttp.onreadystatechange=function() {
		if (xmlhttp.readyState==4 && xmlhttp.status==200) {
			var response = xmlhttp.responseText.split("\n");
			var tempNode = document.getElementById("plot_field").parentNode;
			// alert("Now."+tempNode.nodeName);
			var tableNode = tempNode.parentNode;
			// alert("Now."+tableNode.nodeName+": "+tableNode.rows.length);
			tableNode.deleteRow(tableNode.rows.length-1);
			
			for(var i=0; i < response.length; i++) {
				var info = response[i].split("|");
				if(info[0].replace (/^\s+/, '').replace (/\s+$/, '')=="") continue;
				
				var row = tableNode.insertRow(tableNode.rows.length);
				row.setAttribute("class", "dataview");
				
				var cell1 = row.insertCell(0);
				cell1.setAttribute("class", "data_desc");
				cell1.innerHTML = info[0];
				
				var cell2 = row.insertCell(1);
				cell2.setAttribute("class", "data_value");
				cell2.innerHTML = info[1];
			}
			
			// document.getElementById("plot_field").innerHTML=;
    	}
  	}
	
	xmlhttp.open("GET","plot.php?db="+database+"&id="+id,true);
	xmlhttp.send();
}

function showDownload(database, id)
{
	document.getElementById("downloadPlot").innerHTML="<img src=\"images/ajax-loader.gif\" alt=\"Loader\" title=\"Generating plot...\" />";
	
	if (database=="" || id == "") {
		document.getElementById("plot_field").innerHTML="";
		return;
	}
	
	if (window.XMLHttpRequest) {
		// code for IE7+, Firefox, Chrome, Opera, Safari
		xmlhttp=new XMLHttpRequest();
	} else {
		// code for IE6, IE5
		xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
	}
	
	xmlhttp.onreadystatechange=function() {
		if (xmlhttp.readyState==4 && xmlhttp.status==200) {
			var response = xmlhttp.responseText;
			document.getElementById("downloadPlot").innerHTML=response;
    	}
  	}
	
	xmlhttp.open("GET","plot.php?download=true&db="+database+"&id="+id,true);
	xmlhttp.send();
}

function addCondition(options, database)
{
	var list = document.getElementById("condition_list");
	var addButtonDiv = document.getElementById("condition_add");
	var selectFields = document.getElementsByTagName("select").length;
	var hiddenCount = document.getElementById("condition_count");
	var number = hiddenCount.value;
	var newCondition = document.createElement("div");
	newCondition.setAttribute("class", " condition_block");
	
	str_number = ""+number;
	while(str_number.length<4) {
		str_number = "0" + str_number;
	}
	
	var conditionHTML = "";
	if(selectFields>1) conditionHTML += "<select name=\"condition_connections[#]\" id=\"condition_connection_###\" ><option value=\"AND\">AND</option><option value=\"OR\">OR</option><option value=\"XOR\">XOR</option></select>\n";
	conditionHTML += "<select name=\"condition_fields[#]\" id=\"condition_field_###\" onChange=\"javascript:selectOperator('###', '"+database+"')\" >"+options+"</select>\n<select name=\"condition_operators[#]\" id=\"condition_operator_###\" class=\"condition_operator_select\"></select>\n<input type=\"text\" name=\"condition_values[#]\" id=\"condition_value_###\" />";
	
	var name = "condition_"+str_number;
	newCondition.setAttribute("id", name);
	
	conditionHTML = conditionHTML.replace(/###/g, str_number);
	conditionHTML = conditionHTML.replace(/#/g, number);
	conditionHTML += " <a href=\"javascript:removeCondition('"+name+"')\"><img src=\"images/minus.png\" alt=\"minus\" title=\"Remove condition\" /></a><br />";
	newCondition.innerHTML = conditionHTML;
	
	list.insertBefore(newCondition, addButtonDiv);
	
	hiddenCount.value = parseInt(number) + 1;
	selectOperator(str_number, database);
}

function removeCondition(name)
{
	var cond = document.getElementById(name);
	var parentElement = document.getElementById("condition_list");
	parentElement.removeChild(cond);
}

function selectOperator(id_number, database)
{
	var fieldSelect = document.getElementById("condition_field_"+id_number);
	var field = fieldSelect.options[fieldSelect.selectedIndex].value;
	
	if (window.XMLHttpRequest) {
		// code for IE7+, Firefox, Chrome, Opera, Safari
		xmlhttp=new XMLHttpRequest();
	} else {
		// code for IE6, IE5
		xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
	}
	
	xmlhttp.onreadystatechange=function() {
		if (xmlhttp.readyState==4 && xmlhttp.status==200) {
			
			var fieldType = xmlhttp.responseText;
			
			var operatorSelect = document.getElementById("condition_operator_"+id_number);
			
			// Remove any existing operators
			while(operatorSelect.hasChildNodes()) {
				operatorSelect.removeChild(operatorSelect.firstChild);
			}
			
			if(fieldType=="text") {
				var o1 = document.createElement("option");
				var o1text = document.createTextNode("REGEXP");
				o1.appendChild(o1text);
				o1.setAttribute("value", "REGEXP");
				operatorSelect.appendChild(o1);

				var o2 = document.createElement("option");
				var o2text = document.createTextNode("LIKE");
				o2.appendChild(o2text);
				o2.setAttribute("value", "LIKE");
				operatorSelect.appendChild(o2);

				var o3 = document.createElement("option");
				var o3text = document.createTextNode("=");
				o3.appendChild(o3text);
				o3.setAttribute("value", "=");
				operatorSelect.appendChild(o3);
				
				var o4 = document.createElement("option");
				var o4text = document.createTextNode("<");
				o4.appendChild(o4text);
				o4.setAttribute("value", "lt");
				operatorSelect.appendChild(o4);

				var o5 = document.createElement("option");
				var o5text = document.createTextNode(">");
				o5.appendChild(o5text);
				o5.setAttribute("value", "gt");
				operatorSelect.appendChild(o5);
			}

			if(fieldType=="number") {
				var o1 = document.createElement("option");
				var o1text = document.createTextNode("=");
				o1.appendChild(o1text);
				o1.setAttribute("value", "=");
				operatorSelect.appendChild(o1);

				var o2 = document.createElement("option");
				var o2text = document.createTextNode("<");
				o2.appendChild(o2text);
				o2.setAttribute("value", "lt");
				operatorSelect.appendChild(o2);

				var o3 = document.createElement("option");
				var o3text = document.createTextNode(">");
				o3.appendChild(o3text);
				o3.setAttribute("value", "gt");
				operatorSelect.appendChild(o3);
			}
    	}
  	}
	
	xmlhttp.open("GET","field_type.php?db="+database+"&field="+field,true);
	xmlhttp.send();
	
}

function preselectField(field, selectFieldName)
{
	var selectField = document.getElementById(selectFieldName);
	for(var i = 0; i < selectField.options.length; i++) {
		if(selectField.options[i].value==field) {
			selectField.selectedIndex = i;
		} 
	}
}