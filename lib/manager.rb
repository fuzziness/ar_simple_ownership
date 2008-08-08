module Fuzziness #:nodoc:
  
  module ArOwnership
    # The Ownership module, when included into a controller, adds a before filter
    # (named <tt>set_owner</tt>) and an after filter (name <tt>reset_owner</tt>).
    # These methods assume a couple of things, but can be re-implemented in your
    # controller to better suite your application.
    #
    # See the documentation for <tt>set_owner</tt> and <tt>reset_owner</tt> for
    # specific implementation details.
    module Manager
      def self.included(base) #:nodoc:
        base.extend(ClassMethods)
      end

      module ClassMethods #:nodoc:
        # This method is automatically called on for all classes that inherit from
        # ActiveRecord, but if you need to customize how the plug-in functions, this is the
        # method to use. Here's an example:
        #
        #   class Post < ActiveRecord::Base
        #     manage_ownership :for => :person
        #   end
        #
        # The method will automatically setup all the associations, and create <tt>before_save</tt>
        # and <tt>before_create</tt> filters for record the ownership.
        def manage_ownership(options={})
          # don't allow multiple calls 
          # FIXME check why fails
          #return if self.included_modules.include?(Fuzziness::ArOwnership::Manager::InstanceMethods)
                    
          class_eval do
            # For which class am I managing ownerships? Defaults to :user.
            cattr_accessor :owner_class

            include Fuzziness::ArOwnership::Manager::InstanceMethods
            
            before_filter  :set_owner
            after_filter   :reset_owner            
          end
          
          defaults  = {
            :for => :user,
          }.merge(options)

          if defaults[:for].is_a?(Symbol) || defaults[:for].is_a?(String)
            klass = Kernel.const_get(defaults[:for].to_s.camelize)
          elsif defaults[:for].is_a?(Class)
            klass = Kernel.const_get(defaults[:for].name)
          else
            klass = Kernel.const_get(defaults[:for].to_s)
          end
          
          raise(ArgumentError, "manage_ownership can't handle class #{klass}: did you included owner?") unless klass.respond_to?(:owner_class)

          # FIXME store klass with path          
          self.owner_class = klass
          puts self.owner_class.inspect
          
          owner_class = klass
          puts owner_class.inspect
        end
      end
      
      module InstanceMethods #:nodoc:
        
        private
        
        # The <tt>set_owner</tt> method as implemented here assumes a couple
        # of things. First, that you are using a +User+ model as the owner
        # and second that your controller has a <tt>get_current_owner</tt> method
        # that contains the currently logged in owner. If either of these
        # are not the case in your application you will want to manually add
        # your own implementation of this method to the private section of
        # the controller where you are including the Ownership module.
        def set_owner
          puts owner_class.owner
          
          owner_class.owner= get_current_owner
        end

        # The <tt>reset_owner</tt> method as implemented here assumes that a
        # +User+ model is being used as the owner. If this is not the case then
        # you will need to manually add your own implementation of +get_current_owner+ 
        # method to the private section of the controller where you are including the
        # Ownership module.
        def reset_owner
          self.owner_class.reset_owner
        end

        # The <tt>get_current_owner</tt> method as implemented here assumes that
        # RestfulAutentication plugin is being used.
        def get_current_owner
          puts "current_#{self.class.owner_class.name.underscore}"
          
          self.send "current_#{self.class.owner_class.name.underscore}".to_sym
        end
      end
    end
  end
end

ActionController::Base.send(:include, Fuzziness::ArOwnership::Manager) if defined?(ActionController)
