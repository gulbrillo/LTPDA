#!/usr/bin/ruby

# Database ltpda_large, ID 258, 2

require 'rubygems'
begin
  require 'mysql'
rescue
  puts "The robot needs MySQL support for Ruby."
  exit(1)
end
require 'rexml/document'

begin
  require 'fileutils'
rescue LoadError
end


require './parser.rb'
require './options.rb'
require './ao.rb'
require './gnuplot.rb'
require './dataset.rb'
require './error.rb'
require './functions.rb'

@starttime = Time.now

DEBUG = true

@options = Options.new() # found in functions.rb
@options.parseCommandLineOptions(ARGV.dup)
puts "Gnuplot-Config: " + @options.gnuplot_format + " in ."+@options.gnuplot_extension if DEBUG
@options.readPHPConfigFile()
@options.readOptionsFromDatabase()
@options.parseCommandLineOptions(ARGV)
puts "Gnuplot-Config: " + @options.gnuplot_format + " in ."+@options.gnuplot_extension if DEBUG

@error = Error.new

@db = Mysql::real_connect(@options.db_host, @options.db_user, @options.db_pass, @options.db_name)

path = @options.plot_path.gsub("%database%", @options.db_name)
unless File.directory?(path) or FileUtils.mkdir_p(path)
  echo "Cannot create path "+path
end

def plotObj(id = 0)
  
  id = @options.obj_id if id==0
  
  puts "Plotting ID "+id.to_s
  
  ao = AO.new(@db)
  
  unless ao.load(id)
    @error.write "Could not load Object with ID " + @options.obj_id.to_s
    exit(1)
  end

  ao.save() if @options.export_xml

  if ao.type == "cdata" then
    puts "Object is of type cdata, not plotting." if DEBUG
    exit(2)
  end

  id_string = ao.obj_id.to_s
  while(id_string.length<6)
    id_string = "0" + id_string;
  end
  
  infofile = @options.plot_path.gsub("%database%", @options.db_name) + "/" + @options.db_name + "_" + id_string + "_" + ao.hash + ".txt"

  puts "before parsing " + (Time.now - @starttime).to_s if DEBUG
  parser = Parser.new(ao.xml)
  parser.write_info = true
  parser.info_filename = infofile
  puts "Filename: " + parser.info_filename.to_s if DEBUG
  puts "parser loaded " + (Time.now - @starttime).to_s if DEBUG

  if ao.type == "fsdata"
  	parser.nsecs = ao.nsecs
  end

  parser.extract_data_set
  puts "data extracted " + (Time.now - @starttime).to_s if DEBUG

  #puts parser.version

  if DEBUG
  	puts "Units: " + ao.xunits.to_s + " . " + ao.yunits.to_s
  	puts "Size: " + ao.xml.length.to_s
  	puts "Name: " + ao.name
  	puts "Format: " + @options.gnuplot_format
  end

  puts "Creating gnuplot object " + (Time.now - @starttime).to_s if DEBUG
  gnuplot = Gnuplot.new
  gnuplot.format = @options.gnuplot_format
  gnuplot.title = @options.gnuplot_title
  gnuplot.datasets = parser.datasets
  gnuplot.x_units = ao.xunits
  gnuplot.y_units = ao.yunits
  gnuplot.t0 = ao.t0
  gnuplot.path = @options.plot_path.gsub("%database%", @options.db_name)
  gnuplot.gnuplot_path = @options.gnuplot_path
  gnuplot.extension = @options.gnuplot_extension
  gnuplot.filename = @options.db_name + "_" + id_string + "_" + ao.hash
  gnuplot.x_range = @options.gnuplot_x_range
  gnuplot.y_range = @options.gnuplot_y_range
  gnuplot.info_file = infofile
  #gnuplot.force_errorbars = @options.force_errorbars

  if ao.type == "fsdata"
    gnuplot.xlogscale = true
    gnuplot.ylogscale = true
  end

  puts "Creating gnuplot files " + (Time.now - @starttime).to_s if DEBUG
  gnuplot.create_data_file
  gnuplot.create_gnuplot_file

  puts "Plotting " + (Time.now - @starttime).to_s if DEBUG
  gnuplot.plot

  gnuplot.delete_temp_files
end

plotObj()

puts "End. " + (Time.now - @starttime).to_s if DEBUG