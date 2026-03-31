begin
  require 'fileutils'
rescue LoadError
end
require "./infofile.rb"

# Plots that don't work:
# 157? x
# export PS1='\[\033[01;31m\]\u\[\033[01;33m\]@\[\033[01;32m\]\h \[\033[01;33m\]\w \[\033[01;35m\]\$ \[\033[00m\]'

class Gnuplot
  attr_accessor :format, :path, :filename, :extension, :datasets, :x_units, :y_units,
                :gnuplot_path, :xlogscale, :ylogscale, :title, :x_range, :y_range, :force_errorbars, :t0
  
  def initialize
    @xlogscale = false
    @ylogscale = false
    @imag_column = 0
    @x_range = ""
    @y_range = ""
    @info = InfoFile.new
    @info.append = true
    @t0 = ""
  end
  
  def path=(path)
    @path = path
    unless File.directory?(@path) or FileUtils.mkdir_p(@path)
      echo "Cannot create path "+@path
    end
  end
  
  def info_file=(name)
    @info.filename = name
  end
  
  def data_file
    @path + "/" + @filename + ".dat"
  end
  
  def gnuplot_file
    @path + "/" + @filename + ".gnuplot"
  end
  
  def create_data_file
    
    outputstring = ""
    
    i = 1
    @datasets.each_value do |ds|
      puts "Axis: " + ds.axis + " has " + ds.data.count.to_s + " data points" if DEBUG
      
      # Multiply data with just one entry
      if ds.data.count == 1
        ds.data = ds.data * @datasets["y"].data.count
      end
      
      # Get column numbers
      case ds.axis
      when "x"
        @x_column = i
      when "y"
        @y_column = i
      when "z"
        @z_column = i
      when "dx"
        @dx_column = i
      when "dy"
        @dy_column = i
      when "dz"
        @dz_column = i
      when "yi"
        @imag_column = i
      end
      i += 1
    end
    
    output = File.new(data_file, "w")
    @datasets["y"].data.each_index do |i|
      line = ""
      @datasets.each_value do |ds|
        line += ds.data[i].to_s + "\t"
      end
      output.puts line.chop
    end
    
    output.close
    
  end
  
  def create_gnuplot_file
    
    count = @datasets["x"].data.count
    
    @x_range = "" if !@x_range.match(/^\[([-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?):([-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)\]$/)
    @y_range = "" if !@y_range.match(/^\[([-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?):([-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)\]$/)
    
    if count < 50
      style = "linespoints"
    else
      style = "lines"
    end
    
    puts "dy with count " + count.to_s if @datasets["dy"] if DEBUG
    
    ## Errorbar code
    #if (@datasets["dy"] and count < 200) or @force_errorbars
    #  puts "Plotting errorbars"
    #  errorbars = ", '#{data_file()}' using #{@x_column}:#{@dy_column} with errorbars notitle"
    #else
    #  errorbars = ""
    #end
    
    shorttitle = @title[0, 60]
    
    output = File.new(gnuplot_file, "w")
    
    output.puts "\#!#{@gnuplot_path}"
    output.puts "set encoding utf8"
    output.puts "set xlabel '#{@x_units}'"
    output.puts "set ylabel '#{@y_units}'"
    output.puts "set grid"
    output.puts "set title \"#{@t0}\"" unless @t0 == ""
    output.puts "set pointsize 5" if count < 5
    output.puts "unset key" if @title == ""
    output.puts "set logscale x" if @xlogscale
    output.puts "set logscale y" if @ylogscale
    output.puts "set xrange #{@x_range}" unless @x_range==""
    output.puts "set yrange #{@y_range}" unless @y_range==""
    output.puts "set terminal #{@format}"
    output.puts "set output '#{@path}/#{@filename}_main.#{@extension}'"
    output.puts "plot '#{data_file()}' using #{@x_column}:#{@y_column} with #{style} title '#{shorttitle}'"
    
    if @imag_column > 0
		  output.puts "set ylabel \"Phase\"\n"
		  output.puts "set logscale x\n" if @xlogscale
		  output.puts "unset logscale y\n"
		  output.puts "set yrange [-180:180]\n"
		  output.puts "set ytics 60\n"
		  output.puts "set mytics 2\n"
		  output.puts "f(x)=90\n"
		  output.puts "set output '#{@path}/#{@filename}_phase.#{@extension}'"
		  output.puts "plot '#{data_file()}' using #{@x_column}:#{@imag_column} with #{style} title '#{shorttitle}'"
    end
    
    output.close
  end
  
  def plot
    output = `#{@gnuplot_path} < #{gnuplot_file()} 2>&1`
    if output
      @info.add("Gnuplot-Error", output) unless output.match(/^Warning:/)
    end
    @info.save
  end
  
  def delete_temp_files
	  File.delete data_file
	  File.delete gnuplot_file
	end
end
