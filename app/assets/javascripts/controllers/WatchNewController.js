/**
 * Created with JetBrains RubyMine.
 * User: balwan
 * Date: 1/6/14
 * Time: 2:03 PM
 * To change this template use File | Settings | File Templates.
 */

function isEmailValid(email) {
    email = email || '';
    var atpos = email.indexOf("@");
    var dotpos = email.lastIndexOf(".");
    if (atpos < 1 || dotpos < atpos + 2 || dotpos + 2 >= email.length) {
        return false;
    }
    return true;
}

Rwatcher.WatchNewController = Ember.ObjectController.extend({
    needs:['index'],

    errors: [],
    showSummary: false,
    showConfirmation: false,
    adsCount: 0,

    actions: {
        processUrl: function () {
            var errors = this.get('errors');
            this.set('showSummary', false);
            var inputUrl = this.get('url');
            var self = this;
            // validate
            Ember.$.getJSON('/api/url-info', {url: inputUrl}).then(function (data) {
                errors.clear();
                self.set('adsCount', data.total)
                self.set('showSummary', true);
            }, function (reason) {
                errors.clear();
                console.log('error error!' + JSON.stringify(reason.responseJSON));
                errors.pushObjects(reason.responseJSON.errors);
            })
        },
        submit: function () {
            var self = this;
            var errors = this.get('errors');
            errors.clear();
            var inputUrl = this.get('url');
            var inputEmail = this.get('email');
            if (!isEmailValid(inputEmail)) {
                errors.pushObject('Email není ve správném formátu');
            } else {
                var request = this.store.createRecord('request', {
                    url: inputUrl,
                    email: inputEmail
                });
                request.save()
                    .then(function (data) {
                        self.transitionToRoute('watch.ok',data);
                    }, function (reason) {
                        alert('nezdarilo se zalozit sledovani');
                    });
            }
        }
    }
})
/**
 * Created with JetBrains RubyMine.
 * User: balwan
 * Date: 1/9/14
 * Time: 1:12 AM
 * To change this template use File | Settings | File Templates.
 */