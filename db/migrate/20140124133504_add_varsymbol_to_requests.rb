class AddVarsymbolToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :varsymbol, :string
    add_index :requests, [:varsymbol], :unique => true
  end
end
