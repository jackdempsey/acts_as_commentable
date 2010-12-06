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
    post = Post.create(:text => "Awesome post !")
    assert_not_nil post.comments.create(:title => "comment.", :comment => "This is the a comment.").id

    wall = Wall.create(:name => "My Wall")
    assert_not_nil wall.public_comments.create(:title => "comment.", :comment => "This is the a comment.").id
    assert_not_nil wall.private_comments.create(:title => "comment.", :comment => "This is the a comment.").id
    assert_raise NoMethodError do
      wall.comments.create(:title => "Comment", :title => "Title")
    end
  end

  def test_fetch_comments
    post = Post.create(:text => "Awesome post !")
    post.comments.create(:title => "First comment.", :comment => "This is the first comment.")
    commentable = Post.find(1)
    assert_equal 1, commentable.comments.length
    assert_equal "First comment.", commentable.comments.first.title
    assert_equal "This is the first comment.", commentable.comments.first.comment

    wall = Wall.create(:name => "wall")
    private_comment = wall.private_comments.create(:title => "wall private comment", :comment => "Yipiyayeah !")
    assert_equal [private_comment], wall.private_comments
    public_comment = wall.public_comments.create(:title => "wall public comment", :comment => "Yipiyayeah !")
    assert_equal [public_comment], wall.public_comments
  end

  def test_find_comments_by_user
    user = User.create(:name => "Mike")
    user2 = User.create(:name => "Fake") 
    post = Post.create(:text => "Awesome post !")
    comment = post.comments.create(:title => "First comment.", :comment => "This is the first comment.", :user => user)
    assert_equal true, Post.find_comments_by_user(user).include?(comment)
    assert_equal false, Post.find_comments_by_user(user2).include?(comment) 
  end

  def test_find_comments_for_commentable
    post = Post.create(:text => "Awesome post !")
    comment = post.comments.create(:title => "First comment.", :comment => "This is the first comment.")
    assert_equal [comment], Comment.find_comments_for_commentable(post.class.name, post.id)
  end

  def test_find_commentable
    post = Post.create(:text => "Awesome post !")
    comment = post.comments.create(:title => "First comment.", :comment => "This is the first comment.")
    assert_equal post, Comment.find_commentable(post.class.name, post.id) 
  end

  def test_find_comments_for
    post = Post.create(:text => "Awesome post !")
    comment = post.comments.create(:title => "First comment.", :comment => "This is the first comment.")
    assert_equal [comment], Post.find_comments_for(post)

    wall = Wall.create(:name => "wall")
    private_comment = wall.private_comments.create(:title => "wall private comment", :comment => "Yipiyayeah !")
    assert_equal [private_comment], Wall.find_private_comments_for(wall)

    public_comment = wall.public_comments.create(:title => "wall public comment", :comment => "Yipiyayeah !")
    assert_equal [public_comment], Wall.find_public_comments_for(wall)
  end

  def test_find_comments_by_user
    user = User.create(:name => "Mike")
    post = Post.create(:text => "Awesome post !")
    comment = post.comments.create(:title => "First comment.", :comment => "This is the first comment.", :user => user)
    assert_equal [comment], Post.find_comments_by_user(user)

    wall = Wall.create(:name => "wall")
    private_comment = wall.private_comments.create(:title => "wall private comment", :comment => "Yipiyayeah !", :user => user)
    assert_equal [private_comment], Wall.find_private_comments_by_user(user)

    public_comment = wall.public_comments.create(:title => "wall public comment", :comment => "Yipiyayeah !", :user => user)
    assert_equal [public_comment], Wall.find_public_comments_by_user(user)
  end

  def test_comments_ordered_by_submitted
    post = Post.create(:text => "Awesome post !")
    comment = post.comments.create(:title => "First comment.", :comment => "This is the first comment.")
    comment2 = post.comments.create(:title => "Second comment.", :comment => "This is the second comment.")
    assert_equal [comment, comment2], post.comments_ordered_by_submitted

    wall = Wall.create(:name => "wall")
    private_comment = wall.private_comments.create(:title => "wall private comment", :comment => "Yipiyayeah !")
    private_comment2 = wall.private_comments.create(:title => "wall private comment", :comment => "Yipiyayeah !")
    assert_equal [private_comment, private_comment2], wall.private_comments_ordered_by_submitted

    public_comment = wall.public_comments.create(:title => "wall public comment", :comment => "Yipiyayeah !")
    public_comment2 = wall.public_comments.create(:title => "wall public comment", :comment => "Yipiyayeah !")
    assert_equal [public_comment, public_comment2], wall.public_comments_ordered_by_submitted
  end

  def test_add_comment
    post = Post.create(:text => "Awesome post !")
    comment = Comment.new(:title => "First Comment", :comment => 'Super comment')
    post.add_comment(comment)
    assert_equal [comment], post.comments

    wall = Wall.create(:name => "wall")
    private_comment = Comment.new(:title => "First Comment", :comment => 'Super comment')
    wall.add_private_comment(private_comment)
    assert_equal [private_comment], wall.private_comments

    public_comment = Comment.new(:title => "First Comment", :comment => 'Super comment')
    wall.add_public_comment(public_comment)
    assert_equal [public_comment], wall.public_comments
  end

  def test_is_comment_type
    post = Post.create(:text => "Awesome post !")
    comment = Comment.new(:title => "First Comment", :comment => 'Super comment')
    post.add_comment(comment)
    assert_equal true, comment.is_comment_type?(:comment)

    wall = Wall.create(:name => "wall")
    private_comment = Comment.new(:title => "First Comment", :comment => 'Super comment')
    wall.add_private_comment(private_comment)
    assert_equal true, private_comment.is_comment_type?(:private)

    public_comment = Comment.new(:title => "First Comment", :comment => 'Super comment')
    wall.add_public_comment(public_comment)
    assert_equal true, public_comment.is_comment_type?(:public)
    assert_equal false, public_comment.is_comment_type?(:comment)

  end

end
