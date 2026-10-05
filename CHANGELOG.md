# Changelog

## [Unreleased]

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
