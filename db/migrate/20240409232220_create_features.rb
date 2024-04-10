class CreateFeatures < ActiveRecord::Migration[7.1]
  def change
    create_table :feature do |t|
      t.string  :feature_id
      t.decimal :mag
      t.string  :place
      t.integer :quoted_time
      t.string  :url
      t.integer :tsunami
      t.string  :magType
      t.string  :title
      t.decimal :longitude
      t.decimal :latitude
    end
    create_table :comment do |t|
      t.integer :feature_id
      t.string  :body
    end
  end
end
