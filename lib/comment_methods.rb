module ActsAsCommentable
  module Comment
    
    def self.included(comment_model)
      comment_model.extend Finders
    end
    
    module Finders
      # Helper class method to lookup all comments assigned
      # to all commentable types for a given user.
      def find_comments_by_user(user)
        find(:all,
          :conditions => ["user_id = ?", user.id],
          :order => "created_at DESC"
        )
      end

      # Helper class method to look up all comments for 
      # commentable class name and commentable id.
      def find_comments_for_commentable(commentable_str, commentable_id)
        find(:all,
          :conditions => ["commentable_type = ? and commentable_id = ?", commentable_str, commentable_id],
          :order => "created_at DESC"
        )
      end

      # Helper class method to look up a commentable object
      # given the commentable class name and id 
      def find_commentable(commentable_str, commentable_id)
        commentable_str.constantize.find(commentable_id)
      end
    end
  end
end