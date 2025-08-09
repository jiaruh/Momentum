# Momentum Documentation

This document explains how to build, view, and contribute to the Momentum app documentation.

## Overview

Momentum uses Swift DocC (Documentation Compiler) to generate comprehensive documentation for all modules. The documentation includes:

- API reference for all public types and methods
- Usage examples and code snippets
- Architecture overview and module relationships
- Getting started guides

## Building Documentation

### Using Xcode

1. Open `Momentum.xcodeproj` in Xcode
2. Select **Product** → **Build Documentation** from the menu
3. Xcode will compile the documentation and open it in the Documentation Viewer

### Using Command Line

```bash
# Build documentation for all modules
swift package generate-documentation

# Build documentation for a specific module
swift package generate-documentation --target MomentumCore
```

### Hosting Documentation

To generate documentation for web hosting:

```bash
# Generate static documentation website
swift package generate-documentation --output-path ./docs

# Preview the documentation website
swift package preview-documentation --target MomentumCore
```

## Documentation Structure

```
Momentum/
├── Documentation.docc/           # Main documentation catalog
│   ├── Momentum.md              # Root documentation page
│   └── Info.plist               # Documentation configuration
├── Sources/
│   ├── MomentumCore/
│   │   └── MomentumCore.docc/   # Core module documentation
│   ├── MomentumAuthentication/
│   │   └── MomentumAuthentication.docc/  # Auth module docs
│   ├── MomentumUI/
│   │   └── MomentumUI.docc/     # UI module documentation
│   └── MomentumFeatures/
│       └── MomentumFeatures.docc/  # Features module docs
└── DOCUMENTATION.md             # This file
```

## Module Documentation

### MomentumCore
- **Purpose**: Data models and shared utilities
- **Key Types**: `Item`, `TaskPriority`
- **Documentation**: Core data structures and task management

### MomentumAuthentication
- **Purpose**: Biometric authentication services
- **Key Types**: `AuthenticationService`
- **Documentation**: Security and authentication flows

### MomentumUI
- **Purpose**: Reusable UI components
- **Key Types**: `TaskRow`, `TaskDetailView`, `EditTaskView`, `StatCard`
- **Documentation**: UI component usage and customization

### MomentumFeatures
- **Purpose**: Main app features and screens
- **Key Types**: `ContentView`, `HomeView`, `CalendarView`, `StatsView`
- **Documentation**: App architecture and feature integration

## Writing Documentation

### DocC Comments

Use triple-slash comments (`///`) for DocC documentation:

```swift
/// A task item in the Momentum app.
///
/// `Item` represents a single task with support for completion status,
/// due dates, priorities, and attachments.
///
/// ## Usage
///
/// ```swift
/// let task = Item(task: "Buy groceries")
/// task.isCompleted = true
/// ```
public final class Item {
    /// The main text description of the task.
    public var task: String
    
    /// Creates a new task item.
    ///
    /// - Parameter task: The task description.
    public init(task: String) {
        self.task = task
    }
}
```

### Documentation Guidelines

1. **Start with a brief summary** - One sentence describing the type or method
2. **Add detailed description** - Explain the purpose and behavior
3. **Include usage examples** - Show how to use the API
4. **Document parameters** - Explain each parameter's purpose
5. **Document return values** - Explain what methods return
6. **Add see-also references** - Link to related types and methods

### Markdown Features

DocC supports rich Markdown formatting:

- **Code blocks**: Use \`\`\`swift for syntax highlighting
- **Links**: Use \`\`Type\`\` for symbol links
- **Lists**: Use `-` or `1.` for bullet and numbered lists
- **Emphasis**: Use `*italic*` and `**bold**`
- **Sections**: Use `##` for subsections

## Viewing Documentation

### In Xcode

1. Build documentation (Product → Build Documentation)
2. Use the Documentation Viewer to browse
3. Search for specific symbols or topics
4. Navigate between modules and types

### In Browser

After generating static documentation:

1. Open `docs/index.html` in a web browser
2. Navigate through the documentation website
3. Use the search functionality
4. Share links to specific documentation pages

## Contributing to Documentation

### Adding New Documentation

1. **For new types**: Add comprehensive DocC comments
2. **For new modules**: Create a `.docc` catalog with overview
3. **For tutorials**: Add step-by-step guides with code examples
4. **For articles**: Create standalone documentation articles

### Documentation Review

Before submitting documentation changes:

1. Build documentation locally to check for errors
2. Review generated output for clarity and completeness
3. Ensure all public APIs are documented
4. Verify code examples compile and run correctly
5. Check that links between symbols work properly

### Best Practices

- **Keep it current**: Update documentation when code changes
- **Be comprehensive**: Document all public APIs
- **Use examples**: Show real-world usage patterns
- **Be consistent**: Follow the same style across modules
- **Test examples**: Ensure code examples actually work

## Troubleshooting

### Common Issues

**Documentation build fails**:
- Check for syntax errors in DocC comments
- Ensure all referenced symbols exist
- Verify `.docc` catalog structure

**Missing documentation**:
- Ensure types and methods are `public`
- Add DocC comments to all public APIs
- Check module import statements

**Broken links**:
- Use correct symbol reference syntax: \`\`Type/method\`\`
- Ensure referenced symbols are accessible
- Check spelling and capitalization

### Getting Help

- [Swift DocC Documentation](https://developer.apple.com/documentation/docc)
- [DocC Tutorial](https://developer.apple.com/tutorials/app-dev-training/documenting-your-code)
- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)