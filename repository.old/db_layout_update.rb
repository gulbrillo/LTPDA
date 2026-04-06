#!/usr/bin/ruby

# switch this to d to automatically answer all questions with "delete"
# DO NOT USE THIS ON THE PRODUCTION MACHINE
DEFAULT_ANSWER = ""

DEBUG = false

require 'rubygems'
require 'mysql'

# Read config from php config file
mysql_host = ""
mysql_db = ""
mysql_user = "root"
mysql_pass = ""
mysql_config_user = ""

begin
  configFile = File.new("config.inc.php", "r")
  while !configFile.eof?
    line = configFile.gets
    if a = line.match(/^\$([a-z_]+)[ ]+=[ ]+"([^"]+)"/)
      if a[1] == "mysql_host"
        mysql_host = a[2]
      end
      if a[1] == "mysql_user"
        mysql_config_user = a[2]
      end
      if a[1] == "mysql_password"
        mysql_pass = a[2]
      end
      if a[1] == "mysql_database"
        mysql_db = a[2]
      end
    end
  end
rescue => err
  puts "Notice: Could not read config file."
end

# ask for missing information
if mysql_host == ""
  print "Please enter MySQL host [localhost]: "
	mysql_host = $stdin.gets.chomp
	print "\n"
end

if mysql_db == ""
  print "Please the database of the ltpda web interface [ltpda_admin]: "
	mysql_db = $stdin.gets.chomp
	print "\n"
end

if mysql_config_user == ""
  print "Which user does the web interface use to connect to the database: "
	mysql_config_user = $stdin.gets.chomp
	print "\n"
end

if mysql_pass == "" or mysql_user != "root"
  begin
		system "stty -echo"
		print "Please enter MySQL root password: "
		mysql_pass = $stdin.gets.chomp
		print "\n"
	ensure
		system "stty echo"
	end
end

if mysql_host=="" then mysql_host = "localhost" end
if mysql_db=="" then mysql_db = "ltpda_admin" end
if mysql_config_user=="" then mysql_db = "ltpda_admin" end

$errors = 0

$db = Mysql.real_connect(mysql_host, mysql_user, mysql_pass, mysql_db)

def update(database, admin_db)
  queryexec("USE "+database)
  
  return unless is_old_layout?
  
  all_tables_utf8
  update_bobjs
  update_objmeta
  update_miir_mfir("miir")
  update_miir_mfir("mfir")
  update_data_tables("xydata")
  update_data_tables("fsdata")
  update_data_tables("tsdata")
  update_data_tables("cdata")
  update_ao
  switch_users_to_view(admin_db)
  switch_to_innodb
  update_collections
  
  add_foreign_keys
end
  
def all_tables_utf8()
  tables = queryexec("SHOW TABLES")
  while(table_row = tables.fetch_row)
    table = table_row[0]
    columns = queryexec("SHOW FULL COLUMNS FROM #{table}")
    
    while(col_row = columns.fetch_hash)
      column = col_row["Field"]
      type = col_row["Type"]
      comment = col_row["Comment"]
      
      if type.downcase=="text" then
        queryexec("ALTER TABLE #{table} MODIFY #{column} TEXT CHARACTER SET utf8 COMMENT '#{comment}'")
      end
      
    end
  end  
end

def set_strict_mode
  queryexec("SET GLOBAL sql_mode='STRICT_TRANS_TABLES'")
end

def update_bobjs
  result = queryexec("DESCRIBE bobjs")
  while row = result.fetch_row
    if row[0] == "id" then
      queryexec("ALTER TABLE bobjs DROP COLUMN id")
    end
  end
  
  queryexec("ALTER TABLE bobjs MODIFY obj_id INT(11) UNSIGNED NOT NULL COMMENT 'Object ID'")
  queryexec("ALTER TABLE bobjs ADD PRIMARY KEY (obj_id)")
  queryexec("ALTER TABLE bobjs DROP INDEX object_index")
end

def update_objmeta
  queryexec("ALTER TABLE objmeta DROP COLUMN id")
  queryexec("ALTER TABLE objmeta MODIFY obj_id INT(11) UNSIGNED NOT NULL COMMENT 'Object ID'")
  queryexec("ALTER TABLE objmeta ADD PRIMARY KEY (obj_id)")
  queryexec("ALTER TABLE objmeta MODIFY obj_type ENUM('ao', 'collection', 'filterbank', 'matrix', 'mfir', 'miir', 'parfrac', 'pest', 'plist', 'pzmodel', 'rational', 'smodel', 'ssm', 'timespan') NOT NULL")
  queryexec("ALTER TABLE objmeta ADD KEY (`submitted`)")
end

def update_ao
  queryexec("ALTER TABLE ao DROP COLUMN id")
  queryexec("ALTER TABLE ao MODIFY obj_id INT(11) UNSIGNED NOT NULL COMMENT 'Object ID'")
  queryexec("ALTER TABLE ao ADD PRIMARY KEY (obj_id)")
  queryexec("ALTER TABLE ao DROP COLUMN mfilename")
  queryexec("ALTER TABLE ao DROP COLUMN mdlfilename")
  queryexec("ALTER TABLE ao MODIFY data_type ENUM('cdata', 'tsdata', 'fsdata', 'xydata', 'xyzdata') NOT NULL")
  queryexec("ALTER TABLE ao DROP COLUMN data_id")
end

def update_miir_mfir(table)
  queryexec("ALTER TABLE #{table} DROP COLUMN id")
  queryexec("ALTER TABLE #{table} CHANGE obj_id obj_id INT(11) unsigned NOT NULL COMMENT 'Object ID'")
  queryexec("ALTER TABLE #{table} ADD PRIMARY KEY (obj_id)")
  #queryexec("ALTER TABLE #{table} ADD UNIQUE (obj_id)")
end

def update_data_tables(table)
  queryexec("ALTER TABLE #{table} ADD COLUMN obj_id INT(11) UNSIGNED NOT NULL COMMENT 'Object ID' FIRST")
  queryexec("UPDATE #{table}, ao SET #{table}.obj_id = ao.obj_id WHERE #{table}.id = ao.data_id AND ao.data_type = '#{table}'")
  #queryexec("ALTER TABLE #{table} ADD UNIQUE (obj_id)")
  queryexec("ALTER TABLE #{table} DROP COLUMN id")
  queryexec("ALTER TABLE #{table} ADD PRIMARY KEY (obj_id)")
  
  if table == "tsdata" then
    queryexec("ALTER TABLE tsdata ADD COLUMN toffset BIGINT(20) NOT NULL DEFAULT 0")
  end
  
  if table == "cdata" then
    queryexec("ALTER TABLE cdata DROP COLUMN xunits")
  end
end


def update_collections
  
  create_table_query = <<EOD
CREATE TABLE `collections2objs` (
  `id` int unsigned NOT NULL,
  `obj_id` int unsigned NOT NULL,
  PRIMARY KEY (`id`, `obj_id`),
  FOREIGN KEY (`id`) REFERENCES `collections` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`obj_id`) REFERENCES `objs` (`id`) ON DELETE CASCADE,
  INDEX (`id`),
  INDEX (`obj_id`)
) ENGINE=InnoDB;
EOD
  
  queryexec(create_table_query)
  
  result = queryexec("SELECT id, obj_ids FROM `collections`")
  while row = result.fetch_row
    collection_id = row[0]
    obj_ids = row[1].split(",")
    obj_ids.each do |id|
      queryexec("INSERT INTO `collections2objs` (id, obj_id) VALUES (#{collection_id}, #{id})") unless id.to_i == 0
    end
  end
  
  queryexec("ALTER TABLE `collections` DROP COLUMN `nobjs`")
  queryexec("ALTER TABLE `collections` DROP COLUMN `obj_ids`")
end

def switch_users_to_view(admin_db)
  queryexec("DROP TABLE IF EXISTS `users`")
  queryexec("CREATE VIEW `users` AS SELECT id, username FROM `#{admin_db}`.users")
end

def switch_to_innodb()
  tables = queryexec("SHOW TABLES")
  
  while(row = tables.fetch_row)
    table = row[0]
    
    queryexec("ALTER TABLE #{table} ENGINE = InnoDB") unless table == "users"
    
  end
  
  queryexec("SET GLOBAL sql_mode='STRICT_TRANS_TABLES'")
end

def has_foreign_key?(table)
  database = current_db()
  result = queryexec("SELECT constraint_name
             FROM information_schema.key_column_usage
             WHERE referenced_table_name IS NOT NULL AND
                      constraint_schema='#{database}' AND table_name='#{table}' AND column_name='obj_id'
             ORDER BY constraint_name")
  return result.num_rows > 0;
end

def foreign_keys(table)
  database = current_db()
  result = queryexec("SELECT constraint_name
             FROM information_schema.key_column_usage
             WHERE referenced_table_name IS NOT NULL AND
                      constraint_schema='#{database}' AND table_name='#{table}' AND column_name='obj_id'
             ORDER BY constraint_name")
  keys = []
  while row = result.fetch_row
    keys << row[0]
  end
  
  return keys;
end

def add_foreign_keys
  # Generate table list
  table_result = queryexec("SHOW TABLES")
  tables = []
  table_result.each do |row|
    tables << row[0]
  end
  
  # some tables don't have an object id or don't need to be linked
  tables = tables - ["transactions", "objs", "users", "collections"]
  
  # ensure all 
  # drop possibly already existing foreign keys
  tables.each do |table|
    #result = queryexec("DESCRIBE #{table}")
    #while row = result.fetch_hash
    #  puts "Table: " + table + ", Null: " + row['Null'] if row['Field'] == "obj_id"
    #  if row['Field'] == "obj_id" and row['Null'].downcase == "yes" then
    #    puts "Switching obj_id in table #{table} to NOT NULL."
    #    queryexec("ALTER TABLE #{table} CHANGE obj_id obj_id INT(11) unsigned NOT NULL COMMENT 'Object ID'")
    #  end
    #end
    
    if has_foreign_key?(table)
      keys = foreign_keys(table)
      keys.each do |k|
        queryexec("ALTER TABLE #{table} DROP FOREIGN KEY #{k}")
      end
    end
    
    queryexec("ALTER TABLE #{table} ADD FOREIGN KEY (obj_id) REFERENCES objs(id) ON DELETE CASCADE")
  end
end

def current_db
  cur_db_result = $db.query("SELECT DATABASE()")
  cur_db_result.fetch_row[0]
end

def queryexec(sql)
  puts sql if DEBUG
  
  begin
    result = $db.query(sql)
  rescue Mysql::Error => e
    puts "Rescuing..."
    puts "Current Database: " + current_db()
    puts "Error in query: " + sql
    puts $db.error
    puts e.message
    puts "---"
    
    $errors += 1
  end
  
  result
end

def is_old_layout?
  old_layout = false
  result = queryexec("DESCRIBE ao")
  while row = result.fetch_row
    field = row[0]
    if field == "data_type" then
      old_layout = true
    end
  end
  
  old_layout
end

def update_available_databases(admin_db)
  queryexec("USE "+admin_db)
  has_version_field = false
  result = queryexec("DESCRIBE available_dbs")
  while row = result.fetch_row
    if row[0] == "version"
      has_version_field = true
    end
  end
  
  if !has_version_field
    queryexec("ALTER TABLE `available_dbs` ADD COLUMN `version` INT DEFAULT 1
               COMMENT 'version of the database layout'")
  end
end

def update_version(database, admin_db)
  queryexec("USE " + admin_db)
  queryexec("UPDATE available_dbs SET version=2 WHERE db_name='#{database}'")
end

def check_multiple_obj_ids
  # test if obj_id=0 exist
  tables = ["bobjs", "objmeta", "ao", "miir", "mfir"]
  tables.each do |table|
    result = queryexec("SELECT obj_id, COUNT(id) as cnt FROM #{table} GROUP BY obj_id HAVING cnt > 1")
    while row = result.fetch_row
      puts "Table #{table}: obj_id " + row[0].to_s + " in not unique (" + row[1].to_s + " times)"
      
      answer = DEFAULT_ANSWER
      while answer!="d" and answer!="s"
        print "[D]elete all but one or [S]kip (and repair manually)? "
  		  answer = $stdin.gets.chomp.downcase
      end
      
      if answer == "d"
		    queryexec("DELETE FROM #{table} WHERE obj_id="+row[0].to_s+" LIMIT " + (row[1].to_i - 1).to_s)
      elsif answer == "s"
        $errors += 1
      end
      
    end
  end
end

def check_obj_id_null
  tables = ["bobjs", "objmeta", "ao", "miir", "mfir"]
  tables.each do |table|
    result = queryexec("SELECT COUNT(*) FROM #{table} WHERE obj_id=0")
    count = result.fetch_row[0].to_i
    if count > 0 then
      puts "Table #{table}: found #{count} entries with obj_id = 0"
      
      # repair?
      answer = DEFAULT_ANSWER
      while answer!="d" and answer!="s"
        print "[D]elete or [S]kip (and repair manually)? "
  		  answer = $stdin.gets.chomp.downcase
      end
      
      if answer == "d"
		    queryexec("DELETE FROM #{table} WHERE obj_id=0")
      elsif answer == "s"
        $errors += 1
      end
      
    end
    
  end
end

def check_orphaned_data
  tables = ["tsdata", "cdata", "fsdata", "xydata"]
  tables.each do |table|
    result = queryexec("SELECT COUNT(*) FROM #{table} WHERE id NOT IN (SELECT data_id
                        FROM ao WHERE data_type='#{table}')")
    count = result.fetch_row[0].to_i
    if count > 0 then
      puts "Found #{count} orphaned entries in table #{table}."
      
      answer = DEFAULT_ANSWER
      while answer!="d" and answer!="s"
        print "[D]elete or [S]kip (and repair manually)? "
  		  answer = $stdin.gets.chomp.downcase
      end
      
      if answer == "d"
		    queryexec("DELETE FROM #{table} WHERE id NOT IN (SELECT data_id FROM ao WHERE data_type='#{table}')")
      elsif answer == "s"
        $errors += 1
      end
      
    end
  end
end

def check_unknown_data_type
  result = queryexec("SELECT obj_id, data_type FROM ao WHERE data_type NOT IN ('tsdata',
                      'fsdata', 'xydata', 'xyzdata', 'cdata')")
  answer = DEFAULT_ANSWER
  while row = result.fetch_row
    puts "Object with id " + row[0].to_s + " has an unknown data type: '" + row[1].to_s + "'"
    
    # reset answer, if not for all entries
    if answer != "a" then answer = DEFAULT_ANSWER end
    
    # get new answer if nessecary
    while answer!="d" and answer!="s" and answer!="a"
      print "[D]elete, delete [A]ll or [S]kip (and repair manually)? "
		  answer = $stdin.gets.chomp.downcase
    end
    
    # delete row or skip
    if answer == "d" or answer == "a" then
	    queryexec("DELETE FROM ao WHERE obj_id=#{row[0]}")
    elsif answer == "s" then
      $errors += 1
    end
    
  end
end

def check_unknown_obj_type
  result = queryexec("SELECT obj_id, obj_type, id FROM objmeta WHERE obj_type NOT IN
                      ('ao', 'collection', 'filterbank', 'matrix', 'mfir', 'miir',
                      'parfrac', 'pest', 'plist', 'pzmodel', 'rational', 'smodel', 'ssm', 'timespan')")
  answer = DEFAULT_ANSWER
  while row = result.fetch_row
    puts "Object with id " + row[0].to_s + " has an unknown object type: '" + row[1].to_s + "'"
    
    # reset answer, if not for all entries
    if answer != "a" then answer = DEFAULT_ANSWER end
    
    # get new answer if nessecary
    while answer!="d" and answer!="s" and answer!="a"
      print "[D]elete, delete [A]ll or [S]kip (and repair manually)? "
		  answer = $stdin.gets.chomp.downcase
    end
    
    # delete row or skip
    if answer == "d" or answer == "a" then
	    queryexec("DELETE FROM objmeta WHERE id=#{row[2]}")
    elsif answer == "s" then
      $errors += 1
    end
    
  end
end

def check_orphaned_objects
  tables = ["bobjs", "objmeta", "ao", "miir", "mfir"]
  tables.each do |table|
    result = queryexec("SELECT COUNT(*) FROM #{table} WHERE obj_id NOT IN (SELECT id FROM objs)")
    count = result.fetch_row[0].to_i
    if count > 0 then
      puts "Table #{table}: found #{count} entries with orphaned obj_id"
      
      # repair?
      answer = DEFAULT_ANSWER
      while answer!="d" and answer!="s"
        print "[D]elete or [S]kip (and repair manually)? "
  		  answer = $stdin.gets.chomp.downcase
      end
      
      if answer == "d"
		    queryexec("DELETE FROM #{table} WHERE obj_id NOT IN (SELECT id FROM objs)")
      elsif answer == "s"
        $errors += 1
      end
      
    end
    
  end
end

def update_ltpda_admin_rights(user)
  if user!="" and user!="root"
    queryexec("GRANT CREATE VIEW ON *.* TO '#{user}'@'localhost'")
  end
end

### Begin of the script ###

# Ask if backup exists
puts "This script will irreversibly change the layout of all ltpda databases. "+
     "It is strongly recommended to make a backup first."
print "Type 'YES' to continue: "
answer = $stdin.gets.chomp
if answer != "YES" then exit(0) end

dbs_passed = []

update_ltpda_admin_rights(mysql_config_user)

# If an argument (the database to convert) is given, just select this one
if ARGV[0] != nil
  puts "SELECT '#{ARGV[0]}'"
  db_result = queryexec("SELECT '#{ARGV[0]}'")
else
  admin_db = mysql_db
  update_available_databases(admin_db)
  # first: test databases
  db_result = queryexec("SELECT db_name FROM available_dbs WHERE version=1")
end

while row = db_result.fetch_row
  $errors = 0
  puts "Checking " + row[0] + "..."
  queryexec("USE " + row[0])
  
  check_multiple_obj_ids
  check_obj_id_null
  check_orphaned_data
  check_orphaned_objects
  check_unknown_data_type
  check_unknown_obj_type
  
  if $errors == 0 then dbs_passed << row[0] end
end

# then: convert
if !ARGV[0] then queryexec("USE "+admin_db) end
dbs_passed.each do |database|
  $errors = 0
  puts "Updating " + database + "..."
  update(database, admin_db)
  if !ARGV[0]
    if $errors == 0 then
      update_version(database, admin_db)
    else
      puts "There where errors during the update process. Version number not updated."
    end
  end
  
end

set_strict_mode

