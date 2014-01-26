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

Rwatcher.IndexController = Ember.ObjectController.extend({
    assets: Rwatcher.Assets,
    errors: [],
    showSummary: false,
    showConfirmation: false,
    showPayedWarning: false,
    adsCount: 0,
    iframeUrl: 'http://www.sreality.cz',
    termsAgreement: true,

    actions: {
        processUrl: function () {
            var errors = this.get('errors');
            this.set('showSummary', false);
            var inputUrl = this.get('url');
            var self = this;
            // validate
            Ember.$.getJSON('/api/url-info', {url: inputUrl}).then(function (data) {
                errors.clear();
                self.set('adsCount', data.total);
                self.set('showPayedWarning', data.tarrif.toLowerCase().indexOf('free') < 0);
                self.set('payedAmount',data.tarrif_parsed[1]);
                self.set('showSummary', true);
                //Ember.$('#email').focus(); does not work
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
            if (this.get('termsAgreement')) {
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
                            self.set('showSummary', false);
                            self.transitionToRoute('ok', data);
                        }, function (reason) {
//                            errors.pushObject('Omlouváme se, ale založení sledování se nezdařilo (' + reason.statusText + '). Chyba');
                            errors.pushObject('Je nám velice líto, ale v aplikaci došlo k chybě (' + reason.statusText + ').' +
                                ' Pro jistotu můžete zkusit vaši akci zopakovat. Pokud to nepomůže, tak budeme velice rádi, když nás na problém upozorníte' +
                                ' emailem (<a href="mailto:podpora@sledovani-realit.cz">podpora@sledovani-realit.cz</a>).' +
                                ' Pokusíme se ho co nejrychleji vyřešit. Předem děkujeme');
                            //throw new Ember.Error('Nezdařilo se založit sledování.');
                        });
                }
            } else {
                errors.pushObject('Musíte potvrdit souhlas se smluvními podmínkami')
            }
        },
        showTerms: function () {
            $('#terms').foundation('reveal', 'open', '#about');
        },
        hideTerms: function () {
            $('#terms').foundation('reveal', 'close', '#about');
        },
        showHelp: function () {
            $('#help').toggle();
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
