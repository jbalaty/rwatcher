class AddSearchInfoIdToAdInfos < ActiveRecord::Migration
  def change
    change_table :ad_infos do |t|
      t.belongs_to :search_info
    end

    AdInfo.connection.execute('DELETE FROM ad_infos')
    SearchInfo.connection.execute('DELETE FROM search_infos')
    SearchInfoAdsRelation.connection.execute('DELETE FROM search_info_ads_relations')
    SearchInfoAdsRelation.connection.execute('DELETE FROM requests_search_infos')
    Request.update_all(processed: false)
  end
end
