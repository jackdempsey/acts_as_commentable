class CommentGenerator < Rails::Generator::Base
   def manifest
     record do |m|
       m.directory('app/models')
       m.file('comment.rb', 'app/models/comment.rb')
     end
   end
 end
