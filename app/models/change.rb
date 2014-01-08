class Change < ActiveRecord::Base
  belongs_to :search_info
  belongs_to :ad_info
end
