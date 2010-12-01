class Post < ActiveRecord::Base
  acts_as_commentable
end

class User < ActiveRecord::Base
end
