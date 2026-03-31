require "./infofile.rb"

class Parser
  attr_accessor :version, :datasets, :nsecs, :write_info
  
  def initialize(xml)
    @doc = REXML::Document.new(xml)
    @datasets = Hash.new
    
    @valid_types = ["fsdata", "tsdata", "xydata", "xyzdata"]
    @info = InfoFile.new
  end
  
  def info_filename=(filename)
    @info.filename = filename
  end
  
  def info_filename
    @info.filename
  end
  
  def extract_data_set
    @version = ""

    @version = @doc.root.attributes["ltpda_version"].to_s
  	
  	# TODO: do some version checks here
  	
  	@doc.elements.each("ltpda_object/object[@type='ao']/property[@prop_name='data']") do |element|
  		search_old_data(element)
  	end
  	
  	@doc.elements.each("ltpda_object/ao/data/*") do |element|
  		search_data(element)
  	end
  	
  	generate_x_axis
    @info.save if @write_info
  end
  
  def search_old_data(element)
    
    type = element.attributes["type"]
    
    possible_axis = ["x", "y", "z", "dx", "dy", "dz"]
    i = 0
    
    # Dataset for the imaginary part of y axis
    idataset = Dataset.new
    
    possible_axis.each do |axis|
      dataset = Dataset.new
      dataset.axis = axis
      @doc.elements.each("ltpda_object/object[@type='ao']/property[@prop_name='data']/object[@type='#{type}']/property[@prop_name='#{axis}']") do |dataelement|
        if dataelement.elements.count == 0 and dataelement.text.to_s != ""
          dataset.data += dataelement.text.to_s.split
        end
        
        shape = dataelement.attributes["shape"].strip
        @info.add("Shape of "+axis+" axis", shape) unless shape=="0x0" or shape=="0"
        
        dataelement.elements.each do |typeelement|
          dataset.type = typeelement.name
          typeelement.elements.each do |vectorelement|
            
            dataset.data += vectorelement.text.to_s.split if typeelement.name == "real_data"
		      	
		      	# Create a new dataset for imag_data
		      	if axis == "y" and typeelement.name == "imag_data"
		      	  idataset.axis = "yi"
		      	  idataset.type = typeelement.name
		      	  idataset.data += vectorelement.text.to_s.split
	      	  end
          end
        end
      end
      @datasets[dataset.axis] = dataset unless dataset.data.empty?
      
      @info.add("First values of " + axis + " axis", dataset.data[0, 10].join(", ")) unless dataset.data.empty?
      
      element.elements.each("property[@prop_name='nsecs']") do |nsecselement|
	      @nsecs = nsecselement.text.to_f
	    end
      
    end
    @datasets["yi"] = idataset unless idataset.data.empty?
    
  end
  
  def generate_x_axis
    # Generate missing x axis if nessecary
	  @nsecs = 0 if !@nsecs
  
		if @nsecs == 0
	    multiplier = 1
	  else
		  multiplier = 1.0 * @nsecs / @datasets["y"].data.count
	  end
    
    if !@datasets["x"]
	    @datasets["x"] = Dataset.new
	    @datasets["x"].axis = "x"
	  end
    
    if @datasets["x"].data.count == 0 # and @datasets["y"]
	    @datasets["y"].data.each_index do |i|
			  @datasets["x"].data[i] = i * multiplier
		  end
	  end
    
  end
  
  def search_data(element)
    idataset = Dataset.new
    type = element.name
    puts "New object: " + type.to_s if DEBUG
    
    return unless @valid_types.include?(type)
    
    possible_axis = ["x", "y", "z", "dx", "dy", "dz"]
    
    possible_axis.each do |axis|
    	dataset = Dataset.new
    	dataset.axis = axis
    	element.elements.each(axis) do |dataelement|
    	  shape = dataelement.attributes["shape"].strip
        @info.add("Shape of "+axis+" axis", shape) unless shape=="0x0" or shape=="0"
    	  
	    	if dataelement.elements.count == 0
      		dataset.data += dataelement.text.to_s.split
      	else
	      	dataelement.elements.each do |typeelement|
		      	dataset.type = typeelement.name
		      	typeelement.elements.each do |vectorelement|
			      	
			      	dataset.data += vectorelement.text.to_s.split if typeelement.name == "realData"
			      	
			      	# Create a new dataset for imag_data
			      	if typeelement.name == "imagData"
			      	  idataset.axis = "yi"
			      	  idataset.type = typeelement.name
			      	  idataset.data += vectorelement.text.to_s.split
		      	  end
			      end
		      end
		    end
    	end
    	@datasets[dataset.axis] = dataset unless dataset.data.empty?
    	@info.add("First values of " + axis + " axis", dataset.data[0, 10].join(", ")) unless dataset.data.empty?
    end
    
    element.elements.each("nsecs") do |dataelement|
      @nsecs = dataelement.text.to_f
    end
    
    @datasets["yi"] = idataset unless idataset.data.empty?
  end
  
end
