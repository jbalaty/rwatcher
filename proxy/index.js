var util = require('util'),
    colors = require('colors'),
    http = require('http'),
    connect = require('connect'),
    httpProxy = require('http-proxy'),
    cors = require('cors');

var corsOptions = {
  origin: '*'
};
//
// Basic Connect App
//
connect.createServer(
    cors(corsOptions),
    function (req, res, next) {
      var _write = res.write;
      //if (req.originalUrl === '/') {
      {
        console.log('Adding custom JS script to response');
        res.write = function (data) {
          _write.call(res, data.toString().replace("<head>", "<head><script type=\"text/javascript\">" +
              " var mlistener = function(event){ " +
              " debugger;" +
              " if(event.origin == 'http://sledovani-realit.cz' || event.origin == 'http://localhost:3000') {" +
              "   event.source.postMessage({msg:'setUrl',value:window.location.pathname+" +
              "    window.location.search}, event.origin);" +
              "}};" +
//                "alert('parent: '+parent);" +
//                "window.parent.postMessage({msg:'setUrl',value:window.location.href},'*')" +
              "window.addEventListener('message',mlistener,false);" +
              "</script>" +
              "<style>" +
              " div#adLeaderboard {display:none;}" +
              "</style>"));
        }
      }
      next();
    },

    function (req, res) {
      util.puts('New proxy request: ' + req.url);
      if (req.headers['if-modified-since']) {
        delete req.headers['if-modified-since'];
      }
      proxy.web(req, res);
    }
).listen(8113);

//
// Basic Http Proxy Server
//
var proxy = httpProxy.createProxyServer({
  target: 'http://www.sreality.cz:80'
//    target: 'http://localhost:9013'
});

//
// Target Http Server
//
//http.createServer(function (req, res) {
//  res.writeHead(200, { 'Content-Type': 'text/html' });
//  res.end('<head><title>should be Ruby</title></head><body>Hello, I know Ruby\n</body>');
//}).listen(9013);

util.puts('http proxy server'.blue + ' started '.green.bold + 'on port '.blue + '8113'.yellow);
//util.puts('http server '.blue + 'started '.green.bold + 'on port '.blue + '9113 '.yellow);
