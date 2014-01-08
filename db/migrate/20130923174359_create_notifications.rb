class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.belongs_to :search_info
      t.belongs_to :ad_info
      t.belongs_to :request
      t.string :notificationType
      t.string :notificationSubtype

      t.timestamps
    end
  end
end
