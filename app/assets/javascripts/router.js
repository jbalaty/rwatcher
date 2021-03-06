// For more information see: http://emberjs.com/guides/routing/

Rwatcher.Router.map(function () {
    // this.resource('posts');
    this.route('error', {path: '/error'});
    this.route('ok', {path: '/ok/:id'});
    this.route('about', {path: '/o-aplikaci'});
    this.route('customurl', {path: '/vlastni'});
    this.route('faq', {path: '/faq'});
    this.route('pricelist', {path: '/cenik'});
    this.resource('request', {path: '/request/:request_token'}, function () {
        this.route('delete', {path: '/delete'});
    });
});
