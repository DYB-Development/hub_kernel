---
name: hub_kernel-install
description: Use to hook hub_kernel into a project — adding the gem, filling each hub's ports and running the start check, listing the loaded hubs, setting the permission check and the account scope, and adding the hub check and the crossing check to the host's tests.
tools: Bash, Read, Edit
scope: hubs — a domain gem declares the ports it needs and the methods it exposes, and the host app fills those ports and checks each hub is wired and crosses into no other hub
---

This local follows these steps exactly and invents none. Where a step needs a value only the developer knows, it asks.

## What hub_kernel is
hub_kernel lets a Rails host app fill the ports each hub declares, refuse to start while a port is unfilled, answer permission and account scope for calls made by name, answer permission when an interface lists what a person may call, and fail its suite when one hub's code names a class another hub owns. Hook it in when the app uses hubs, its own or ones shipped in domain gems.

## Interface
- `gem "hub_kernel"` — the Gemfile line that adds the gem to the host app.
- `HubKernel::Hubs.check!` — raises `HubKernel::UnwiredPortError` naming every unfilled port of every loaded hub, one per line, such as "Supplies' spend recorder is not wired", and, while any loaded hub exposes a method, the permission check or the account scope when either is unset or cannot be called.
- `HubKernel::Hubs.list` — the hubs that have loaded and declared at least one port or exposed at least one method.
- `HubKernel::UnwiredPortError` — raised by the start check, by calling an unfilled port, by a call by name while the permission check or the account scope is unset, and by listing what a person may call from a hub that exposes at least one method while the permission check is unset.
- `HubKernel::Authz.check` — the host-wide permission rule, a callable taking a person, an action and an account and answering `true` or `false`.
- `HubKernel::Context.scope` — the host-wide account scope, a callable taking an account and a block and running the block inside that account.
- `HubKernel::Conformance::Hub` — a test module that fails naming each of one hub's ports left unfilled or filled with something that cannot be called.
- `HubKernel::Crossings` — the crossing map: which classes each hub owns, the shared classes, the host's layer, each hub's interface module, and any namespace a hub owns whole.
- `HubKernel::Conformance::Crossings` — a test module that reads the host's files against the crossing map and fails on each crossing, each unowned class, each class owned twice, and each mapped class that does not exist.

## How to use it
1. Add the gem to the host's `Gemfile`, then run `bundle install`:

   ```ruby
   gem "hub_kernel"
   ```

2. List the hubs the app uses and each port they declare. Ask the developer what fills each port, such as another hub's method. Do not pick a filler yourself.

3. Fill every port and run the start check in a `to_prepare` block in an initializer, such as `config/initializers/hubs.rb`, so both run again after every code reload:

   ```ruby
   Rails.application.config.to_prepare do
     Supplies.spend_recorder = Finance.method(:record_spend)
     Billing::Ledger.entry_recorder = Finance.method(:record_entry)
     HubKernel::Hubs.check!
   end
   ```

   A port accepts any object that responds to `call`. The start check only sees hubs that have loaded, so name every hub in this block. Run `HubKernel::Hubs.list` in `bin/rails console` to see which hubs it saw.

4. Run `bin/rails runner 'HubKernel::Hubs.check!'`. If the error names "hub_kernel's permission check" or "hub_kernel's account scope", a loaded hub exposes a method and step 5 is required. If it names neither, skip to step 6.

5. Ask the developer for the app's permission rule and the account scope, since neither has a default. Set both in the same `to_prepare` block, before the start check:

   ```ruby
   Rails.application.config.to_prepare do
     Supplies.spend_recorder = Finance.method(:record_spend)
     HubKernel::Authz.check = ->(person, action, account) { Permissions.allow?(person, action, account) }
     HubKernel::Context.scope = ->(account, &call) { Current.set(account: account, &call) }
     HubKernel::Hubs.check!
   end
   ```

   - While any loaded hub exposes a method, the start check refuses to start until both are set to something that responds to `call`.
   - The permission check answers both a call by name and a listing of what a person may call, so the two always agree.
   - Listing what a person may call needs only the permission check, while a call by name needs both.
   - The action is a string made of the hub's own name, without its namespace and in snake case, then the method, such as `"supplies:record_purchase"` for `Shop::Supplies`.
   - The permission check must answer exactly `true` or `false`, and any other answer makes the call or the listing raise an error.
   - The account scope must take the block and run it, or the hub method never runs.

6. Add one hub check to the host's tests for each hub that declares at least one port, such as `test/hubs/supplies_hub_test.rb`:

   ```ruby
   require "hub_kernel/conformance/hub"

   class SuppliesHubTest < ActiveSupport::TestCase
     include HubKernel::Conformance::Hub

     hub { Supplies }
   end
   ```

   - The `require` line is needed because the gem does not load the test modules on its own.
   - A hub that exposes methods but declares no port gets no hub check, since the check errors on a hub with no ports.

7. Ask the developer for the crossing map, since only they know which hub owns which class:
   - which classes each hub owns;
   - which classes all hubs share, such as a base controller;
   - which hub name stands for the host's own layer;
   - each hub's interface module;
   - any namespace a hub owns whole, such as a hub gem's `Billing`.

   Also ask which files the check should read, and which to skip, such as the file that defines the interface modules.

8. Add the crossing check to the host's tests, such as `test/hub_crossings_test.rb`:

   ```ruby
   require "hub_kernel/conformance/crossings"

   class HubCrossingsTest < ActiveSupport::TestCase
     include HubKernel::Conformance::Crossings

     crossings files: "app/{models,controllers,jobs,views}/shop/**/*.{rb,erb}", except: [ "app/models/shop/hubs.rb" ] do
       HubKernel::Crossings.new(
         owners: { supplies: %w[Shop::Purchase Shop::PurchasesController], finance: %w[Shop::Expense], shop: %w[Shop::Home] },
         shared: %w[Shop::BaseController],
         host_layer: :shop,
         interfaces: { supplies: "Shop::Hubs::Supplies", finance: "Shop::Hubs::Finance" },
         namespaces: { billing: %w[Billing] }
       )
     end
   end
   ```

   - `files:` is a glob read from `Rails.root`, and defaults to `"app/**/*.{rb,erb}"`.
   - `root:` changes the folder the glob is read from.
   - `except:` lists paths to skip, written relative to that folder.
   - Hub names are symbols, and class names are strings.

9. Run the app and the test suite, and confirm the checks below.

## Conventions
- After installing, `bin/rails runner 'HubKernel::Hubs.check!'` exits with no error, and every hub check and the crossing check pass.
- The start check reports unfilled ports, and the permission check or account scope when unset or not callable while a hub exposes a method.
- The hub check reports one hub's unfilled ports and each port filled with something that cannot be called, which the start check does not report.
- A domain gem never runs the hub check, since it never fills its own ports, so the hub check always lives in the host's tests.
- A view belongs to the hub that owns its controller, then to the hub that owns the record its folder is named after, and otherwise to the host's layer.
- A constant inside another hub's class counts as naming that class.
- A hub's interface module may be named by the host's layer and by that hub, and by no other hub.
- A class listed by name under `owners` belongs to that hub even inside another hub's namespace.
- The check for unowned classes reads only Ruby files outside `app/views`, so a view never needs its own entry in the map.
- The crossing check fails with "The crossing check found no files to read" when its `files:` pattern matches nothing the map owns, so fix the pattern or the map rather than the test.
- When a hub gains a port, fill it in the `to_prepare` block. When a hub first exposes a method, set the permission check and the account scope there too. When a class is added, renamed or removed, update the crossing map, since the check fails on a class no hub owns and on a mapped class that no longer exists.
- Writing a hub, declaring its ports, and listing the methods it exposes are not part of installing and are out of scope here.
