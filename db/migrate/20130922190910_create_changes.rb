class CreateChanges < ActiveRecord::Migration
  def change
    create_table :changes do |t|
      t.belongs_to :search_info
      t.belongs_to :ad_info
      t.string :changeType
      t.string :changeSubtype
      t.string :data
      t.text  :dataBefore
      t.text  :dataAfter

      t.timestamps
    end
  end
end
