Haxe provide cross platform web api
===================================

design notes: keep minimal. Additional supporting code shall be provided by
extra libraries

======= JS =======
dependencies nodejs-std
run: nodejs nodejs.js

======= PHP =======
Take care about .htaccess, see commented sample in test-php.hxml
run: copy/symlink php/ to PHP enabled directory

======= neko =======
run: nekotools server

======= java nano-httpd ====
1) externs created using https://github.com/Dr-Emann/java-haxe-extern-creator
2) all callbacks must be called immediately, because the serve() function in
  the Java implementation must return the site response

additional useful libaries:
github.com/MarcWeber/haxe-continuation/
github.com/MarcWeber/haxe-assertions/
