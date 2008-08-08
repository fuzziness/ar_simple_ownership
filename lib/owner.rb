module Fuzziness #:nodoc:
  module ArOwnership
    # Owner model extension
    module Owner
      def self.included(base) #:nodoc:
        base.extend(ClassMethods)
      end

      module ClassMethods #:nodoc:
        def acts_as_owner
          # don't allow multiple calls 
          return if self.included_modules.include?(Fuzziness::ArOwnership::Owner::InstanceMethods)
          send(:extend, Fuzziness::ArOwnership::Owner::InstanceMethods)
        end
      end

      module InstanceMethods #:nodoc:
        # Used to set the owner for a particular request. See the Ownership module for more
        # details on how to use this method.
        def owner=(object)
          Thread.current["#{self.to_s.downcase}_#{self.object_id}_owner"] = object
        end

        # Retrieves the existing owner for the current request.
        def owner
          Thread.current["#{self.to_s.downcase}_#{self.object_id}_owner"]
        end

        # Sets the owner back to +nil+ to prepare for the next request.
        def reset_owner
          Thread.current["#{self.to_s.downcase}_#{self.object_id}_owner"] = nil
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Fuzziness::ArOwnership::Owner) if defined?(ActiveRecord)
