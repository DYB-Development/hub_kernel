# HubKernel
Gives every hub in a Rails app one way to declare what it needs from another hub.

## Usage

### Starting a hub
A hub usually lives in a domain gem, next to the domain logic it serves. Run the
generator from the gem's root, naming each port as the port and the method the hub's
own code calls:

```bash
bin/rails generate hub_kernel:hub Ledger entry_recorder:record_entry
```

Inside a Rails engine gem it writes the hub under the gem's namespace, such as
`app/models/billing/ledger.rb` with `module Billing::Ledger`, which extends
`HubKernel::Ports` and declares each port. It also adds hub_kernel to the gem's
gemspec. It writes no hub check into the gem's tests, since the gem never fills its own
ports.

### Using a hub from a gem
The app that installs the gem fills each of the hub's ports in its own setup, then
runs the start check:

```ruby
Rails.application.config.to_prepare do
  Billing::Ledger.entry_recorder = Finance.method(:record_entry)
  HubKernel::Hubs.check!
end
```

The app's own test for that hub includes the hub check, where the ports are filled:

```ruby
class Billing::LedgerHubTest < ActiveSupport::TestCase
  include HubKernel::Conformance::Hub

  hub { Billing::Ledger }
end
```

Run inside an app rather than a gem, the generator writes the hub under
`app/models` and its hub check under `test/models`.

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

### The start check
Every hub that declares a port is on `HubKernel::Hubs.list`. Call
`HubKernel::Hubs.check!` after the app fills its ports, and the app refuses to start
while any port is unfilled:

```ruby
Rails.application.config.to_prepare do
  Supplies.spend_recorder = Finance.method(:record_spend)
  HubKernel::Hubs.check!
end
```

It raises `HubKernel::UnwiredPortError` naming every unfilled port with its hub, one per
line. Running it inside `to_prepare` checks again after every code reload, and a hub
declared again on a reload stays on the list once.

### The hub check
A hub's own test can check that the app filled every one of its ports, so a missing
fill shows in the suite rather than on the next start:

```ruby
require "hub_kernel/conformance/hub"

class SuppliesHubTest < ActiveSupport::TestCase
  include HubKernel::Conformance::Hub

  hub { Supplies }
end
```

The test fails and names each port the app left unfilled, and each port filled with
something that cannot be called.

### The exposed list
A hub names each method outside callers may reach, the values it takes, and whether it
writes. A layer such as a JSON endpoint looks a method up by name and serves only what
the hub exposes:

```ruby
module Supplies
  extend HubKernel::Exposes

  exposes :record_purchase, takes: %i[supplier_id bought_on lines], writes: true
end

Supplies.exposed("record_purchase").takes # => [:supplier_id, :bought_on, :lines]
Supplies.exposed("delete_everything")     # => nil
```

### The exposed-list check
A hub's own test can check its exposed list, so a listed method the hub lacks, or one
listed with values it does not take, shows in the suite rather than on a caller's
request:

```ruby
require "hub_kernel/conformance/exposed"

class SuppliesHubTest < ActiveSupport::TestCase
  include HubKernel::Conformance::Exposed

  hub { Supplies }
end
```

The test fails and names each problem. A method that takes `**` values accepts any
values it is listed with, as long as it is listed with each value it requires.

### The crossing check
A host's test can check that no hub's code names a class another hub owns. The host
passes a map of which classes each hub owns, and the test fails listing each file and
the class it names:

```ruby
require "hub_kernel/conformance/crossings"

class HubCrossingsTest < ActiveSupport::TestCase
  include HubKernel::Conformance::Crossings

  crossings files: "app/{models,controllers,jobs,views}/shop/**/*.{rb,erb}", except: [ "app/models/shop/hubs.rb" ] do
    HubKernel::Crossings.new(
      owners: { supplies: %w[Shop::Purchase Shop::PurchasesController], finance: %w[Shop::Expense], shop: %w[Shop::Home] },
      shared: %w[Shop::BaseController],
      host_layer: :shop,
      interfaces: { supplies: "Shop::Hubs::Supplies", finance: "Shop::Hubs::Finance" }
    )
  end
end
```

- A constant inside another hub's class counts as naming that class.
- A name no hub owns, such as a namespace, is not a crossing, and neither is a class on
  the `shared` list.
- A view belongs to the hub that owns its controller, then to the hub that owns the
  record its folder is named after, and otherwise to the `host_layer`.
- The host's layer may name any hub's interface module, and a hub naming another hub's
  interface module is a crossing.

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
