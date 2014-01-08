class CreateSearchInfoAdsRelation < ActiveRecord::Migration
  def change
    create_table :search_info_ads_relations do |t|
      t.belongs_to :search_info
      t.belongs_to :ad_info
    end
  end
end
