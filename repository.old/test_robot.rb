#!/usr/bin/env ruby
require 'rubygems'
require 'mysql'

def run_robot(id)
	system("/usr/bin/env ruby ltpda_robot.rb --id "+id.to_s)
end

def test_if_temp_files_exist
end

def test_if_plot_esists
end

db = Mysql.connect("localhost", "root", "", "ltpda_robot_test")

result = db.query("SELECT objmeta.obj_id FROM objmeta, ao WHERE objmeta.obj_type='ao' AND ao.obj_id=objmeta.obj_id AND ao.data_type!='cdata' AND ao.obj_id > 100 ORDER BY objmeta.obj_id")

puts "Found " + result.num_rows.to_s + " objects."

i = 1
while row = result.fetch_row
	puts "Plotting ID " + row[0].to_s + " (" + i.to_s + "/" + result.num_rows.to_s + ")"
	run_robot(row[0])
	i += 1
end
