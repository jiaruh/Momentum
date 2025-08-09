# Integrating Swift Packages into Xcode Project

Since the Momentum app has been refactored into Swift Package modules, you need to integrate these local packages into your Xcode project:

## Steps to Add Local Swift Packages:

1. **Open Momentum.xcodeproj in Xcode**

2. **Add Local Package Dependencies:**
   - In Xcode, go to File → Add Package Dependencies
   - Click "Add Local..." button
   - Navigate to the Momentum project folder and select it
   - Click "Add Package"

3. **Add Package Products to Target:**
   - Select your Momentum target
   - In the "Frameworks, Libraries, and Embedded Content" section, add:
     - MomentumCore
     - MomentumAuthentication
     - MomentumUI
     - MomentumFeatures

4. **Verify Integration:**
   - Build the project (⌘+B)
   - The modular structure should now work correctly

## Alternative: Manual Integration

If the above doesn't work, you can manually drag the Swift Package folders into your Xcode project:

1. Drag the `Sources` folder into your Xcode project
2. Make sure to add the folders as groups (not folder references)
3. Ensure all Swift files are added to the Momentum target

## Benefits of This Architecture:

- **Modularity**: Each feature is isolated in its own module
- **Reusability**: Modules can be reused across different projects
- **Testing**: Each module has its own test suite
- **Maintainability**: Clear separation of concerns
- **iOS Optimized**: All code is specifically optimized for iOS 17+