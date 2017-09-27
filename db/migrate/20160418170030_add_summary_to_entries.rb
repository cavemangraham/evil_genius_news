class AddSummaryToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :summary, :text
  end
end
