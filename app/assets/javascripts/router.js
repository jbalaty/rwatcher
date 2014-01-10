// For more information see: http://emberjs.com/guides/routing/

Rwatcher.Router.map(function() {
  // this.resource('posts');
    this.resource('index', { path: '/' }, function(){
    });
    this.route('ok', {path: '/ok/:id'});
    this.route('about', {path: '/o-aplikaci'});
    this.route('faq', {path: '/faq'});

});
