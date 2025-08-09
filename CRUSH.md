# Momentum Project Quickstart

This document provides essential commands and guidelines for developing in the Momentum codebase.

## Common Commands

- **Build**: `xcodebuild build -scheme Momentum -destination 'platform=iOS Simulator,name=iPhone 14'`
- **Run all tests**: `xcodebuild test -scheme Momentum -destination 'platform=iOS Simulator,name=iPhone 14'`
- **Run a single test**: `xcodebuild test -scheme Momentum -destination 'platform=iOS Simulator,name=iPhone 14' -only-testing:MomentumTests/YourTestClassName/testYourFunction`
- **Lint**: `swiftlint` (assuming SwiftLint is installed and configured)

## Code Style

- **Formatting**: Adhere to the default Xcode formatting. Use SwiftLint for consistency.
- **Naming**: Use UpperCamelCase for types and protocols, lowerCamelCase for variables and functions.
- **Imports**: Import specific modules rather than the entire library.
- **Types**: Use Swift's type inference where possible, but explicitly state types for clarity in public APIs.
- **Error Handling**: Use Swift's `do-catch` statements and the `Result` type for robust error handling.
- **Documentation**: Write documentation comments for public APIs.