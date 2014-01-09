Ember.TEMPLATES["application"] = Ember.Handlebars.template(function anonymous(Handlebars,depth0,helpers,partials,data) {
this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Ember.Handlebars.helpers); data = data || {};
  var buffer = '', hashTypes, hashContexts, escapeExpression=this.escapeExpression;


  data.buffer.push("<header class=\"row\">\n    <div class=\"columns\">\n        <a href=\"/\"><h1><em><b style=\"color:red;\">S</b>ledování realit</em></h1></a>\n    </div>\n</header>\n<div class=\"row\">\n    <div class=\"columns\" style=\"min-height: 300px;\">\n        ");
  hashTypes = {};
  hashContexts = {};
  data.buffer.push(escapeExpression(helpers._triageMustache.call(depth0, "outlet", {hash:{},contexts:[depth0],types:["ID"],hashContexts:hashContexts,hashTypes:hashTypes,data:data})));
  data.buffer.push("\n    </div>\n</div>\n<footer class=\"row\">\n    <div class=\"columns text-right\">\n        &copy; 2014\n    </div>\n</footer>\n");
  return buffer;
  
});
