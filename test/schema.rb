ActiveRecord::Schema.define(:version => 0) do
  create_table :posts do |t|
    t.text :text
    t.datetime
  end

  create_table :users do |u|
    u.string :name
  end

end
