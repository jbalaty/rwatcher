class SearchInfo < ActiveRecord::Base
  has_and_belongs_to_many :requests
  has_many :search_info_ads_relations
  has_many :ad_infos, through: :search_info_ads_relations

end
