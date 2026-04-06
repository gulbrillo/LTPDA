def puts_help()
  help = <<EOD
Usage: ruby ltpda_robot.rb [-D <database>] [--id <obj_id>] [options]

Options
-h <host>                 
--host <host>             Hostname for the MySQL server
-u <user>                 
--user <user>             Username for the MySQL server
-p <password>             
--password <password>     Password for the MySQL server

-D <database>
--database <database>     Database in which the object is to find
--id <id>                 Object ID of the AO

--admin-database          Database of the ltpda web interface
                          Needed to plot/export all available objects

--export-xml              Export the object to an XML file
--xml-path                Path for the XML export

--gnuplot-format          Gnuplot-compatible format string
                          (e.g. "png size 1024,786" or "pdf color")
--x-range                 specify range of the x axis
--y-range                 specify range of the y axis

The robot tries to get information from the config.inc.php and the options
table of the web interface. The config file needs to be in the same directory
as the robot.
The robot takes options from
- standard values
- settingsfrom the web interface
- command line
with the latter overwriting the previous.
EOD
  puts help
end