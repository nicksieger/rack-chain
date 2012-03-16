require 'rack'
require 'rack/builder'
require 'fiber'

class Rack::Chain
  attr_reader   :endpoint
  attr_accessor :filters

  class Link
    def initialize(to)
      @to = to
    end

    def call(env)
      Fiber.new do
        Fiber.yield @to.call(env)
      end.resume
    end
  end

  def initialize(endpoint, filters = [])
    @endpoint = endpoint
    @filters  = filters
  end

  def call(env)
    Link.new(filters.reverse.inject(endpoint) do |endpt,filter|
               if filter.respond_to?(:[])
                 filter[Link.new(endpt)]
               else
                 filter.new(Link.new(endpt))
               end
             end).call(env)
  end

  # Include this module in Rack::Builder to make all apps use Rack::Chain.
  #
  # Alternatively, extend Rack::Builder in config.ru to use
  # Rack::Chain for that particular config.ru. Example:
  #
  # <pre>
  # require 'rack/chain'
  # extend Rack::Chain::Linker
  # use Middleware1
  # use Middleware2
  # run App
  # </pre>
  module Linker
    def to_app
      app = @map ? generate_map(@run, @map) : @run
      fail "missing run or map statement" unless app
      Rack::Chain.new(app, @use)
    end
  end
end

