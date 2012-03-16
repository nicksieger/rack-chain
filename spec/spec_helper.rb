require 'bundler/setup'
require 'rspec'
require 'rack/chain'

module Rack::Chain::Fixtures
  class FilterDummy
    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env).tap do |result|
        result[2] ||= []
        result[2] << body if body
      end
    end

    def body
      self.class.name.split(/::/)[-1]
    end
  end

  class AppDummy
    def call(env)
      [200, {"Content-Type" => "text/plain"}, [body]]
    end

    def body
      self.class.name.split(/::/)[-1]
    end
  end

  module Dummies
  end

  def reset_fixtures
    Dummies.class_eval do
      constants.each {|c| remove_const(c) }
    end
  end

  def filter_dummy(name = "Foo", &block)
    Dummies.const_set(name, Class.new(FilterDummy) do
                        define_method(:body, &block) if block
                      end)
  end

  def app_dummy(name = "App", &block)
    Dummies.const_set(name, Class.new(AppDummy) do
                        define_method(:body, &block) if block
                      end)
  end
end

RSpec.configure do |config|
  config.include Rack::Chain::Fixtures
  config.after :each do
    reset_fixtures
  end
end
