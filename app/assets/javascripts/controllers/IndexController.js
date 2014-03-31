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

Rwatcher.IndexController = Ember.ObjectController.extend(
    Ember.GoogleAnalyticsTrackingMixin, {
        assets: Rwatcher.Assets,
        errors: [],
        showSummary: false,
        showConfirmation: false,
        showPayedWarning: false,
        adsCount: 0,
        iframeUrl: 'http://proxy.sledovani-realit:8113',
        termsAgreement: true,

        init: function () {
            var self = this
            window.addEventListener('message', function (event) {
                if (event.data['msg'] != null) {
//                    alert('Receiving iframe URL: ' + event.data.value);
//                controller.set('url', event.data.value);
                    var u = 'http://www.sreality.cz' + event.data.value;
                    self.set('url', u);
                    self.processUrl();
                }
            }, false);
        },

        processUrl: function () {
            console.log('processing url: ' + this.get('url'));
            var errors = this.get('errors');
            this.set('showSummary', false);
            var inputUrl = this.get('url');
            var self = this;
            // validate
            // track this event
            this.trackEvent('IndexAction', 'ProccessUrl', inputUrl);
            Ember.$.getJSON('/api/url-info', {url: inputUrl}).then(function (data) {
                errors.clear();
                self.set('adsCount', data.total);
//                self.set('showPayedWarning', data.tarrif.toLowerCase().indexOf('free') < 0);
                self.set('showPayedWarning', true);
                if (data.tarrif.toLowerCase().indexOf('free') > -1) {
                    self.set('payedAmount', '0 Kč');
                } else if (data.tarrif.toLowerCase().indexOf('individual') > -1) {
                    self.set('payedAmount', 'individuální, po založení sledování Vás budeme kontaktovat');
                } else {
                    self.set('payedAmount', data.tarrif_parsed[1] + ' Kč');
                }
                self.set('showSummary', true);
                //Ember.$('#email').focus(); does not work
            }, function (reason) {
                errors.clear();
                errors.pushObjects(reason.responseJSON.errors);
            })
        },

        actions: {
            processUrl: function () {
                var iframe = document.getElementById('iframe')
                iframe.contentWindow.postMessage('getUrl', '*');
            },
            submit: function () {
                var self = this;
                var errors = this.get('errors');
                errors.clear();
                this.trackEvent('IndexAction', 'SubmitEmail');
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
                                errors.pushObjects(reason.responseJSON.errors);
                                //errors.pushObject('Omlouváme se, ale založení sledování se nezdařilo (' + reason.statusText + '). Chyba');
                                /*errors.pushObject('Je nám velice líto, ale v aplikaci došlo k chybě (' + reason.statusText + ').' +
                                 ' Pro jistotu můžete zkusit vaši akci zopakovat. Pokud to nepomůže, tak budeme velice rádi, když nás na problém upozorníte' +
                                 ' emailem (<a href="mailto:podpora@sledovani-realit.cz">podpora@sledovani-realit.cz</a>).' +
                                 ' Pokusíme se ho co nejrychleji vyřešit. Předem děkujeme');
                                 */
                            });
                    }
                } else {
                    errors.pushObject('Musíte potvrdit souhlas se smluvními podmínkami')
                }
            },
            showTerms: function () {
                $('#terms').foundation('reveal', 'open', '#about');
                this.trackEvent('IndexAction', 'ShowTerms');
            },
            hideTerms: function () {
                $('#terms').foundation('reveal', 'close', '#about');
            },
            showHelp: function () {
                isVisible = $('#help:visible').length > 0;
                $('#help').toggle();
                this.trackEvent('IndexAction', 'ShowHelp', isVisible ? 'hide' : 'show');
            },
            getUrl: function () {
                var iframe = document.getElementById('iframe')
                iframe.contentWindow.postMessage('getUrl', '*');
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
