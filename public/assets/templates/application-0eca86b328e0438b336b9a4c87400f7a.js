Ember.TEMPLATES.application=Ember.Handlebars.template(function(n,s,e,t,a){function l(n,s){s.buffer.push("Hlavní stránka")}function o(n,s){s.buffer.push("O službě")}function r(n,s){s.buffer.push("Ceník")}function h(n,s){s.buffer.push("Časté dotazy")}this.compilerInfo=[4,">= 1.0.0"],e=this.merge(e,Ember.Handlebars.helpers),a=a||{};var i,p,f,u,c,b="",d=this.escapeExpression,m=this,v=e.helperMissing;return a.buffer.push('<div class="body">\n    <header class="row">\n        <div class="columns small-12 large-5">\n            <h1><a href="/" style="color:inherit;">\n                <em>\n                    <b style="color:red;">S</b>ledování&nbsp;realit\n                    <div class="beta">beta</div>\n                </em>\n            </a></h1>\n        </div>\n\n    </header>\n    '),f={},u={},a.buffer.push(d(e._triageMustache.call(s,"outlet",{hash:{},contexts:[s],types:["ID"],hashContexts:u,hashTypes:f,data:a}))),a.buffer.push('\n    <br/>\n    <footer class="row">\n        <div class="columns text-center">\n            '),f={},u={},c={hash:{},inverse:m.noop,fn:m.program(1,l,a),contexts:[s],types:["STRING"],hashContexts:u,hashTypes:f,data:a},i=e["link-to"]||s&&s["link-to"],p=i?i.call(s,"index",c):v.call(s,"link-to","index",c),(p||0===p)&&a.buffer.push(p),a.buffer.push("\n            &nbsp;&nbsp;&nbsp;\n            "),f={},u={},c={hash:{},inverse:m.noop,fn:m.program(3,o,a),contexts:[s],types:["STRING"],hashContexts:u,hashTypes:f,data:a},i=e["link-to"]||s&&s["link-to"],p=i?i.call(s,"about",c):v.call(s,"link-to","about",c),(p||0===p)&&a.buffer.push(p),a.buffer.push("\n            &nbsp;&nbsp;&nbsp;\n            "),f={},u={},c={hash:{},inverse:m.noop,fn:m.program(5,r,a),contexts:[s],types:["STRING"],hashContexts:u,hashTypes:f,data:a},i=e["link-to"]||s&&s["link-to"],p=i?i.call(s,"pricelist",c):v.call(s,"link-to","pricelist",c),(p||0===p)&&a.buffer.push(p),a.buffer.push("\n            &nbsp;&nbsp;&nbsp;\n            "),f={},u={},c={hash:{},inverse:m.noop,fn:m.program(7,h,a),contexts:[s],types:["STRING"],hashContexts:u,hashTypes:f,data:a},i=e["link-to"]||s&&s["link-to"],p=i?i.call(s,"faq",c):v.call(s,"link-to","faq",c),(p||0===p)&&a.buffer.push(p),a.buffer.push('\n\n        </div>\n        <div class="columns text-center" style="margin-top:7px;">\n            <small>&copy; 2014 <a href="mailto:dotazy@sledovani-realit.cz">sledovani-realit.cz</a></small>\n        </div>\n    </footer>\n\n</div>\n'),b});