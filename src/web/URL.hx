package web;

// modeled after http://nodejs.org/api/url.html
// unfinished

class URL {
  public var href(get_href,set_href):String; // full url

  public var host(get_host, set_host): String; // foo:8080
  public var domain: String; // foo
  public var path:   String;
  public var port: Null<String>; // 8080
  public var protocol: String;
  public var params: Map<String,String>;

  public var hash:String; // fragment with #foo pound sign

  static public function parse(s:String) {
    throw "TODO";
  }

  public function encodeParams(params:Map<String,String>) {
    throw "TODO";
    return "";
  }

  public function set_host(h:String) {
    var l = h.split(':');
    domain = l[0];
    port = l.length > 1 ? l[1] : null;
  }

  public function get_host(arg){
    return domain +
      (port == null 
        ? ''
        : ":"+port);
  }

  public function toString() {
    return '${this.protocol}://${this.host}/${path}${encodeParams(this.params)}';
  }

  public function get_href() {
    return toString();
  }

  public function set_href(s:String) {
    throw "TODO";
  }

}
