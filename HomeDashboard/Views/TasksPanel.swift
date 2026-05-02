import SwiftUI

/// Middle third of the Tasks section.
/// Shows a checklist of tasks/reminders. Inert placeholder in v1.
/// Sketch: x=513 w=512 h=980 (÷2 → 256×490pt)
struct TasksPanel: View {
    // Placeholder items matching the mockup style
    private let items = Array(repeating: TaskItem(title: "Aufgaben Aufgabe Aufgabe",
                                                   detail: "Details Details Details"), count: 5)

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    TaskRow(item: item)
                }
            }
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.surface)
    }
}

// MARK: - Row

private struct TaskRow: View {
    let item: TaskItem
    @State private var done = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Checkbox
            Image(systemName: done ? "checkmark.square" : "square")
                .font(.system(size: 18, weight: .thin))
                .foregroundStyle(Color.textSecondary)
                .onTapGesture { done.toggle() }
                .frame(width: 24, height: 24)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(DashboardFont.thin(Layout.fontSizeSmall))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
                Text(item.detail)
                    .font(DashboardFont.thin(Layout.fontSizeSmall - 2))
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, Layout.panelPadding)
        .frame(minHeight: 44)
        .frame(maxWidth: .infinity, alignment: .leading)

        Divider()
            .background(Color.textSecondary.opacity(0.2))
            .padding(.leading, Layout.panelPadding + 24 + 12)
    }
}

private struct TaskItem {
    let title: String
    let detail: String
}

#Preview {
    TasksPanel()
        .frame(width: 256, height: 490)
        .background(Color.surface)
}
