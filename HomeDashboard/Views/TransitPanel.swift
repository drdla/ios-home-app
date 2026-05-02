import SwiftUI

/// Right third of the Tasks section – S-Bahn departures.
/// Sketch: Transportation group x=1024 w=512 h=981 (÷2 → 256×490pt)
struct TransitPanel: View {
    let stops: [TransitStopGroup]
    @State private var now = Date()
    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(stops.enumerated()), id: \.element.id) { index, stop in
                    TransitStopView(stop: stop, now: now)
                        .padding(.top, index == 0 ? 7 : 22)
                }
            }
            .padding(.top, 2)
            .padding(.horizontal, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.surface)
        .onReceive(timer) { t in now = t }
    }
}

// MARK: - Section

private struct TransitStopView: View {
    let stop: TransitStopGroup
    let now: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(stop.name)
                .font(DashboardFont.regular(Layout.fontSizeSmall))
                .foregroundStyle(Color.textTertiary)
                .frame(maxWidth: .infinity, alignment: .center)

            ForEach(stop.sections) { section in
                TransitSectionView(section: section, now: now)
            }
        }
    }
}

private struct TransitSectionView: View {
    let section: TransitSection
    let now: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(section.title)
                .font(DashboardFont.regular(Layout.fontSizeSmall + 1))
                .foregroundStyle(Color.textTertiary)
                .padding(.bottom, 1)

            ForEach(section.departures) { dep in
                DepartureRow(departure: dep, now: now)
            }
        }
        .padding(.bottom, 6)
    }
}

// MARK: - Row
/// Matches Sketch row: [S2 badge] [destination] [time] [minutes bold]

private struct DepartureRow: View {
    let departure: TransitDeparture
    let now: Date

    var body: some View {
        HStack(spacing: 8) {
            LineBadge(line: departure.line)

            Text(destination)
                .font(DashboardFont.thin(Layout.fontSizeSmall))
                .foregroundStyle(Color.textSecondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(timeString)
                .font(DashboardFont.thin(Layout.fontSizeSmall))
                .foregroundStyle(Color.textSecondary)
                .monospacedDigit()

            Text("\(minutesUntil)")
                .font(DashboardFont.regular(Layout.fontSizeSmall))
                .foregroundStyle(departure.delayMinutes > 0 ? Color.highlight : Color.textPrimary)
                .monospacedDigit()
                .frame(width: 28, alignment: .trailing)

            Text("Min.")
                .font(DashboardFont.thin(Layout.fontSizeSmall - 1))
                .foregroundStyle(Color.textSecondary)
        }
        .frame(minHeight: 21)
        .opacity(departure.cancelled ? 0.4 : 1)
        .overlay(alignment: .center) {
            if departure.cancelled {
                Rectangle()
                    .fill(Color.textSecondary)
                    .frame(height: 0.5)
            }
        }
    }

    private var destination: String {
        // Truncate long names to fit (e.g. "Ostbahnhof" → "Ostbahnhof")
        departure.destination
    }

    private var timeString: String {
        departure.realtime.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute().locale(Locale(identifier: "de_DE")))
    }

    private var minutesUntil: Int {
        departure.minutesUntil(from: now)
    }
}

// MARK: - Line Badge (S2 green pill)

struct LineBadge: View {
    let line: String

    var body: some View {
        Text(line)
            .font(DashboardFont.regular(Layout.fontSizeSmall - 1))
            .foregroundStyle(Color.textPrimary)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(badgeColor, in: RoundedRectangle(cornerRadius: 4))
    }

    private var badgeColor: Color {
        switch line {
        case "S2": return Color.sBahnS2
        case "RB": return Color.sBahnRB
        default:   return Color.textSecondary
        }
    }
}

#Preview {
    TransitPanel(stops: DashboardSnapshot.mockup.transitStops)
        .frame(width: 256, height: 490)
        .background(Color.surface)
}
