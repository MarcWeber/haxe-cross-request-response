package web;
import haxe.CallStack;

#if JAVA_NANOHTTPD
import fi.iki.elonen.NanoHTTPD;
#end

typedef ServerOptions = {
#if (js || JAVA_NANOHTTPD)
  port: Int
#end
}

#if JAVA_NANOHTTPD
class NanoHTTPDHx extends NanoHTTPD {

  public var process: web.RequestResponse -> Void;
  public var onError: web.RequestResponse -> Dynamic -> Array<haxe.StackItem> -> Void;

  public function new(port:Int, process, onError) {
    super(port);
    this.process  = process;
    this.onError = onError;
  }

  override public function serve(
      uri:String,
      method:fi.iki.elonen.NanoHTTPD_Method,
      headers:java.util.Map<String,
      String>,
      parms:java.util.Map<String,
      String>,
      files:java.util.Map<String,
      String>
  )
  :fi.iki.elonen.NanoHTTPD_Response 
  {
    var rr = new RequestResponse(this.onError);
    this.process(rr);
    return rr.response;
  }

}
#end

class Server {

  static public function serve(
      process: web.RequestResponse -> Void,
      onError: web.RequestResponse -> Dynamic -> Array<haxe.StackItem> -> Void,
      options: ServerOptions
  ) {
  #if js
    js.Node.http.createServer(function(request, response){
      var rr = new RequestResponse(onError, request, response);
      try{
        process(rr);
      }catch(e:Dynamic){
        rr.onError(rr, e, CallStack.exceptionStack() );
      }
    }).listen(options.port);
  #elseif (php || neko)
    var rr = new RequestResponse(onError);
    try{
      process(rr);
    }catch(e:Dynamic){
      rr.onError(rr, e, haxe.CallStack.exceptionStack() );
    }
  #elseif JAVA_NANOHTTPD
    var server = new NanoHTTPDHx(options.port, function(rr){
      try{
        process(rr);
      }catch(e:Dynamic){
        rr.onError(rr, e, CallStack.exceptionStack() );
      }
    }, onError);
    try{
      trace("running");
      fi.iki.elonen.ServerRunner.executeInstance(server);
      trace("done running");
    }catch(e:Dynamic){
      trace(e);
    }
  #else
    #error TODO
  #end
  }
}
