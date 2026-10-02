# Changelog

## [Unreleased]

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
