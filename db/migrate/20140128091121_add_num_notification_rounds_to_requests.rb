class AddNumNotificationRoundsToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :numnotificationrounds, :integer, default: 0
  end
end
