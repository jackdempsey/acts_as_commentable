require 'test/unit'
require 'logger'
require File.expand_path(File.dirname(__FILE__) + '/../rails/init')

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

class ActsAsCommentableTest < Test::Unit::TestCase

  def setup_comments
    require File.expand_path(File.dirname(__FILE__) + '/../lib/generators/comment/templates/create_comments') 
    CreateComments.up
    load(File.expand_path(File.dirname(__FILE__) + '/../lib/generators/comment/templates/comment.rb'))
  end

  def setup_test_models
    load(File.expand_path(File.dirname(__FILE__) + '/schema.rb'))
    load(File.expand_path(File.dirname(__FILE__) + '/models.rb'))
  end

  def setup
    setup_comments
    setup_test_models
  end

  def teardown
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end

  def test_create_comment
    commentable = Post.create(:text => "Awesome post !")
    assert_not_nil commentable.comments.create(:title => "First comment.", :comment => "This is the first comment.").id
  end

  def test_fetch_comments
    post = Post.create(:text => "Awesome post !")
    post.comments.create(:title => "First comment.", :comment => "This is the first comment.")
    commentable = Post.find(1)
    assert_equal 1, commentable.comments.length
    assert_equal "First comment.", commentable.comments.first.title
    assert_equal "This is the first comment.", commentable.comments.first.comment
  end

  def test_find_comments_by_user
    user = User.create(:name => "Mike")
    user2 = User.create(:name => "Fake") 
    post = Post.create(:text => "Awesome post !")
    comment = post.comments.create(:title => "First comment.", :comment => "This is the first comment.", :user => user)
    assert_equal true, Post.find_comments_by_user(user).include?(comment)
    assert_equal false, Post.find_comments_by_user(user2).include?(comment) 
  end

end
