
# This gear adds inspection utilities to Camping
module Gear
  module Inspection

    # reserved module for Camping Class Methods we add because we're the best.
    module ClassMethods

    end

    module ControllersClassMethods
      # All Helper helps us inspect our Controllers from outside of the app.
      # TODO: Move to CampTools for introspection.
      def all
        all = []
        constants.map { |c|
          all << c.name if !["I", "Camper"].include? c.to_s
        }
        all
      end
    end

    def self.included(mod)
      mod.extend(ClassMethods)
      mod::Controllers.extend(ControllersClassMethods)
    end

    # empty setup as determined by the Camping Gear Spec API.
    def self.setup(app, *a, &block) end

  end
end
