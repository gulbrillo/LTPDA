#/bin/bash

REPO_DIR=".."

cd $REPO_DIR
for x in *.php;
	do if [ ! "No syntax errors detected in ${x}" = "`php -l ${x}`" ];
		then echo Syntax error in ${x};
	fi;
done;