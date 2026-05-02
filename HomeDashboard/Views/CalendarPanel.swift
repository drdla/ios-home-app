import SwiftUI

/// Left third of the Tasks section.
/// Shows a 23-hour vertical grid (hours 1–23) with colored event blocks.
/// Sketch: x=0 w=513 h=980 (÷2 → 256.5×490pt)
struct CalendarPanel: View {
    let events: [CalendarEvent]

    // Hours shown: 1 … 23
    private let hours = Array(1...23)
    private var rowHeight: CGFloat { 490.0 / CGFloat(hours.count) }

    var body: some View {
        GeometryReader { geo in
            let rh = geo.size.height / CGFloat(hours.count)
            ZStack(alignment: .topLeading) {
                // Grid lines + hour labels
                VStack(spacing: 0) {
                    ForEach(hours, id: \.self) { hour in
                        HStack(spacing: 0) {
                            Text("\(hour)")
                                .font(DashboardFont.thin(Layout.fontSizeSmall - 1))
                                .foregroundStyle(Color.textSecondary)
                                .frame(width: Layout.calendarLabelWidth, alignment: .trailing)
                                .padding(.trailing, 4)

                            Rectangle()
                                .fill(Color.textTertiary.opacity(0.3))
                                .frame(height: 0.5)
                                .frame(maxWidth: .infinity)
                        }
                        .frame(height: rh)
                    }
                }

                // Event blocks
                ForEach(events) { event in
                    CalendarEventBlock(event: event, rowHeight: rh)
                        .offset(
                            x: Layout.calendarLabelWidth + 4 + CGFloat(event.column) * columnWidth(geo: geo),
                            y: CGFloat(event.startHour - 1) * rh
                        )
                        .frame(width: columnWidth(geo: geo) - 2)
                        .frame(height: CGFloat(event.endHour - event.startHour) * rh)
                }
            }
        }
        .padding(.top, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.surface)
        .clipped()
    }

    private func columnWidth(geo: GeometryProxy) -> CGFloat {
        (geo.size.width - Layout.calendarLabelWidth - 4) / 2
    }
}

// MARK: - Event block

private struct CalendarEventBlock: View {
    let event: CalendarEvent
    let rowHeight: CGFloat

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 4)
                .fill(fillColor)
            Text(event.title)
                .font(DashboardFont.thin(Layout.fontSizeSmall - 1))
                .foregroundStyle(Color.textPrimary)
                .padding(4)
                .lineLimit(3)
        }
    }

    private var fillColor: Color {
        switch event.colorName {
        case "green":  return Color.calendarGreen
        case "purple": return Color.calendarPurple
        default:       return Color.calendarTeal
        }
    }
}

#Preview {
    CalendarPanel(events: DashboardSnapshot.mockup.calendarEvents)
        .frame(width: 256, height: 490)
        .background(Color.surface)
}
