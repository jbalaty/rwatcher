/**
 * Created with JetBrains RubyMine.
 * User: balwan
 * Date: 1/10/14
 * Time: 11:05 PM
 * To change this template use File | Settings | File Templates.
 */
Rwatcher.ErrorController = Ember.Controller.extend({
    location: function(){
        return window.location;
    }.property()
})