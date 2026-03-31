#!/usr/bin/ruby

require 'net/http'
require 'net/https'
require 'mysql'

# Basepath after domain (with trailing slash)
$HTTP_HOST = "localhost"
$BASEPATH = "/lisa/"
$LOGIN_USER = "kayssun"
$LOGIN_PASS = "passwd"

$MYSQL_HOST = "localhost"
$MYSQL_USER = "root"
$MYSQL_PASS = "allyourbase"
$MYSQL_DB = "ltpda_admin"

class WebTest
	
	def page
		@page
	end
	
	def page=(page)
		@page = page
	end
	
	def post
		@post
	end
	
	def post=(post)
		@post = post
	end
	
	def last_data
		@last_data
	end
	
	def last_resp
		@last_resp
	end
	
	def last_query
		@last_query
	end
	
	# Logs in to the page and post data (if any)
	# return false, if a class="error" is found
	def run
		@http = Net::HTTP.new($HTTP_HOST, 80)
		# http.use_ssl = false
		path = $BASEPATH + @page
		
		# GET request (check, if this is necessary)
		# resp, data = http.get(path, nil)
		
		if @post!=nil and !@post[0,1]=="&" then
			@post = "&" + @post
		else
			@post = ""
		end
		
		# POST request -> logging in
		data = 'ltpda_user='+$LOGIN_USER+'&ltpda_password='+$LOGIN_PASS+'&ltpda_login_button=Login' + @post
		headers = {
			'Content-Type' => 'application/x-www-form-urlencoded'
		}
		
		resp, data = @http.post(path, data, headers)
		
		@cookie = resp.response['set-cookie']
		@last_data = data
		@last_resp = resp
		
		## Here be some output for the first try:
		#puts 'Code = ' + resp.code
		#puts 'Message = ' + resp.message
		#resp.each {|key, val| puts key + ' = ' + val}
		# puts data
		
		!data.include?('class="error"')
	end
	
	# Loads another page and greps for a string. Can post additional data
	def check_web(checkpage, needle, checkpost)
		path = $BASEPATH + checkpage
		if post!=nil then
			headers = {
				'Cookie' => @cookie,
				'Content-Type' => 'application/x-www-form-urlencoded'
			}
			resp, data = @http.post(path, checkpost, headers)
		else
			headers = {
				'Cookie' => @cookie
			}
			resp, data = @http.get(path, headers)
		end
		
		# Debugging...
		# puts data
		
		@last_data = data
		@last_resp = resp
		
		# Return if we found the needle
		data.include?(needle)
	end
	
	# Executes query and returns number of rows
	# if needle is given, returns number of rows containing needle in the first field
	def check_sql(squery, needle)
		db = Mysql.real_connect($MYSQL_HOST, $MYSQL_USER, $MYSQL_PASS, $MYSQL_DB)
		query = db.query(squery)
		
		if needle==nil then
			query.num_rows
		else
			count = 0
			while row = query.fetch_row
				if row[0].include?(needle) then
					count += 1
				end
			end
			count
		end
		
		@last_query = squery;
	end
	
	def logout 
		if @cookie!=nil then
			path = $BASEPATH + "index.php?logout=true"
			headers = {
				'Cookie' => @cookie
			}
			resp, data = @http.get(path, headers)
		end
	end
end

def generate_key()
	all = "abcdefghijklmnopqrstuvwxyz"
	key = ""
	8.times do
		key += all[rand(26), 1]
	end
	key
end

# Test if creating works
def test_create_database(key)
	protocol = Array.new
	mytest = WebTest.new
	mytest.page = "create_database.php"
	
	if mytest.run then
		protocol.push(['create_database.php main', true, ''])
	else
		protocol.push(['create_database.php main', false, mytest.last_data])
	end
	
	if mytest.check_web('create_database.php', 'class="success"', 'database_name=ltpda_test_'+key+'&database_long_name=LTPDA-Ruby-Test&database_description=FromRuby&create_button=Create') then
		protocol.push(['create_database.php create', true, ''])
	else
		protocol.push(['create_database.php create', false, mytest.last_data])
	end
	
	if mytest.check_sql('SHOW DATABASES', 'ltpda_test_'+key) > 0 then
		protocol.push(['create_database.php exists', true, ''])
	else
		protocol.push(['create_database.php exists', false, '\'SHOW DATABASES\' does not contain "ltpda_test_'+key+'"'])
	end
	
	if mytest.check_sql('SELECT db_name FROM available_dbs WHERE db_name="ltpda_test_'+key+'"', nil) > 0 then
		protocol.push(['create_database.php link exists', true, ''])
	else
		protocol.push(['create_database.php link exists', false, '\'SELECT db_name FROM available_dbs WHERE db_name="ltpda_test_'+key+'"\' returns 0 rows'])
	end
	
	mytest.logout
	
	protocol
end

# Test if deleting works
def test_delete_database(key)
	protocol = Array.new
	mytest = WebTest.new
	mytest.page = "delete_database.php?db=ltpda_test_"+key+"&confirm=true"
	
	if mytest.run then
		protocol.push(['delete_database.php delete', true, ''])
	else
		protocol.push(['delete_database.php delete', false, mytest.last_data])
	end
	
	if mytest.check_sql('SHOW DATABASES', 'ltpda_test_'+key) == 0 then
		protocol.push(['delete_database.php notfound', true, ''])
	else
		protocol.push(['delete_database.php notfound', false, '\''mytest.last_query+'\' contains "ltpda_test_'+key+'"'])
	end
	
	if mytest.check_sql('SELECT db_name FROM available_dbs WHERE db_name="ltpda_test_'+key+'"', nil) == 0 then
		protocol.push(['create_database.php link notfound', true, ''])
	else
		protocol.push(['create_database.php link notfound', false, '\''+mytest.last_query+'\' returns at least one row'])
	end
	
	mytest.logout
	
	protocol
end

def test_create_user(key)
	protocol = Array.new
	mytest = WebTest.new
	mytest.post = "username=ltpda_test_"+key+"&given_name=ltpda_test_given_"+key+"&family_name=ltpda_test_family_"+key+"&email=ltpda_test_"+key+"@example.com&telephone=+495111234567&institution=ltpda_test_AEI&save_data=Save";
	mytest.page = "create_user.php"
	
	if mytest.run then
		protocol.push(['create_user_php create', true, ''])
	else
		protocol.push(['create_user_php create', false, mytest.last_data])
	end
	
	if mytest.checksql('SELECT username FROM users WHERE username=ltpda_test_"'+key+'"')
		
end

key = generate_key()
puts 'Using key "' + key + '"'
protocol = test_create_database(key)
protocol += test_delete_database(key)
puts protocol