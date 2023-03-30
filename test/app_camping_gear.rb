require 'test_helper'
require 'camping'

Camping.goes :Packing

module Camping
  module Gear

    # Basically copied from Cuba, will probably modify later.
    module CSRF

      # Package Class Methods
      module ClassMethods
        # define class methods
        def secret_token
          @_secret_token ||= SecureRandom.base64(64)
        end

        def erase_token
          @_secret_token = nil
        end

        def set_secret(secret)
          @_secret_token = secret
        end
      end

      # Run a setup routine with this Gear.
      def self.setup(app, *a, &block)
        @app = app
        @app.set :secret_token, "top_secret_code"
      end

      def self.included(mod)
        mod.extend(ClassMethods)
      end

      # Adds an instance method csrf
      def csrf
        @csrf ||= Camping::Gear::CSRF::Helper.new(@state, @request)
      end

      class Helper
        attr_accessor :req
        attr_accessor :state

        def initialize(state, request)
          @state = state
          @req = request
        end
      end
    end
  end
end

module Packing
  pack Camping::Gear::CSRF

  before :Home do
    @great = "This is great"
  end

  after :Work do
    @body = "This is nice"
  end

  module Controllers
    class Home < R '/'
      def get
        (@great == "This is great").to_s
      end
    end

    class Work < R '/work'
      def get
        (@nice == "This is great").to_s
      end
    end
  end
end

class Packing::Test < TestCase

  def test_gear_packed
    list = Packing::G
    assert (list.length == 3), "Proper number of Gear was not packed! Gear: #{list.length}"
  end

  def test_right_gear_packed
    csrf_gear = "Camping::Gear::CSRF"
    assert Packing::G.map(&:to_s).include?(csrf_gear), "The correct Gear was not packed! Gear: #{csrf_gear}"
  end

  def test_instance_methods_packed
    im = Packing.instance_methods.map(&:to_s)
    assert (im.include? "csrf"), "Gear instance methods were not included: #{im}"
  end

  def test_class_methods_packed
    [:secret_token, :erase_token, :set_secret].each { |sym|
      assert (Packing.methods.include? sym), "Gear class methods were not packed, missing #{sym.to_s}."
    }
  end

  def test_setup_callback
    secret = Packing.options[:secret_token]
    assert (secret == "top_secret_code"), "Gear setup callback failed: \"#{secret}\" should be \"top_secret_code\"."
  end

  # Maybe move the Camping Filters tests somewhere else later.
  def test_before_filter
    get '/'
    assert_body "true", "Before filter did not work."
  end

  def test_after_filter
    get '/work'
    assert (body() == "This is nice"), "After filter did not work."
  end

end
