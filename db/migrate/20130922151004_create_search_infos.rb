class CreateSearchInfos < ActiveRecord::Migration
  def change
    create_table :search_infos do |t|
      t.text :urlNormalized # normalized extern url
      t.string :usage, default: 'user'
      t.text :externId, length: 1024 # identifier of resource in external system
      t.string :externSource # external system name string = eg. sreality
      t.datetime :lastCheckAt
      t.integer :numFailedChecks
      t.datetime :firstFailedCheck
      t.integer :resultsCount
      t.string :lastExternId

      t.timestamps
    end
  end
end
