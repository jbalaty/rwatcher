class Notification < ActiveRecord::Base
  belongs_to :request
  belongs_to :search_info
  belongs_to :ad_info
end
