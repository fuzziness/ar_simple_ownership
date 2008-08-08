ActiveRecord::Schema.define(:version => 0) do
  create_table :users, :force => true do |t|
    t.string :name
    t.timestamp
  end

  create_table :people, :force => true do |t|
    t.string :login
    t.timestamp
  end

  # Books are created and updated by People
  create_table :books, :force => true do |t|
    t.string :user_id
    t.string :title
    t.timestamp
  end

  # Comments are created and updated by People
  # and also use non-standard foreign keys.
  create_table :comments, :force => true do |t|
    t.integer :real_person_id
    t.integer :book_id
    t.string :comment
    t.timestamp
  end

  create_table :camelized_models, :force => true do |t|
    t.integer :user_id
    t.string :data
    t.timestamp
  end
end