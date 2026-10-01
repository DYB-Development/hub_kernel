# HubKernel
Gives every hub in a Rails app one way to declare what it needs from another hub.

## Usage

### Ports
A port is something a hub needs from outside itself. The hub declares it by name,
with the method its own code calls:

```ruby
module Supplies
  extend HubKernel::Ports

  port :spend_recorder, as: :record_spend
end
```

The app fills each port with any callable, usually another hub's method:

```ruby
Rails.application.config.to_prepare do
  Supplies.spend_recorder = Finance.method(:record_spend)
end
```

`Supplies.record_spend(amount: 5)` then calls what the app filled the port with and
returns its answer. An error it raises reaches the caller unchanged. Calling a port the
app left unfilled raises `HubKernel::UnwiredPortError`, such as "Supplies' spend
recorder is not wired".

## Installation
Add this line to your application's Gemfile:

```ruby
gem "hub_kernel"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install hub_kernel
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
