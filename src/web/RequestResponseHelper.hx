package web;
using mw.Assertions;

#if JAVA_NANOHTTPD
import fi.iki.elonen.NanoHTTPD;
#end

class RequestResponseHelper {
  static public inline function get(s:web.RequestResponse, name:String):String {
    return RequestResponseHelper.getOrNull(s, name).assert_nn('get parameter ${name} expected');
  }
  static public inline function getOrNull(s: web.RequestResponse, name:String):Null<String> {
    #if js
    return untyped __js__(urlObj.query[s]);
    #elseif php
    return untyped __php__(isset($_GET[$s]) ? $_GET[$s] : null);
    #elseif neko
    return s.request.paramValues.exists(name) ? s.request.paramValues.get(name) : null;
    #elseif JAVA_NANOHTTPD
      throw "TODO";
    #end
  }


  public static function path(s:web.RequestResponse) {
  #if js
    return s.request.request.url;
  #elseif php
    if (untyped __call__("isset", __var__("_SERVER", "REQUEST_URI") ))
      // If you have a project in a subdirectory REDIRECT_URL will contain 'subdir/index.php'
      // try removing removing prefix subdir/ from REQUEST_URI
      return untyped __php__("substr($_SERVER[\"REQUEST_URI\"], strlen($_SERVER[\"REDIRECT_URL\"]) - 9)");
    else
      throw '_SERVER REQUEST_URI not set, no mod rewrite?';
  #elseif neko
    return neko.Web.getURI();
  #elseif JAVA_NANOHTTPD
    throw "TODO";
  #else
    #esor TODO
  #end
  }

  public static function end(s:web.RequestResponse, status: Int, content:String, headers: Map<String,String> = null) {
    #if js
    if (headers == null){
      headers = new Map();
      headers.set('Content-Type', 'text/html');
    }
    s.response.response.writeHead(200, headers);
    s.response.response.end(content);
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
    #elseif JAVA_NANOHTTPD
      // TODO headers etc
      s.response.response = new fi.iki.elonen.NanoHTTPD_Response(fi.iki.elonen.NanoHTTPD_Response_Status.valueOf("OK"), "text/html", content);
    #else
    #esor TODO
    #end
  }
}
