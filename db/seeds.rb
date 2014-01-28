# coding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Request.delete_all
req1 = Request.create!(title:'Muj inzerat na barak 1',
                url:'http://www.sreality.cz/detail/prodej/byt/4+1/praha-praha-5-/4000535132?attractiveAdvertId=3459',
                email: 'test@balwan.cz'
)
Request.create!(title:'Muj inzerat na barak 2',
                url:'http://www.sreality.cz/detail/prodej/byt/2+kk/praha-zabehlice-pracska/4152259164',
                email: 'test@balwan.cz'
)
Request.create!(title:'Muj inzerat na byt 1 - zruseny inzerat',
                url:'http://www.sreality.cz/detail/prodej/byt/2+kk/praha-zlicin-vestonicka/1773867868',
                email: 'test@balwan.cz'
)
Request.create!(title:'Muj inzerat na vyhledavani',
                url:'http://www.sreality.cz/search?category_type_cb=2&category_main_cb=1&sub%5B%5D=2&sub%5B%5D=3&sub%5B%5D=4&sub%5B%5D=5&sub%5B%5D=6&price_min=2000&price_max=13000&region=&distance=0&rg%5B%5D=10&dt%5B%5D=5001&dt%5B%5D=5002&dt%5B%5D=5003&dt%5B%5D=5004&dt%5B%5D=5008&usable_area-min=&usable_area-max=&floor_number-min=&floor_number-max=&age=0&extension=1&sort=0&perPage=10&hideRegions=0&discount=-1',
                email: 'test@balwan.cz',
                state: 'active'
)
#Request.create!(title:'Muj inzerat na domy v Ceske Lipe',
#                url:'http://www.sreality.cz/search?category_type_cb=1&category_main_cb=1&sub%5B%5D=1&sub%5B%5D=2&sub%5B%5D=3&sub%5B%5D=4&sub%5B%5D=5&sub%5B%5D=6&price_min=1200000&price_max=1850000&region=&distance=0&rg%5B%5D=10&dt%5B%5D=5001&dt%5B%5D=5002&dt%5B%5D=5003&dt%5B%5D=5008&usable_area-min=30&usable_area-max=&floor_number-min=&floor_number-max=&age=0&extension=1&sort=0&perPage=10&hideRegions=0&discount=-1',
#                email: 'test@balwan.cz'
#)
#Request.create!(title:'Fail inzerat',
#                url:'http://www.sreality.cz/projekt?perPage=10&sort=1&projectName=&region=&distance=0&rg%5B%5D=2&rg%5B%5D=11&dt%5B%5D=8asdfa',
#                email: 'test@balwan.cz'
#)


#Ad.delete_all
#Ad.create!(request_id: req1.id,
#    title: 'Prodej, byt 4+1, 144 m²',
#           description: %{Dva objekty malobytových vil s terasovými apartmány - prostorné byty 2+kk až 6+1
#(užitná plocha 45 až 220 m2) s velikými terasami či terasovými travními zahradami nebo zahradami na terénu pozemku -
#nabízejí excelentní výhled do údolí Radotína a řeky Berounky. Všechny byty i terasy jsou orientovány na jih s celodenním
# osluněním Pro parkování jsou k dispozici velkoryse dimenzované podzemní garáže.},
#          price:11_990_000,
#          externsource:'sreality',
#          externid:'4106',
#          url:'http://www.sreality.cz/detail/prodej/byt/4+1/praha-praha-5-/4000535132?attractiveAdvertId=3459')



