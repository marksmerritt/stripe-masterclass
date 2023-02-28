class CreatePlans < ActiveRecord::Migration[7.0]
  def change
    create_table :plans do |t|
      t.string :name
      t.integer :amount
      t.string :interval
      t.string :stripe_id

      t.timestamps
    end
  end
end
