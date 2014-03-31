/**
 * Created with JetBrains RubyMine.
 * User: balwan
 * Date: 1/9/14
 * Time: 1:50 AM
 * To change this template use File | Settings | File Templates.
 */
Rwatcher.CustomurlRoute = Ember.Route.extend({
    model: function () {
        return this.store.createRecord('request', {
//            url: 'http://www.sreality.cz/search?category_type_cb=2&category_main_cb=1&sub%5B%5D=2&price_min=&price_max=5000&region=&distance=0&usable_area-min=&usable_area-max=&floor_number-min=&floor_number-max=&age=0&extension=0&sort=0&perPage=10&hideRegions=0&discount=-1'
        });
    }
});