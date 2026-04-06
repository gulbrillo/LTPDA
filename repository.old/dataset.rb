class Dataset
  attr_accessor :data, :axis, :unit, :type
  
  def initialize
    @data = []
    @axis = ""
    @unit = ""
    @type = ""
  end
end