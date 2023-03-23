# This gear is originally from filtering_camping gem by judofyr, and techarc.
module Filters
	module ClassMethods
		def filters
			@_filters ||= {:before => [], :after => []}
		end

		def before(actions, &blk)
			actions = [actions] unless actions.is_a?(Array)
			actions.each do |action|
				filters[:before] << [action, blk]
			end
		end

		def after(actions, &blk)
			actions = [actions] unless actions.is_a?(Array)
			actions.each do |action|
				filters[:after] << [action, blk]
			end
		end
	end

	def self.included(mod)
		mod.extend(ClassMethods)
	end

	def self.setup(app, *a, &block) end

	def run_filters(type)
		o = self.class.to_s.split("::")
		filters = Object.const_get(o.first).filters
		filters[type].each do |filter|
			if (filter[0].is_a?(Symbol) && (filter[0] == o.last.to_sym || filter[0] == :all)) ||
				 (filter[0].is_a?(String) && /^#{filter[0]}\/?$/ =~ @env.REQUEST_URI)
				 self.instance_eval(&filter[1])
			end
		end
	end

	def service(*a)
		run_filters(:before)
		super(*a)
		run_filters(:after)
		self
	end
end
