module Fuzziness #:nodoc:

  module ArOwnership
    # Extends the functionality of ActiveRecord by automatically recording the model
    # responsible for creating the current object. See the Owner
    # and Ownership modules for further documentation on how the entire process works.
    module Ownable

      def self.included(base) #:nodoc:
        base.extend(ClassMethods)
      end

      module ClassMethods #:nodoc:
        # This method is automatically called on for all classes that inherit from
        # ActiveRecord, but if you need to customize how the plug-in functions, this is the
        # method to use. Here's an example:
        #
        #   class Post < ActiveRecord::Base
        #     ownable :by => :person, :on  => :create_user
        #   end
        #
        # The method will automatically setup all the associations, and create <tt>before_save</tt>
        # filter for record the ownership and <tt>named_scope</tt> or owner's selections.
        def ownable(options={})
          # don't allow multiple calls 
          return if self.included_modules.include?(Fuzziness::ArOwnership::Ownable::InstanceMethods)
          
          class_eval do
            include Fuzziness::ArOwnership::Ownable::InstanceMethods
            
            # Should ActiveRecord record ownerships? Defaults to true.
            cattr_accessor  :record_ownership
            self.record_ownership = true
            # Which class is responsible for ownerships? Defaults to :user.
            cattr_accessor  :owner_class_name
            # What column should be used for the owner id? Defaults to :user_id.
            cattr_accessor :owner_model_attribute
          end
                  
          defaults = {
            :by => :user,
            :on => :user_id,
          }.merge(options)

          self.owner_class_name = defaults[:by].to_sym
          self.owner_model_attribute = defaults[:on].to_sym

          class_eval do
            belongs_to self.owner_class_name.to_s.underscore.to_sym, 
              :class_name => self.owner_class_name.to_s.singularize.camelize,
              :foreign_key => self.owner_model_attribute
                                 
            before_create :set_owner_model_attribute
            
            named_scope "of_current_#{self.owner_class_symbol}".to_sym, 
              lambda{ {:conditions => {self.owner_model_attribute => self.get_owner_value}} } 
          end
        end
        
        # Temporarily allows you to turn ownership record off. For example:
        #
        #   Post.without_ownership do
        #     post = Post.find(params[:id])
        #     post.update_attributes(params[:post])
        #     post.save
        #   end
        def without_ownership
          original_value = self.record_ownership
          self.record_ownership = false
          yield
          self.record_ownership = original_value
        end
        
        def owner_class #:nodoc:
          self.owner_class_name.to_s.capitalize.constantize rescue nil
        end
        
        def owner_class_symbol #:nodoc:
          self.owner_class_name.to_s.underscore rescue nil
        end 

        def get_owner_value #:nodoc:
          # # store owner id
          # owner_class.owner.object_id rescue nil

          # store owner model
          self.owner_class.owner rescue nil
        end

        def has_owner? #:nodoc:
          !self.get_owner_value.nil?
        end
      end

      module InstanceMethods #:nodoc:
        
        private

        def set_owner_model_attribute
          return unless self.record_ownership
          # # store owner id
          # if respond_to?(self.owner_model_attribute.to_sym) && self.class.has_owner?
          #   self.send("#{self.owner_model_attribute}=".to_sym, self.class..get_owner_value)
          # end

          # store owner model
          if respond_to?(self.class.owner_class_symbol.to_sym) && self.class.has_owner?
            self.send("#{self.class.owner_class_symbol}=".to_sym, self.class.get_owner_value)
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Fuzziness::ArOwnership::Ownable) if defined?(ActiveRecord)
