# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

HPNetwork is a protocol-based Swift networking library using Swift Package Manager. It produces two library targets: `HPNetwork` (core) and `HPNetworkMock` (testing utilities). The sole external dependency is Apple's `swift-http-types`.

**Platforms**: iOS 15+, tvOS 15+, watchOS 6+, macOS 12+
**Swift tools version**: 6.0

## Commands

```bash
# Build
swift build

# Run all tests
swift test

# Run a single test target
swift test --filter HPNetworkTests
swift test --filter HPNetworkMockTests

# Format code
Scripts/format-swift-code

# Lint (CI uses this — must pass before merge)
Scripts/lint-swift-code

# Dead code detection
periphery scan --config config/periphery.yml

# Build documentation
Scripts/build-docc-archive
```

## Architecture

The library is built on a protocol hierarchy for requests:

- `NetworkRequest<Output>` — base protocol, defines URL, method, headers, auth, cache policy
  - `DataRequest<Output>` — adds `convertResponse(_:)` to transform raw `Data`
    - `DecodableRequest<Output: Decodable>` — auto-decodes JSON via configurable `JSONDecoder`
  - `DownloadRequest` — downloads to file (`Output == URL`)

`NetworkClient` (conforming to `NetworkClientProtocol`) executes requests. Each request builds its own `URLRequest` internally. Responses are wrapped in `NetworkResponse<Output>` which includes timing metadata (`networkingDuration`, `processingDuration`).

### Mocking (HPNetworkMock)

Two levels of mocking:

1. **High-level**: `NetworkClientMock` + `NetworkRequestMockStore` (actor) — mock at the request protocol level. Register expected responses per request type.
2. **Low-level**: `URLSessionMock` + `URLRequestMockStore` (Mutex-protected) — mock via `URLProtocol`, intercepts actual URL loading. Requires macOS 15+ / iOS 18+.

### Key patterns

- **Result builder**: `@HTTPFieldBuilder` for declarative HTTP header composition
- **Sendable throughout**: all request/response types conform to `Sendable`; mock stores use actors or `Synchronization.Mutex`
- **Authorization**: protocol `Authorization` with built-in `BasicAuthorization` and `BearerAuthorization`

## Code Style

Formatting is enforced by `swift-format` with config at `config/swift-format.json`:

- 4-space indentation, 140-char line length
- `NeverForceUnwrap` and `NeverUseForceTry` are enabled — no `!` unwrapping
- File-scoped declarations use `private` (not `fileprivate`)
- Use `///` for documentation comments
- Ordered imports
