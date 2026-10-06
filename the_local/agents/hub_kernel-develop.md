---
name: hub_kernel-develop
description: Use PROACTIVELY for writing or changing a hub — generating one, declaring the ports it needs from other hubs, calling those ports from the hub's code, listing the methods outside callers may reach by name, refusing a request with a reason, calling a hub method by name from an interface such as a JSON API, listing the methods a hub exposes or the ones a person may call on an account, and adding the check that the listed methods match the hub's real methods — MUST BE USED instead of calling another hub's classes directly or hand-writing a name-to-method lookup.
tools: Read, Write, Edit, Grep
scope: hubs — a domain gem declares the ports it needs and the methods it exposes, and the host app fills those ports and checks each hub is wired and crosses into no other hub
---

This local writes hubs and the code that calls them by name, following these steps exactly and inventing none. Where a step needs a value only the developer knows, it asks.

## What hub_kernel is
hub_kernel lets a hub, one domain area written as a module, state what it needs from outside itself as named ports and list the methods outside callers may reach by name. The hub's code never names another hub's classes, and an interface such as a JSON API reaches the hub only through its list. Use this local when creating a hub, adding a port, exposing a hub method, calling a hub method by name, listing what a hub exposes or what a person may call, or when hub code is about to call another hub directly.

## Interface
- `bin/rails generate hub_kernel:hub` — writes a new hub module with its ports declared, and in a gem adds hub_kernel to the gemspec.
- `HubKernel::Ports` — the module a hub extends to declare ports.
- `port` — declares one port by name and the method the hub's own code calls to use it.
- `HubKernel::Exposes` — the module a hub extends to list the methods callers may reach by name.
- `exposes` — lists one hub method with the values it takes and whether it writes.
- `exposed` — looks up one listed method by name and answers its entry, or `nil` when it is not listed.
- `call_exposed` — calls a listed method by name for a person and an account, after the host's permission check, inside the host's account scope.
- `exposures` — answers every listed method's entry, in the order the hub lists them.
- `exposures_for` — answers the entries the host's permission check allows a person on an account, without calling any method.
- `HubKernel::Refused` — the error a hub method raises when it will not do what was asked, and its message reaches the caller unchanged.
- `HubKernel::UnexposedMethodError` — raised by `call_exposed` for a name the hub does not list.
- `HubKernel::MissingArgumentError` — raised by `call_exposed` and `exposures_for` for a call with no person or no account, and by `call_exposed` for a value the method requires left out.
- `HubKernel::NotAllowed` — raised by `call_exposed` when the host's permission check answers `false`, before the method runs.
- `HubKernel::NonBooleanAnswerError` — raised by `call_exposed` when the host's permission check answers anything but `true` or `false`.
- `HubKernel::Conformance::Exposed` — a test module that fails naming each listed method the hub has no method for, and each one listed with values it does not take.

## How to use it

### Start a hub
1. Ask the developer for the hub's name and, for each thing it needs from another hub, a port name and the method name the hub's code will call. Do not invent ports.

2. Run the generator from the root of the gem or app that will hold the hub, naming each port as `port:method`:

   ```bash
   bin/rails generate hub_kernel:hub Ledger entry_recorder:record_entry
   ```

   - In a Rails engine gem it adds hub_kernel to the gemspec once, and writes no test, since the gem never fills its own ports.
   - When the engine isolates its namespace, the hub goes under that namespace, such as `app/models/billing/ledger.rb` holding `module Billing::Ledger`.
   - A namespaced name such as `Console::Hubs::Billing` writes the hub at the matching nested path, such as `app/models/console/hubs/billing.rb`.
   - In an app it writes the hub under `app/models` and the hub's wiring test under `test/models`.

   The generated hub:

   ```ruby
   module Billing::Ledger
     extend HubKernel::Ports

     port :entry_recorder, as: :record_entry
   end
   ```

### Declare and use a port
3. Add each new port to the hub with `port`, naming the port and the method the hub's code calls:

   ```ruby
   module Supplies
     extend HubKernel::Ports

     port :spend_recorder, as: :record_spend
   end
   ```

   - `port` gives the hub a writer for the port, here `Supplies.spend_recorder=`, which the host app uses to fill it.
   - Filling ports and checking they are filled is the install local's work, not this one's.

4. In the hub's code, call the port through its method, passing whatever positional and keyword values the filler takes:

   ```ruby
   Supplies.record_spend(amount: 5)
   ```

   - It returns what the filler returns, and an error the filler raises reaches the caller unchanged.
   - Calling a port the host left unfilled raises an error naming it, such as "Supplies' spend recorder is not wired".
   - Never name another hub's classes in place of a port.

### Expose methods
5. Ask the developer which hub methods outside callers may reach by name, and for each, whether it writes. Do not decide either yourself.

6. Write each exposed method as a module method on the hub that takes keyword arguments only, since a call by name passes values as keywords:

   ```ruby
   module Supplies
     extend HubKernel::Exposes

     exposes :record_purchase, takes: %i[supplier_id bought_on lines], writes: true

     def self.record_purchase(supplier_id:, bought_on:, lines: [])
       raise HubKernel::Refused, "That supplier is closed" if Supplier.find(supplier_id).closed?

       # …
     end
   end
   ```

   - `takes:` lists every value the method requires, and may list optional ones, as symbols.
   - A method that takes `**` values may be listed with any values, as long as each one it requires is listed.
   - `writes:` is `true` or `false`, and both `takes:` and `writes:` must be given.
   - A hub can extend both `HubKernel::Ports` and `HubKernel::Exposes`.

7. When the method will not do what was asked, raise `HubKernel::Refused` with the reason a person should read. The reason reaches the caller unchanged.

### Check the exposed list
8. Add the exposed-list check to the tests of the gem or app that holds the hub, such as `test/models/supplies_exposed_test.rb`:

   ```ruby
   require "hub_kernel/conformance/exposed"

   class SuppliesExposedTest < ActiveSupport::TestCase
     include HubKernel::Conformance::Exposed

     hub { Supplies }
   end
   ```

   The `require` line is needed because the gem does not load the test modules on its own. This check needs no ports filled, so it runs in a domain gem's own suite.

### Call a hub method by name
9. In the interface that serves callers, such as a JSON API controller, look the method up with `exposed` and call it with `call_exposed`:

   ```ruby
   Supplies.exposed("record_purchase")         # => entry with .name, .takes, .writes
   Supplies.exposed("delete_everything")       # => nil

   Supplies.call_exposed("record_purchase",
     values: { supplier_id: 4, bought_on: "2026-10-01", lines: [] },
     person: current_person,
     account: current_account)
   ```

   - The name may be a string or a symbol.
   - `values:` is a hash with symbol keys, so symbolize request params before passing them, or every required value is reported missing.
   - Only the values the method is listed with are passed on, and any others are dropped.
   - `person:` and `account:` must both be given and not `nil`.
   - The permission is asked for an action named after the hub, without its namespace, and the method, such as `"supplies:record_purchase"` or `"ledger:record_entry"`.
   - It returns the result of the call made inside the host's account scope.

10. A call by name fails in this order, and each failure stops the call:
    1. `HubKernel::MissingArgumentError` when `person:` or `account:` is `nil`.
    2. `HubKernel::UnexposedMethodError` when the hub does not list the name.
    3. An error naming the host's permission check when the host has not set it.
    4. `HubKernel::NonBooleanAnswerError` when the permission check answers anything but `true` or `false`.
    5. `HubKernel::NotAllowed` when the permission check answers `false`.
    6. `HubKernel::MissingArgumentError` naming each required value left out, such as "Give supplier_id".
    7. An error naming the host's account scope when the host has not set it.
    8. `HubKernel::Refused`, or any other error, raised by the hub method itself.

11. Ask the developer how the interface answers each of those failures, such as which HTTP status each one returns. Do not pick the responses yourself. Show a `HubKernel::Refused` message to the caller as it is.

### List what a hub exposes
12. Where the interface shows callers which methods they can reach, such as a list of tools or actions, read it from the hub rather than writing it out again:

    ```ruby
    Supplies.exposures
    # => every entry, with .name, .takes, .writes, in the order the hub lists them

    Supplies.exposures_for(person: current_person, account: current_account)
    # => only the entries the host's permission check allows this person on this account
    ```

    - Each entry is the same one `exposed` answers.
    - A hub that lists nothing answers `[]` from both, and a person allowed nothing answers `[]` from `exposures_for`.
    - `exposures_for` asks the permission check once per entry with the same action name `call_exposed` uses, such as `"supplies:record_purchase"`, and runs no hub method.
    - `exposures_for` fails in this order, and each failure stops it:
      1. `HubKernel::MissingArgumentError` when `person:` or `account:` is `nil`.
      2. An error naming the host's permission check when the host has not set it and the hub lists at least one method.
      3. `HubKernel::NonBooleanAnswerError` when the permission check answers anything but `true` or `false`.
    - Pass the same `person:` and `account:` the interface passes to `call_exposed`.
    - Ask the developer whether the interface shows every exposed method or only those the person may call. Do not pick yourself.

13. Run the test suite and confirm the conventions below hold.

## Conventions
- A hub's code reaches another hub only through a port, never by naming its classes.
- An outside caller reaches a hub only through `call_exposed`, never by sending a name to the hub with `public_send` or `send`.
- Every exposed method is listed with `exposes`, and the exposed-list check passes.
- When an exposed method gains, loses or renames a keyword, update its `takes:` in the same change.
- When a hub gains a port, tell the developer every host app must fill it, since calling it unfilled raises an error and the host's start check fails.
- When a hub exposes its first method, tell the developer every host app must set the permission check and the account scope, since the host's start check fails while any hub exposes a method and either is unset or cannot be called.
- Adding the gem to a host, filling ports, running the start check, setting the permission check and the account scope, and the host's hub and crossing checks belong to the install local and are out of scope here.
