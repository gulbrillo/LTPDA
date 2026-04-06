#!/usr/bin/env ruby

require 'rubygems'
require 'mysql'
require 'yaml'
require 'optparse'
require 'digest/md5'

@mysql_host = "localhost"
@mysql_user = "root"
@mysql_pass = ""
@mysql_db = "ltpda_robot_test"
@ask_for_password = false
@save_id = 0
@load_file = ""

ID = 114
BASE_FILENAME = "OBJ"

opts = OptionParser.new do |opts|
	opts.on("--help") do
	  puts "Export/import objects to or from a file.
Usage: ruby copy_object.rb -d <database> [options]\n
 -d <database>      Database name
 --save <id>        Exports object with this id to a file
 --load <filename>  Imports an object from a file
 -u <name>          User for the MySQL connection (default: root)
 -p [password]      Password for the MySQL connection
	                                          (default: no password)
 -h <hostname>      MySQL host (default: localhost)
          
You need to supply either --save or --load."
  end
  opts.on("-d [DATABASE]") do |database|
    @mysql_db = database
  end
  opts.on("-u USER") do |user|
    @mysql_user = user
  end
  opts.on("-p [PASS]") do |pass|
    @mysql_pass = pass
    @ask_for_password = true if pass == ""
  end
  opts.on("-h [HOST]") do |host|
    @mysql_host = host
  end
  opts.on("--save [ID]") do |id|
    @save_id = id.to_i
  end
  opts.on("--load [FILE]") do |file|
    @load_file = file
  end
  opts.parse(ARGV)
end

@db = Mysql.new(@mysql_host, @mysql_user, @mysql_pass, @mysql_db)

def exportObj(id)
  result = @db.query("SELECT xml, hash FROM objs WHERE id=#{id}")
  tables = Hash.new
  while(row = result.fetch_row)
    xmloutput = File.new(id.to_s + "_object.xml", 'w')
    xmloutput.puts row[0]
    xmloutput.close
    objs = Hash.new
    objs["hash"] = row[1]
  end
  
  meta_tables = ["objmeta", "ao", "fsdata", "tsdata", "xydata", "cdata", "mfir", "miir"]
  
  meta_tables.each do |table|
    result = @db.query("SELECT * FROM #{table} WHERE obj_id=#{id}")
    tables[table] = result.fetch_hash
  end
  
  yamldump = YAML.dump(tables)
  output = File.new(id.to_s+"_object.yaml", 'w')
  output.puts yamldump
  output.close
end

def importObj(filename)
  xmlfile = File.new(filename+".xml", 'r')
  xml = xmlfile.read.chomp
  xmlfile.close
  
  digest = Digest::MD5.hexdigest(xml)
  
  xml = @db.escape_string(xml)
  @db.query("INSERT INTO objs (xml, hash) VALUES ('#{xml}', '#{digest}')")
  
  
  result = @db.query("SELECT LAST_INSERT_ID()")
  obj_id = result.fetch_row[0]
  
  puts "New object id: " + obj_id
  
  tables = YAML.load(File.open(filename+".yaml"))
  
  tables.each do |table|
    if table[1]
      query = "INSERT INTO #{table[0]} "
      fields = "("
      content = "("
      
      # get table meta info (field info)
      result = @db.query("DESCRIBE #{table[0]}")
      fieldmeta = []
      while row = result.fetch_row
        fields += row[0] + ", "
        if row[0]=="obj_id"
          content += obj_id.to_s + ", "
        else
          if row[1].downcase.start_with?("int") or row[1].downcase.start_with?("float")
            content += table[1][row[0]] + ", "
          else
            content += "'" + @db.escape_string(table[1][row[0]].to_s) + "', "
          end
        end
      end
      fields = fields.chop.chop + ")"
      content = content.chop.chop + ")"
      
      query = query + fields + " VALUES " + content
      @db.query(query)
      
    end
  end
end

if @save_id > 0
  exportObj(@save_id)
end

if @load_file != "" and File::exists?(@load_file)
  if @load_file.end_with? ".xml"
    @load_file = @load_file[0, @load_file.length - 4]
  elsif @load_file.end_with? ".yaml"
    @load_file = @load_file[0, @load_file.length - 5]
  end
  importObj(@load_file)
end


