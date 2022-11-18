#!/bin/bash
##修改
APP='demo'
VERSION=1.0
EMAIL='rtxbc@163.com'

#样例准备
function frame_demo(){
	mkdir include src src/include
	local file_h='#include <iostream>
#define PREFIX_NAME "'$APP'"'

	local file_cpp='#include "'$APP'.h"
int main(int argc, char **argv){
std::cout << "hello," << PREFIX_NAME << std::endl;
return 0;
}'
	echo "$file_h" >> include/$APP.h
	echo "$file_cpp" >> src/$APP.cpp
}


#智能化工具
function frame_autoscan(){
	clear
	frame_demo


	autoscan

	mv configure.scan configure.ac
	change_configure

	aclocal
	autoconf 
	autoheader

	makefile
	automake --add-missing
	automake --add-missing
	touch NEWS README  AUTHORS  ChangeLog
	automake --add-missing

	./configure
}

#Makefile.am
function makefile(){
local CURRENTPATH=`pwd`
local content='INCLUDES=-I'$CURRENTPATH'/include -I'$CURRENTPATH'/src/include 
UTOMAKE_OPTIONS=foreign
bin_PROGRAMS='$APP'
'$APP'_SOURCES=src/'$APP'.cpp '
	echo "$content" > Makefile.am
}

function change_configure(){
	sed -i "s/FULL-PACKAGE-NAME/$APP/g" configure.ac
	sed -i "s/VERSION/$VERSION/g" configure.ac
	sed -i "s/BUG-REPORT-ADDRESS/$EMAIL/g" configure.ac
	sed -i "s/AC_CONFIG_SRCDIR\(.*\)/AC_CONFIG_SRCDIR\(\[src\/$APP.cpp\]\)/" configure.ac

	#后面插入记录
	sed -i "/AC_INIT/a\AM_INIT_AUTOMAKE\($APP,$VERSION\)" configure.ac

	#前面插入记录
	sed -i "/AC_OUTPUT/i\AC_CONFIG_FILES\(\[Makefile\]\)" configure.ac
}

function usage() {
    echo "usage:sh $0 {demofile|autotools|clear}"
}

function clear(){
	for file in `ls | grep -v frame.sh`
	do
		rm -rf $file
	done
}

if [[ "$#" -ne "1" ]]; then
    usage
    exit 1
fi


case X"$1" in
    Xdemo)
        frame_demo
        ;;
    Xautotools)
        frame_autoscan
        ;;
    Xclear)
        clear
        ;;
    X*)
        usage
        ;;
esac
exit 0
