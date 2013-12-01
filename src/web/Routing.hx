package web;

class Rooting {
  public var roots:Array<web.Request -> Bool>;

  static public function serve(r:web.Request, fallback: web.Request -> Void) {
    for (x in Rooting.roots)
      if (x(r))
        return;

    fallback();
  }
}
