/**
 * Created with JetBrains RubyMine.
 * User: balwan
 * Date: 1/6/14
 * Time: 2:03 PM
 * To change this template use File | Settings | File Templates.
 */

Rwatcher.RequestDeleteController = Ember.ObjectController.extend({
    needs: ['request'],
    request: Ember.computed.alias("controllers.request"),
    errors:[],
    showOk:false,
    isError: function () {
        return this.get('request').get('errors');
    }.property('request'),
    actions: {
        proceed: function (request) {
            var self = this;
            request.destroyRecord()
                .then(function(){
                    self.set('showOk',true)
                }, function(reason){
                    self.get('errors').pushObject(reason);
                })
        },
        cancel: function () {
            this.transitionToRoute('index');

        }
    }
});
