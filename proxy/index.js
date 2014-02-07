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

        res.write = function (data) {
            _write.call(res, data.toString().replace("<head>", "<head><script type=\"text/javascript\">" +
                " var mlistener = function(event){ " +
                " if(event.origin == 'http://sledovani-realit.cz' || event.origin == 'http://localhost:3000') {" +
                "   event.source.postMessage({msg:'setUrl',value:window.location.href}, event.origin);" +
                "}};" +
//                "alert('parent: '+parent);" +
//                "window.parent.postMessage({msg:'setUrl',value:window.location.href},'*')" +
                "window.addEventListener('message',mlistener,false);" +
                "</script>"));
        }
        next();
    },

    function (req, res) {
        util.puts('New proxy request: ' + req.url)
        proxy.web(req, res);
    }
).listen(8013);

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
http.createServer(function (req, res) {
    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.end('<head><title>should be Ruby</title></head><body>Hello, I know Ruby\n</body>');
}).listen(9013);

util.puts('http proxy server'.blue + ' started '.green.bold + 'on port '.blue + '8013'.yellow);
util.puts('http server '.blue + 'started '.green.bold + 'on port '.blue + '9013 '.yellow);
