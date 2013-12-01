package web;
using mw.Assertions;

class RequestResponseHelper {
  static public inline function get(rr:web.RequestResponse, name:String):String {
    return RequestResponseHelper.getOrNull(rr, name).assert_nn('get parameter ${name} expected');
  }
  static public inline function getOrNull(rr: web.RequestResponse, name:String):Null<String> {
    #if js
    return untyped __js__(urlObj.query[s]);
    #elseif php
    return untyped __php__(isset($_GET[$s]) ? $_GET[$s] : null);
    #elseif neko
    return rr.paramValues.exists(name) ? rr.paramValues.get(name) : null;
    #end
  }


  public static function path(rr:web.RequestResponse) {
  #if js
    return rr.request.url;
  #elseif php
    if (untyped __call__("isset", __var__("_SERVER", "REQUEST_URI") ))
      // If you have a project in a subdirectory REDIRECT_URL will contain 'subdir/index.php'
      // try removing removing prefix subdir/ from REQUEST_URI
      return untyped __php__("substr($_SERVER[\"REQUEST_URI\"], strlen($_SERVER[\"REDIRECT_URL\"]) - 9)");
    else
      throw '_SERVER REQUEST_URI not set, no mod rewrite?';
  #elseif neko
    return neko.Web.getURI();
  #else
    #error TODO
  #end
  }

  public static function end(rr:web.RequestResponse, status: Int, content:String, headers: Map<String,String> = null) {
    #if js
    if (headers == null){
      headers = new Map();
      headers.set('Content-Type', 'text/html');
    }
    rr.response.writeHead(200, headers);
    rr.response.end(content);
    #elseif php
    if (headers == null){
      headers = new Map();
      headers.set('Content-Type', 'text/html');
    }

    var sapi_type:String = untyped __call__("php_sapi_name");
    if (sapi_type.substring(0, 3) == 'cgi'){
        untyped __call__("header", "Status: 404 Not Found");
    } else {
        untyped __call__("header", "HTTP/1.1 404 Not Found");
    }

    for(k in headers.keys()){
      php.Web.setHeader(k, headers.get(k));
    }
    php.Lib.print(content);
    #elseif neko
      if (headers != null)
      for(k in headers.keys()){
        neko.Web.setHeader(k, headers.get(k));
      }
      neko.Lib.print(content);
    #else
    #error TODO
    #end
  }
}
