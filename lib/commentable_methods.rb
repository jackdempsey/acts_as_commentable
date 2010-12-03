require 'active_record'

# ActsAsCommentable
module Juixe
  module Acts #:nodoc:
    module Commentable #:nodoc:

      def self.included(base)
        base.extend ClassMethods  
      end

      module ClassMethods
        def acts_as_commentable(*args)
          comment_roles = args.to_a.flatten.compact.map(&:to_sym)
          write_inheritable_attribute(:comment_types, (comment_roles.blank? ? [:comments] : comment_roles))
          class_inheritable_reader(:comment_types)

          options = ((args.blank? or args[0].blank?) ? {} : args[0])

          if !comment_roles.blank?
            comment_roles.each do |role|
              has_many "#{role.to_s}_comments".to_sym,
                {:class_name => "Comment",
                  :as => :commentable,
                  :dependent => :destroy,
                  :conditions => ["role = ?", role.to_s],
                  :before_add => Proc.new { |x, c| c.role = role.to_s }}
            end
          else
            has_many :comments, {:as => :commentable, :dependent => :destroy}
          end

          comment_types.each do |role|
            method_name = (role == :comments ? "comments" : "#{role.to_s}_comments").to_s
            class_eval %{
              def self.find_#{method_name}_for(obj)
                commentable = self.base_class.name
                Comment.find_comments_for_commentable(commentable, obj.id, "#{role.to_s}")
              end

              def self.find_#{method_name}_by_user(user) 
                commentable = self.base_class.name
                Comment.where(["user_id = ? and commentable_type = ? and role = ?", user.id, commentable, "#{role.to_s}"]).order("created_at DESC")
              end

              def #{method_name}_ordered_by_submitted
                Comment.find_comments_for_commentable(self.class.name, id, "#{role.to_s}")
              end

              def add_#{method_name.singularize}(comment)
                comment.role = "#{role.to_s}"
                #{method_name} << comment
              end
            }
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Juixe::Acts::Commentable)
