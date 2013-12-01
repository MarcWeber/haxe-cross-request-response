package web;
import haxe.CallStack;

typedef ServerOptions = {
#if js
  port: Int
#end
}

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
  #else
    #error TODO
  #end
  }
}
