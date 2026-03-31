class InfoFile
  attr_accessor :filename
  
  def initialize
    @info = Hash.new
    @open_mode = 'w'
  end
  
  def add(name, value)
    @info[name] = value
  end
  
  def append=(append)
    if append
      @open_mode = 'a'
    else
      @open_mode = 'w'
    end
  end
  
  def save
    output = File.new(@filename, @open_mode)
    sorted_info = @info.sort_by { |name, value| name }
    sorted_info.each do |x|
      x[1].strip!
      x[1].gsub!("\n", "<br />")
      output.puts x[0].to_s + "=" + x[1].to_s
    end
    output.close
  end
end