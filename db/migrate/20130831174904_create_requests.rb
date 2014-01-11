class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.string :title # custom name for this request
      t.text :url, length: 1024 # url from external system
      t.boolean :processed, default: false
      t.integer :numFailedAttempts, default:0
      t.datetime :firstFailedAttempt
      t.string :email
      t.string :token, length: 1024

      t.timestamps
    end

    create_table :requests_search_infos do |t|
      t.belongs_to :search_info
      t.belongs_to :request
    end
  end
end
