module Fuzziness #:nodoc:
  module ArOwnership #:nodoc:
    
    # Extends the functionality of +ActiveRecord+ by automatically recording the model
    # responsible for creating the current object.
    # See the <tt>Owner</tt> and <tt>Manager</tt> modules for further documentation
    # on how the entire process works.
    module Ownable

      def self.included(base) #:nodoc:
        base.extend(ClassMethods)
      end

      module ClassMethods
        # Automatically setup model association, create <tt>before_save</tt>
        # filter for record the ownership and <tt>named_scope</tt> for made search by owners.
        # If you need to customize how the plug-in works, this is the method to use.
        # 
        # Here's an example:
        #
        #   class Post < ActiveRecord::Base
        #     ownable :by => :person, :on  => :create_user
        #   end
        #
        # Options:
        # <tt>by</tt>::        owner model class (default: +User+)
        # <tt>on</tt>::        owner id column name (default: +user_id+)
        # 
        def ownable(options={})
          # don't allow multiple calls 
          return if self.included_modules.include?(Fuzziness::ArOwnership::Ownable::InstanceMethods)
          #:stopdoc:
          include Fuzziness::ArOwnership::Ownable::InstanceMethods
          #:startdoc:
         
          # Should ActiveRecord record ownerships? Defaults to true.
          class_inheritable_accessor  :record_ownership
          self.record_ownership = true
          # Which class is responsible for ownerships? Defaults to :user.
          class_inheritable_accessor  :owner_class_name
          # What column should be used for the owner id? Defaults to :user_id.
          class_inheritable_accessor :owner_model_attribute
                  
          defaults = {
            :by => :user,
            :on => :user_id,
          }.merge(options)

          self.owner_class_name = defaults[:by].to_sym
          self.owner_model_attribute = defaults[:on].to_sym

          belongs_to self.owner_class_name.to_s.underscore.to_sym, 
            :class_name => self.owner_class_name.to_s.singularize.camelize,
            :foreign_key => self.owner_model_attribute
                                 
          before_create :set_owner_model_attribute
            
          named_scope "of_current_#{self.owner_class_symbol}".to_sym, 
            lambda{ {:conditions => {self.owner_model_attribute => self.get_owner_value}} } 
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
