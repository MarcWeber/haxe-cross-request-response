package web;
using mw.Assertions;

#if JAVA_NANOHTTPD
import fi.iki.elonen.NanoHTTPD;
#end

typedef File = {
  name:String,
  contents: Void -> String,
  ?type: String, // supported by PHP target
  ?size: Int     // supported by PHP target
}

#if SERVER

class RequestResponseHelper {

#if !macro

  static public function referer(s:web.RequestResponse):String {
#if php
    if (untyped __call__("isset", __var__("_SERVER", "HTTP_REFERER")))
      return untyped __var__("_SERVER", "HTTP_REFERER");
    else
      return "";
#else
      TODO
#end
  }

  static public inline function get(s:web.RequestResponse, name:String):String {
    return RequestResponseHelper.getOrNull(s, name).assert_nn('get parameter ${name} expected');
  }
  static public function getOrNull(s: web.RequestResponse, name:String):Null<String> {
    #if NODE_JS
    return untyped __js__(urlObj.query[name]);
    #elseif php
    return
        ( untyped __call__("isset", __var__("_GET", name) ) )
      ? untyped __var__("_GET", name)
      : null;
    #elseif neko
    return s.request.paramValues.exists(name) ? s.request.paramValues.get(name) : null;
    #elseif JAVA_NANOHTTPD
      throw "TODO";
    #end
  }

  static public inline function post(s:web.RequestResponse, name:String):String {
    return RequestResponseHelper.postOrNull(s, name).assert_nn('post parameter ${name} expected');
  }
  static public inline function postOrNull(s: web.RequestResponse, name:String):Null<String> {
    #if NODE_JS
    TODO
    // return untyped __js__(urlObj.query[name]);
    #elseif php
    return
        ( untyped __call__("isset", __var__("_POST", name) ) )
      ? untyped __var__("_POST", name)
      : null;
    #elseif neko
      return s.request.paramValues.exists(name) ? s.request.paramValues.get(name) : null;
    // return s.request.paramValues.exists(name) ? s.request.paramValues.get(name) : null;
    #elseif JAVA_NANOHTTPD
      throw "TODO";
    #end
  }

  static public inline function file(s:web.RequestResponse, name:String):File {
    return RequestResponseHelper.fileOrNull(s, name).assert_nn('file parameter ${name} expected');
  }
  static public inline function fileOrNull(s: web.RequestResponse, name:String):Null<File> {
    #if NODE_JS
    TODO
    // return untyped __js__(urlObj.query[name]);
    #elseif php
    if ( untyped __call__("isset", __var__("_FILES", name))){
      var f = untyped __var__("_FILES", name);
      if (f == null || (untyped __call__('empty', __var__(f, "name")))){
        return null;
      }
      return {
        name: untyped __var__(f, "name"),
        type: untyped __var__(f, "type"),
        size: untyped __var__(f, "size"),
        contents: function(){ return sys.io.File.getContent(untyped __var__(f, "tmp_name")); }
      };
    } else {
      return null;
    }
    #elseif neko
      throw "TODO";
    // return s.request.paramValues.exists(name) ? s.request.paramValues.get(name) : null;
    #elseif JAVA_NANOHTTPD
      throw "TODO";
    #end
  }

  // without get paramaters
  public static function domain_and_path(s:web.RequestResponse):String {
  #if NODE_JS
    not implemented yet
  #elseif php
    // return untyped __php__("preg_replace('/http(s)?:\\/\\//', '', $_SERVER['REDIRECT_SCRIPT_URI'])");
    return untyped __var__("_SERVER", "HTTP_HOST")+""+
           __call__("preg_replace", '/\\?[^?]*$/','', __var__("_SERVER", "REQUEST_URI"));

    if (untyped __call__("isset", __var__("_SERVER", "REQUEST_URI") ))
      // If you have a project in a subdirectory REDIRECT_URL will contain 'subdir/index.php'
      // try removing removing prefix subdir/ from REQUEST_URI
      return untyped __php__("substr($_SERVER[\"REQUEST_URI\"], strlen($_SERVER[\"REDIRECT_URL\"]) - 9)");
    else
      throw '_SERVER REQUEST_URI not set, no mod rewrite?';
  #elseif neko
    return neko.Web.getHostName()+neko.Web.getURI();
  #elseif JAVA_NANOHTTPD
    not implemented yet
  #else
    TODO
  #end
  }

  // without domain / without protocol
  public static function path(s:web.RequestResponse):String {
  #if NODE_JS
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

  // use macro function to validate code?
  public static function end_redirect(s:web.RequestResponse, code:Int, url:String, close:Bool = false) {
  var msg = switch (code) {
    case 301: "Moved Permantenly";
    case 302: "Moved Temporarily";
    case _: throw "unexpected";
  }
  #if php
    untyped __call__("header", 'HTTP/1.1 ${code} ${msg}');
    untyped __call__("header", 'location: ${url}');
    if (close)
      untyped __call__("header", "Connection: close");
  #elseif neko
    // no idea how to pass code, looks like neko is using 302
    neko.Web.redirect(url);
  #else
      throw "TODO";
  #end
  }


  public static function end(s:web.RequestResponse, status: Int, content:String, headers: Map<String,String> = null) {
    #if NODE_JS
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

    if (status == 404) {
      if (sapi_type.substring(0, 3) == 'cgi'){
          untyped __call__("header", "Status: 404 Not Found");
      } else {
          untyped __call__("header", "HTTP/1.1 404 Not Found");
      }
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
#end
}

#end
