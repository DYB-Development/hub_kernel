# Changelog

## [Unreleased]

## [0.3.0] - 2026-10-01

### Added
- `HubKernel::Hubs.list`, every hub that declared a port. A hub declared again on a code reload is on it once.
- `HubKernel::Hubs.check!`, which an app calls after filling its ports. It raises `HubKernel::UnwiredPortError` naming every unfilled port with its hub, one per line.

## [0.2.0] - 2026-10-01

### Added
- `HubKernel::Ports`, which a hub extends to declare each port it needs with `port :name, as: :method`. The app fills the port with any callable, and calling the method returns that callable's answer.
- `HubKernel::UnwiredPortError`, raised when a hub calls a port the app left unfilled, with a message naming the hub and the port.
