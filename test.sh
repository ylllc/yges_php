#!/bin/bash

# † Simple Test Runner for PHP †
# Copyright © 2024 Yggdrasil Leaves, LLC.
# https://github.com/ylllc/yges_php

# The work directory always this place. 
cd $(dirname $0)
ROOTDIR=$PWD

# Log directory.
LOGDIR=log

# Become 1 if failed.
EXITCODE=0

# running target directory 
BASEDIR=$1
if [ -z "$BASEDIR" ]; then
	BASEDIR='test'
else
	BASEDIR="test/$BASEDIR"
fi

# Reject illegal basedir 
if [[ ${BASEDIR:0:1} = '/' ]]; then
	echo "* Illegal BASEDIR"
	exit 1
fi
if [[ $BASEDIR =~ \.\. ]]; then
	echo "* Illegal BASEDIR"
	exit 1
fi

# Prepare log directory.
if ! [ -d "$LOGDIR" ]; then
	mkdir "$LOGDIR"
fi

# Test a scenario. 
test_one () {

	# py local path.
	PHPNAME=$1
	if [ ${PHPNAME:0:2} = './' ]; then
		PHPNAME=${PHPNAME:2}
	fi

	# Log path.
	DATE=`date +%Y%m%d-%H%M%S`
	PATH2=`echo $PHPNAME | sed -e 's/\//~/g'`
	LOGFILE="${DATE}_${PATH2%.*}.log"
	LOGPATH="$ROOTDIR/$LOGDIR/$LOGFILE"

	# Test settings.
	TEST_WILL_EXIT_WITH=0

	# Work directory and binary path.
	WORKDIR="$ROOTDIR/$(dirname $PHPNAME)"
	PHPFILE=$(basename $PHPNAME)

	# Config file 
	CFGFILE="$WORKDIR/${PHPFILE%.*}.cfg"
	if [ -f $CFGFILE ]; then
		source $CFGFILE
	fi

	# Execute and result.
	php "$WORKDIR/$PHPFILE" > "$LOGPATH"
	RESULT=$?

	# Remove empty log file.
	LOGSIZE=`wc -c "$LOGPATH" | cut -d' ' -f1`
	if [ $LOGSIZE = 0 ]; then
		rm "$LOGPATH"
	fi

	if [ "$RESULT" != "$TEST_WILL_EXIT_WITH" ]; then
		EXITCODE=1

		if [ -f "$LOGPATH" ]; then
			LOGINFO="see $LOGFILE"
		else
			LOGINFO="no logfile"
		fi

		# Bad end in a scenario.
		echo "* [FAILED] $PHPNAME exited as $RESULT ($LOGINFO)"
		echo "*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*"
	fi
}

# Find all scenaria in the base directory 
# And run them.
test_all () {

	while read pyfile
	do
		test_one "$pyfile"
	done <<< $(find "$BASEDIR" -name '*.php')
}

# BASEDIR is required
if ! [ -d $BASEDIR ]; then
	echo "* $BASEDIR not found"
	EXITCODE=1
else
	test_all
fi

# Good end in all scenaria.
if [ $EXITCODE -eq 0 ]; then
	echo "* Test all OK in $BASEDIR"
fi

exit $EXITCODE
