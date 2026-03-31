LTPDA Repository README and Installation Guide


  1. Quick installation guide
  2. Software requirements
  3. Requirement details
  4. Clean installation
  5. Upgrading from an older repository
  6. Configuring data plotting
  7. Additional information

While this document should cover most of the possible installation issues it is
probably not perfect. Feel free to contact me (gerrit@visscher.de).

Quick installation guide


  1. Ensure you have these packages installed (or equivalent): apache2, php,
     mysql, ruby, ruby-mysql, gnuplot
  2. To support large objects, set max_allowed_packet = 256M in my.cnf and
     memory_limit = 256M in php.ini
  3. Copy all files into the webserver directory and change the rights to fit
     the server (+write access)
  4. Run install.php from the browser


1.0 Software requirements

                                        
|Software|tested versions|should work on|
|Apache  |   2.2.6, 2.2.8|          >2.0|
|MySQL   |    5.0, 5.0.45|          >4.0|
|PHP     |   5.2.4, 5.2.6|          >4.0|
|Sendmail|         8.14.1|              |
|Ruby*   |   1.8.6, 1.8.7|        >1.8.6|
|Gnuplot*|   4.0.0, 4.4.2|        >4.0.0|

* needed for on-line plot generation and the database upgrade script

You can use postfix or qmail instead, they provide a sendmail wrapper. For more
information see http://de2.php.net/manual/en/ref.mail.php.

Browsers

                          
|Software |tested versions|
|Firefox  |     8.0, 9.0.1|
|Konqueror|          3.5.8|
|Opera    |            9.5|
|Safari   |            5.1|
|Chrome   |             16|
|Chromium |             15|


Requirement details

The robot needs ruby >1.8.6 and the mysql module for ruby. This can be
installed in two ways:

  1. via package manager: Most linux distributions bring a package like "ruby-
     mysql" (Fedora) or "libmysql-ruby" (Debian/Ubuntu)
  2. or via gem: Make sure, the "rubygems" package is installed. On a binary
     distribution, the mysql header files need to be installed. They are
     usually in a package called "libmysqlclient-dev" (Debian/Ubuntu) or
     "mysql-devel" (Fedora) The mysql gem can be installed via gem install
     mysql.

More general installation instructions can be found on the ruby download page.
If you installed the mysql support via package manager and a first run of the
script complains about missing "rubygems" you can either comment out that line
or quickly install the rubygems package.

Mac OS X 10.7 (Lion) with Homebrew

If you installed MySQL via Homebrew, you can just run "sudo gem install mysql".
The header files should be found automatically.

Mac OSX 10.6/10.7 mith manually installed MySQL-Server

If you installed MySQL via a package directly vom mysql.com, you need to supply
the mysql config to the gem installer.
sudo env ARCHFLAGS="-arch x86_64" gem install mysql -- --with-mysql-config=/
usr/local/mysql/bin/mysql_config

Clean Installation

First check that the server machine on which you want to run an LTPDA
Repository has a working apache server with properly configured PHP support
complete with the PHP MySQL modules. Also check that a MySQL server is running
and that you have the root access for the machine and the MySQL server.

Configure MySQL Server

The MySQL server should be configured (in my.cnf) to have:

* max_allowed_packet = 256M

Then restart the MySQL server by doing, for example, /etc/init.d/mysqld restart

Configuring Apache

The apache server needs to be configured (in php.ini) to have: memory_limit =
256M. You need to restart the apache server after this change.

Installing the PHP code

Installing an LTPDA Repository from scratch, then requires the following steps
(may be slightly different on different Linux distributions):

  1. Unzip the repository source files
  2. Copy all files/folders contained within the unzipped folder to the apache
     html folder. For example:
     # cp -r * /var/www/html/ltpdarepo
  3. Check that the apache server is running
  4. Change the owner of the repository files:
     # cd /var/www/html
     # chown -R apache:apache ltpdarepo
  5. Change permissions of the config file.
     # cd ltpdarepo
     # chmod a+w config.inc.php
  6. Confirm the MySQL server is running.
  7. Start the install procedure by opening a web-browser (either on the
     server, or another client machine) and enter the URL http://
     my.servermachine.com/ltpdarepo/install.php
  8. Follow the on-screen instructions
  9. After all that, delete the file install.php and change the permissions of
     config.inc.php back to # chmod 640 config.inc.php



Upgrading


  1. Make sure you have a recent backup of both the php files and all databases
  2. Copy all the files from the .zip file into your ltpdarepo directory,
     overwrite existing files (e.g. /var/www/ltpdarepo)
  3. Change the owner of the files to the webserver (e.g. chown -R www-data:
     www-data /var/www/ltpdarepo)
  4. Log in as an administrator to update the administrational database
  5. Follow the instructions shown at the bottom of the index page

Note: after updating the web-interface, you will be prompted to upgrade your 
repository databases to the new database layout using the included ruby script. 
During that process, you should take the server off-line to avoid any conflicts 
during the upgrade process (which can take several hours).


Installing the LTPDA Repository Robot

The LTPDA Repository includes an additional program which is intended to be
used for two purposes:

  1. To generate plots of data in the repository on demand (when the use clicks
     on a object in the web interface)
  2. To generate dumps of the XML data to a specified directory. This is
     intended to be run via crontab.


Setting up the on-demand plot generation

On most systems, the default configuration does not need to be changed.

  1. On the web-interface, go to "general options"
  2. Check/set the paths in the section "Repository Robot", for example:

                                                                         
     |Internal path to plot and meta files:|/var/www/html/ltpdarepo/plots|
     |External path to plot files:         |http://my.servermachine.com/ |
     |                                     |ltpdarepo/plots              |
     |Path to ltpda repo robot:            |/var/www/html/ltpdarepo/     |
     |                                     |ltpda_robot.rb               |

     (remember to click save if you make any changes)


Setting up the XML dump as a cron job

If you want to dump the xml data into a folder on your server, run
ruby ltpda_robot.rb --export-xml --xml-path /path/to/xml/folder --noplot
which will automatically dump all xml data from all databases into that folder.
You can set up a cron job to generate xml dumps and plots of the data every
night. Add this line to /etc/crontab:
* 2 * * * www-data cd /var/www/ltpdarepo; ruby ltpda_robot.rb --export-xml --
xml-path /path/to/xml/folder Modify the values to fit your system.

Additional information


Internal names

Tables and columns for the data sets must not contain any other characters than
alphanumeric, underscore (_) or a dash (-)

Custom queries

When executing a custom query, the script reconnects to the database with the
login data of the user. This prevents that the user can access or even modify
more data than he is allowed to. As the passwords are encrypted, the user has
to supply his password every time he wants to execute a query.