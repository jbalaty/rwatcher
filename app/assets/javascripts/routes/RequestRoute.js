/**
 * Created with JetBrains RubyMine.
 * User: balwan
 * Date: 1/9/14
 * Time: 1:50 AM
 * To change this template use File | Settings | File Templates.
 */
Rwatcher.RequestRoute = Ember.Route.extend({
    model: function (params) {
        return this.store.find('request', { token: params.request_token })
            .then(function (data) {
                if (data.get('length') > 0) {
                    return data.get('firstObject');
                } else throw 'not_found';
            })
            .then(null, function (reason) {
                return {errors: ['Omlouváme se, ale záznam s ID "' +
                    params.request_token + '" nebyl nalezen']}
            })
    }
//    serialize: function (model) {
//        return {request_token: model.get('token')};
//    }
});