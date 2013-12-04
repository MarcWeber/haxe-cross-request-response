#!/bin/sh

echo neko
haxe test-neko.hxml
echo php
haxe test-php.hxml
echo node
haxe test-nodejs.hxml

export CLASSPATH=`pwd`/java/nanohttpd/core/target/classes:`pwd`/java/nanohttpd/webserver/target/classes
haxe test-java-nanohttpd.hxml
