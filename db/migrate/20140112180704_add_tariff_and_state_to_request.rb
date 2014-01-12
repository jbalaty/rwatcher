class AddTariffAndStateToRequest < ActiveRecord::Migration
  def change
    add_column :requests, :tarrif, :string, default: 'T1_none'
    add_column :requests, :state, :string, default: 'created'
  end
end
