/**
 * Created with JetBrains RubyMine.
 * User: balwan
 * Date: 1/7/14
 * Time: 8:37 PM
 * To change this template use File | Settings | File Templates.
 */
Rwatcher.Request = DS.Model.extend({
    url: DS.attr('string'),
    email: DS.attr('string'),
    varsymbol: DS.attr('string'),
    sms_guide_html: DS.attr('string'),
    created_at: DS.attr('date')
});