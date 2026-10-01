# Changelog

## [Unreleased]

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
