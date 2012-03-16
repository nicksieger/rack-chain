# Rack::Chain

Rack::Chain uses fibers to minimize stack depth in Rack applications.

A Rack application assembled with Rack::Chain runs each middleware
`#call` in a separate fiber, thereby avoiding deep stacks.

The name "chain" comes from `javax.servlet.FilterChain`, which is the
equivalent pattern to Rack middleware in the Java Servlet API.

Until the Rack API morphs into a before/after pattern which would
allow decomposing the request pipeline into a flat sequence of
function applications over a request and a response, these kinds of
cheeky gyrations may be necessary.

## Requirements

Because Rack::Chain relies on fibers for its operation, Ruby 1.9 is
required.

## Usage

To use Rack::Chain with existing Rack applications, place the
following lines in your `config.ru`:

```ruby
require 'rack/chain'
extend Rack::Chain::Linker
```

