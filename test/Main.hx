import web.Server;
using web.RequestResponseHelper;

class HW extends web.routing.StaticRoutingMacro {

  static public function users(r: web.RequestResponse, name:String) {
    r.end(200, "user is "+name);
  }

}

class Main {

  static function main() {
    // #if php
    //   untyped __php__("var_dump($_SERVER)");
    // #end

    Server.serve(function(rr){
        rr.end(400, "serving page " + rr.path());
    }, function(rr, e, stack){
      rr.end(503, e+" "+stack);
    }, {
#if js
port : 8080
#elseif JAVA_NANOHTTPD
port : 8080
#else
#end
    });
  }
}
