package web.routing;
/* Example:

   class Foo extends StaticRoutingMacro {
      static public function user_by_name(r: web.Request, name:String) {
      }

      /* will be created automatically:
      static public function user_by_nameURL(name:String) {
        return "Foo/user_by_name/"+name;
      }
   }

*/

@:buildBuild(web.RoutingBuilder.staticBuild()) class StaticRoutingMacro {
#if macro
  public var routes;
#end
}
