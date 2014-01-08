class AdInfo < ActiveRecord::Base
  has_many :search_info_ads_relations
  has_many :search_infos, through: :search_info_ads_relations
end
