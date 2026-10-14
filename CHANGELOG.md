# Changelog

## [Unreleased]

### Added
- At boot and after each code reload, hub_kernel loads every hub module in the host's hub folders, so the start check checks it and hub_kernel-interface serves it even when nothing else names it. The loading runs before the host's own `to_prepare` code fills ports.
- `HubKernel::HubFolders.hub_modules(root)` names the class of every hub module in the hub folders under `root`, and the crossing check finds hub modules by the same rule.

## [0.23.0] - 2026-10-14

### Added
- A hub answers `port_names` with the names of the ports it declares, in the order it declares them.
- Kept ports: a test that requires `hub_kernel/kept_ports` and includes `HubKernel::KeptPorts` has every port of the hubs it names in `keep_ports { [ Sales, Finance ] }` filled after each test as it was before it. A test that names no hubs keeps the ports of the hub it names in `hub { ... }` for the hub check.
- `HubKernel::HubFolders.hub_of_controller(root, page)` returns the hub whose folder holds `<page>_controller.rb`, returns nil when no hub folder holds it, and raises `HubKernel::HubFolders::SharedController` naming each folder when several hold it.

## [0.22.0] - 2026-10-14

### Added
- Record saving: a hub that extends `HubKernel::Records` gets two private methods, `saved` and `removed`, that save or delete a record and return its id, or raise `HubKernel::Refused` with the record's error messages joined into one sentence.

## [0.21.0] - 2026-10-13

### Added
- A hub folder may hold several hub modules, and the crossing check counts every one of them as that hub's interface module.

## [0.20.0] - 2026-10-13

### Added
- The crossing check fails naming each folder under `hubs/` that holds no hub module.
- The crossing check reports a class the host's list gives one hub while its file sits in another hub's folder as owned by two hubs, and fails naming each listed class already in its own hub's folder. A class in a hub folder is never reported as missing.
- The crossing check finds a hub's interface module in its folder, as the module that extends `HubKernel::Ports` or `HubKernel::Exposes`, so a hub in a folder needs no `interfaces` entry.
- A hub folder's `views` are searched after the host's own, and its `helpers` join the host's helper paths.
- The crossing check gives a file under `hubs/<hub>/`, and each class defined there, to that hub without an entry in `owners`. Naming a class from another hub's folder is a crossing.
- The crossing check reads every `.rb` and `.erb` file under each hub folder's `app/` by default.
- A hub in the host app can keep its code in `hubs/<hub>/app/<kind>/`. Each of those folders is added to the host's load and eager load paths, so its classes load by their full names. Files under a hub's `lib/` folder are not loaded.

### Changed
- Run in an app, the hub generator writes the hub into `hubs/<hub>/app/models/` and its hub check into `test/hubs/<hub>/`. Run inside a gem it writes what it did before.
- `owners:` is optional on `HubKernel::Crossings`.

## [0.19.0] - 2026-10-06

### Changed
- hub_kernel depends on hub_kernel-interface, which now holds `HubKernel::Exposes`, `HubKernel::Authz`, `HubKernel::Context` and the errors they raise, under the same names. A hub and a host change nothing.
- `HubKernel::Hubs.list` reads hub_kernel-interface's record of hubs that expose methods alongside the hubs that declare ports.

## [0.18.0] - 2026-10-06

### Removed
- `HubKernel::Context::Null`, the context with a fixed actor and tenant. `HubKernel::Context.scope`, set once by the host, replaces it.
- `gates` and `gated_actions` on a hub that included `HubKernel::Authz`, and the per-object `allowed?(actor, action)` it asked of a policy. `HubKernel::Authz.check`, set once by the host and asked on every call by name, replaces them.

## [0.17.0] - 2026-10-06

### Added
- The start check names the permission check or the account scope when either is unset or cannot be called while any hub exposes a method.
- A hub that exposes a method is on `HubKernel::Hubs.list`, as a hub that declares a port is.

## [0.16.0] - 2026-10-05

### Added
- `exposures` on a hub, which gives every entry it exposes with its name, the values it takes and whether it writes.
- `exposures_for(person:, account:)` on a hub, which gives only the entries the host's permission check allows that person on that account.

## [0.15.0] - 2026-10-05

### Added
- hub_kernel is a the_local provider: installing it gives an app its info, install and develop agents.

## [0.14.0] - 2026-10-05

### Added
- A `namespaces:` option on `HubKernel::Crossings`, which gives a hub every class under a namespace. A class listed by name in `owners` wins over another hub's namespace.

## [0.13.0] - 2026-10-05

### Added
- `missing_classes` on `HubKernel::Crossings`, naming each class the map names that does not resolve to a constant.
- The crossing check fails naming each class the map names that does not exist in the app.

## [0.12.0] - 2026-10-04

### Added
- `unowned_classes(paths)` and `claimed_twice` on `HubKernel::Crossings`.
- The crossing check fails naming each class defined in the files it reads that no hub owns, and each class the map gives to two hubs.

## [0.11.0] - 2026-10-04

### Added
- `call_exposed(name, values:, person:, account:)` on a hub, which calls an exposed method by name with only the values it is listed with.
- `HubKernel::UnexposedMethodError`, raised for a name a hub does not expose.
- `HubKernel::Refused`, which a hub raises with a reason when it will not do what was asked.
- `HubKernel::Authz.check`, which every call by name asks with the person, the action and the account, raising `HubKernel::NotAllowed` when it refuses.
- `HubKernel::Context.scope`, which every permitted call by name runs inside for the account it names.
- `belongs?(path)` on `HubKernel::Crossings`, which says whether a file belongs to a hub or the host's layer.

### Fixed
- The crossing check fails with "The crossing check found no files to read" when none of the files it read belongs to the map.
- A clean crossing check counts as an assertion, so it no longer warns that the test is missing assertions.

## [0.10.0] - 2026-10-02

### Added
- `HubKernel::Crossings`, which takes a map of the classes each hub owns, a shared list, the host's layer and each hub's interface module, and lists the classes a file names that another hub owns.
- `HubKernel::Conformance::Crossings`, which a host's test includes with `crossings { HubKernel::Crossings.new(...) }`. It reads the files the host names and fails listing each file and the class it names.

## [0.9.0] - 2026-10-02

### Added
- `HubKernel::Conformance::Exposed`, which a hub's test includes with `hub { Supplies }`. The test fails and names each exposed method the hub lacks, and each one listed with values it does not take.
- `exposure_problems` on a hub, listing each problem with its exposed list.

## [0.8.0] - 2026-10-02

### Changed
- Run inside a gem, the hub generator adds hub_kernel to the gem's gemspec, once however many hubs it generates, and writes no hub check into the gem's tests. Run inside an app it behaves as before.

## [0.7.0] - 2026-10-02

### Added
- `bin/rails generate hub_kernel:hub NAME port:method ...`, which writes a hub module that extends `HubKernel::Ports` and declares each named port, and a test for the hub that includes `HubKernel::Conformance::Hub`. A namespaced name writes both at the matching nested path.

## [0.6.0] - 2026-10-02

### Added
- `HubKernel::Exposes`, which lets a hub name each method outside callers may reach with `exposes :record_purchase, takes: [...], writes: true`.
- `exposed(name)` on a hub, which finds an exposed method by its name and gives `nil` for a name the hub does not expose.

## [0.5.0] - 2026-10-01

### Added
- `HubKernel::Conformance::Hub`, which a hub's test includes with `hub { Supplies }`. The test fails and names each port the app left unfilled, and each port filled with something that cannot be called.
- `uncallable_ports` on a hub, listing each port filled with something that cannot be called.

## [0.4.0] - 2026-10-01

### Removed
- `HubKernel::Events`, with `UndeclaredEventError` and `UnwiredEventError`. Nothing used it, and events between hubs belong to the event_engine gems.

## [0.3.0] - 2026-10-01

### Added
- `HubKernel::Hubs.list`, every hub that declared a port. A hub declared again on a code reload is on it once.
- `HubKernel::Hubs.check!`, which an app calls after filling its ports. It raises `HubKernel::UnwiredPortError` naming every unfilled port with its hub, one per line.

## [0.2.0] - 2026-10-01

### Added
- `HubKernel::Ports`, which a hub extends to declare each port it needs with `port :name, as: :method`. The app fills the port with any callable, and calling the method returns that callable's answer.
- `HubKernel::UnwiredPortError`, raised when a hub calls a port the app left unfilled, with a message naming the hub and the port.
