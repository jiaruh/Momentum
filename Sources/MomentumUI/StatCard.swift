import SwiftUI

/// A card component for displaying statistics with an icon and color theme.
///
/// `StatCard` provides a visually appealing way to display numerical statistics
/// or key metrics with consistent styling throughout the app.
///
/// ## Features
///
/// - Customizable icon from SF Symbols
/// - Color-themed design
/// - Clean, card-based layout
/// - Shadow and corner radius styling
///
/// ## Usage
///
/// ```swift
/// StatCard(
///     title: "Completed Tasks",
///     value: "42",
///     icon: "checkmark.circle.fill",
///     color: .green
/// )
/// ```
///
/// ## Grid Layout Example
///
/// ```swift
/// LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
///     StatCard(title: "Total", value: "100", icon: "list.bullet", color: .blue)
///     StatCard(title: "Done", value: "75", icon: "checkmark.circle.fill", color: .green)
/// }
/// ```
public struct StatCard: View {
    /// The title text displayed at the bottom of the card.
    public let title: String
    
    /// The main value or statistic to display prominently.
    public let value: String
    
    /// The SF Symbol icon name to display.
    public let icon: String
    
    /// The color theme for the icon.
    public let color: Color
    
    /// Creates a new statistics card.
    ///
    /// - Parameters:
    ///   - title: The descriptive title for the statistic.
    ///   - value: The numerical or text value to display prominently.
    ///   - icon: The SF Symbol icon name (e.g., "checkmark.circle.fill").
    ///   - color: The color theme for the icon.
    public init(title: String, value: String, icon: String, color: Color) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}