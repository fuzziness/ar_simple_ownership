module Fuzziness #:nodoc:
  module ArOwnership #:nodoc:
    
    # Extends the functionality of +ActionController+ by automatically recording the 
    # currently logged user as owner.
    # See the <tt>Owner</tt> and <tt>Ownable</tt> modules for further documentation
    # on how the entire process works.
    module Manager
      
      def self.included(base) #:nodoc:
        base.extend(ClassMethods)
      end

      module ClassMethods
        # The method will automatically setup before and after filters for keeping
        # track of ownership.
        # These methods assume a couple of things, but can be re-implemented in your
        # controller to better suite your application.
        #
        # See the documentation for <tt>set_owner</tt> and <tt>reset_owner</tt> for
        # specific implementation details.
        # 
        # If you need to customize how the plug-in works, this is the method to use.
        # 
        # Here's an example:
        #
        #   class Post < ActiveRecord::Base
        #     manage_ownership :for => :person
        #   end
        #   
        # Options:
        # <tt>for</tt>::       ownable model class (default: +User+)
        #
        def manage_ownership(options={})
          return if self.included_modules.include?(Fuzziness::ArOwnership::Manager::InstanceMethods)
            
          include Fuzziness::ArOwnership::Manager::InstanceMethods 
          
          class_inheritable_accessor :owner_class
            
          # before_filter usage for object (pre)loading is safe 
          prepend_before_filter  :set_owner
          append_after_filter   :reset_owner            
          
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
        end
      end
      
      module InstanceMethods
        
        private
        
        # Sets the current owner for the managed class. The method as implemented 
        # here assumes that your controller has a <tt>get_current_owner</tt> method
        # that contains the currently logged in owner.
        def set_owner #:doc:
          self.owner_class.owner= get_current_owner
        end

        # Resets the currently logged in owner for the managed class.
        def reset_owner #:doc:
          self.owner_class.reset_owner
        end

        # Returns the currently logged in owner for the managed class. The method 
        # as implemented here assumes that a RestfulAutentication generated +User+
        # model is being used as the owner. 
        # If this is not the case then
        # you will need to manually add your own implementation of +get_current_owner+ 
        # method to the private section of the controller where you are including the
        # Manager module.
        def get_current_owner #:doc:
          self.send "current_#{owner_class.name.underscore}".to_sym
        end
      end
    end
  end
end

ActionController::Base.send(:include, Fuzziness::ArOwnership::Manager) if defined?(ActionController)
