class Ad < ActiveRecord::Base
  has_one :watched_resource, as: :polymorhicWatchedResource

  #validates :title, :description, :price, :externid, :externsource, :url, presence: true
  #validates :price, numericality: {greater_than_or_equal_to: 0.01}

  def Ad.create_or_update(ad_hash)
    ad = Ad.new
    aaa = ad.polymorhicWatchedResource
    wr = WatchedResource.find_by_externId ad_hash['externid']
    unless wr
      wr = WatchedResource.new
    end
    wr.externId = ad_hash['externid']
    wr.urlNormalized = ad_hash['url']
    wr.externSource = ad_hash['externsource']
    wr.lastCheckAt = DateTime.now
    wr.numFailedChecks= 0
    wr.firstFailedCheck = nil
    wr.resultsCount = 0
    wr.save!
  end
end
