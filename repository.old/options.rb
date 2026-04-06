require 'optparse'
require './help.rb'

class Options
  attr_accessor :db_host, :db_user, :db_pass, :db_name, :db_admin_name, :obj_id,
                :gnuplot_format, :gnuplot_extension, :export_xml, :gnuplot_title,
                :gnuplot_path, :plot_path, :php_config_file, :plottype, :replot,
                :gnuplot_x_range, :gnuplot_y_range, :force_errorbars, :xml_path

  def initialize()
    # Set default values
    @db_host = "localhost"
    @db_user = "root"
    @db_pass = ""
    @db_admin_name = "ltpda_admin"
    @db_name = "ltpda_robot_test"
    @obj_id = 0
    @php_config_file = "config.inc.php"
    @plot_path = "./plots/%database%"
    @gnuplot_path = "/usr/bin/env gnuplot"
    @gnuplot_format = "png size 1024,768"
    @gnuplot_extension = "png"
    @gnuplot_title = ""
    @export_xml = false
    @plottype = ""
    @gnuplot_x_range = ""
    @gnuplot_y_range = ""
    @force_errorbars = false
    @replot = false
    @xml_path = "."
  end

  def parseCommandLineOptions(argv)
    opts = OptionParser.new do |opts|
    	opts.on("--help") do
        puts_help()
    		exit
    	end
    	opts.on("-h [HOST]", "--host [HOST]") do |host|
    		@db_host = host
    	end
    	opts.on("-u [USER]", "--user [USER]") do |user|
    		@db_user = user
    	end
    	opts.on("-p [PASS]", "--password [PASS]") do |pass|
      	@db_pass = pass
      end
      opts.on("-D [DB]", "--database [DB]") do |db|
        @db_name = db
      end
      opts.on("--admin-database [DB]") do |db|
        @db_admin_name = db
      end
      opts.on("--id [ID]") do |id|
    		@obj_id = id.to_i
    	end
    	opts.on("--export-xml") do
    		@export_xml = true
    	end
    	opts.on("--download") do
    		@plottype = "download"
    	end
    	opts.on("--title [TITLE]") do |title|
    		@gnuplot_title = title
    	end
    	opts.on("--gnuplot-format [FORMAT]") do |format|
    		@gnuplot_format = format
    	end
    	opts.on("--x-range [RANGE]") do |range|
    		@gnuplot_x_range = range
    	end
    	opts.on("--y-range [RANGE]") do |range|
    		@gnuplot_y_range = range
    	end
    	opts.on("--force-errorbars") do
    		@force_errorbars = true
    	end
    	opts.on("--xml-path [PATH]") do |path|
    		@xml_path = path
    	end
    end
    opts.parse!(argv)
  end

  def readPHPConfigFile()
    if @php_config_file == "" then @php_config_file = "config.inc.php" end
    optFile = File.open(@php_config_file)
    while !optFile.eof?
      line = optFile.gets
      match = line.match(/^\$([a-zA-Z_]*).*\"([^\"]*)\"/)
      if match != nil
        read_vars(match[1], match[2])
      end
    end
    optFile.close
  end
  
  def read_vars(var, content)
    case var
    when "mysql_host"
      @db_host = content
    when "mysql_user"
      @db_user = content
    when "mysql_pass"
      @db_pass = content
    when "mysql_database"
      @db_admin_name = content
    end
  end
  
  def readOptionsFromDatabase()
    if @plottype == "download"
      @gnuplot_format = "pdf color"
      @gnuplot_extension = "pdf"
    end
    
    plottype = "_" + @plottype unless @plottype == ""
    
    database = Mysql.connect(@db_host, @db_user, @db_pass, @db_admin_name)
    return false unless database
    
    result = database.query("SELECT name, value FROM options WHERE name LIKE 'robot%'")
    return false unless result
  
    while row = result.fetch_row
      case row[0]
      when "robot#{plottype}_gnuplot_format_string"
        @gnuplot_format = row[1]
      when "robot#{plottype}_gnuplot_extension"
        @gnuplot_extension = row[1]
      when "robot_gnuplot_path"
        @gnuplot_path = row[1]
      when "robot_plot_path"
        @plot_path = row[1]
      end
    end
    
    database.close
    
    true
  end
  
end
