begin
  require 'fileutils'
rescue LoadError
end

class AO
  attr_accessor :xml, :xunits, :yunits, :zunits, :nsecs, :type, :obj_id, :hash, :name, :t0, :toffset
  
  def initialize(database)
    @db = database
    @t0 = ""
  end
  
  # test if the object is actually an AO
  def is_ao?(id)
    result = @db.query("SELECT obj_type FROM objmeta WHERE obj_id=#{id}")
    if(row = result.fetch_row)
      return row[0].to_s == "ao"
    end
    false
  end
  
  # load an AO from the database
  def load(id)
    @obj_id = id
    
    unless is_ao?(id)
	    puts id.to_s + " is not an AO."
	    return false
	  end
    
    result = @db.query("SELECT objs.xml, objs.hash, ao.data_type, objmeta.name FROM objs, ao, objmeta WHERE objs.id=#{@obj_id} AND ao.obj_id=#{@obj_id} AND objmeta.obj_id=#{@obj_id}")
    if row = result.fetch_row then
      @xml = row[0]
      @hash = row[1]
      @type = row[2]
      @name = row[3]
    end
    
    case @type
    when "xydata"
      result = @db.query("SELECT xunits, yunits FROM xydata WHERE obj_id=#{@obj_id}")
      if(row = result.fetch_row)
        @xunits = row[0]
        @yunits = row[1]
      end
    when "fsdata"
      result = @db.query("SELECT xunits, yunits FROM fsdata WHERE obj_id=#{@obj_id}")
      if(row = result.fetch_row)
        @xunits = row[0]
        @yunits = row[1]
      end
    when "tsdata"
      result = @db.query("SELECT xunits, yunits, nsecs, DATE_SUB(t0, INTERVAL ROUND(toffset / 1000) SECOND), toffset FROM tsdata WHERE obj_id=#{@obj_id}")
      if(row = result.fetch_row)
        @xunits = row[0]
        @yunits = row[1]
        @nsecs = row[2]
        @t0 = row[3]
        @toffset = row[4]
      end
    end
    
    true
  end
  
  def save(path = ".")
	  FileUtils.mkdir_p(path) unless File.directory?(path)
    output = File.new(path + "/" + @obj_id.to_s + "_" + @hash.to_s + ".xml", "w")
    output.puts @xml
    output.close
  end
end
