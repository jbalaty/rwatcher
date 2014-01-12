class AddTokenIndexToRequest < ActiveRecord::Migration
  def change
    add_column :requests, :token, :string, length: 1024
    add_index :requests, [:url, :email], :unique=>true
  end
end
