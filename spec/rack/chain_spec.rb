require File.expand_path('../../spec_helper', __FILE__)

describe Rack::Chain do
  let(:env) { Hash.new }

  let(:app) { app_dummy.new }

  let(:chain) { Rack::Chain.new(app) }

  let(:filter_names) { %w(Foo Bar Baz) }

  let(:filters) { filter_names.map {|x| filter_dummy(x) } }

  let(:full_chain) { chain.tap {|c| c.filters += filters } }

  it "has an ordered list of filters" do
    full_chain.filters.should == filters
  end

  it "calls each filter in order" do
    full_chain.call(env)[2].should == ["App", *filter_names.reverse]
  end

  context Rack::Chain::Linker, "#to_app" do
    let(:builder) do
      Rack::Builder.new do
        extend Rack::Chain::Linker
      end.tap do |builder|
        filters.each do |filter|
          builder.use filter
        end
        builder.run app
      end
    end

    it "overrides Rack::Builder#to_app to create a Rack::Chain" do
      builder.to_app.should be_instance_of(Rack::Chain)
    end

    it "calls each filter in order" do
      builder.to_app.call(env)[2].should == ["App", *filter_names.reverse]
    end
  end

  context "with a large set of middleware" do
    let(:number_of_filters) { 100 }

    let(:filter_names) { (1..number_of_filters).map {|n| "Filter#{n}" } }

    let(:filters) { filter_names.map {|x| filter_dummy(x) { caller.size } } }

    # Skip the call stack size for the app
    let(:app) { app_dummy { nil }.new }

    it "the call stack size stays constant" do
      call_stack_sizes = full_chain.call(env)[2].compact
      call_stack_sizes.max.should == call_stack_sizes.min
    end

    context "but using normal Rack::Builder" do
      let(:builder) do
        Rack::Builder.new.tap {|builder|
          filters.each do |filter|
            builder.use filter
          end
          builder.run app
        }
      end

      it "the call stack size grows with each layer" do
        call_stack_sizes = builder.call(env)[2].compact
        call_stack_sizes.max.should > number_of_filters
      end
    end
  end
end
