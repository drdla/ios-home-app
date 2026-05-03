import SwiftUI

/// Root layout – reproduces the Sketch artboard "Home App iPad 6" (768×1024pt portrait).
/// Fixed 768×1024pt canvas, scaled as a unit on larger devices.
struct DashboardView: View {
    @EnvironmentObject private var vm: AppViewModel

    // Small optical nudge so the iPad status bar does not sit on top of the first row.
    // Do not use the full safe-area/status-bar height here; it creates a visible gap
    // and squeezes the bottom DoorBird preview.
    private let topContentOffset: CGFloat = 5

    var body: some View {
        GeometryReader { geo in
            let scale = min(
                geo.size.width / Layout.screenWidth,
                (geo.size.height - topContentOffset) / Layout.screenHeight
            )
            ZStack {
                Color.surface.ignoresSafeArea()
                DashboardCanvas()
                    .environmentObject(vm)
                    .frame(width: Layout.screenWidth, height: Layout.screenHeight)
                    .scaleEffect(scale)
                    .frame(width: geo.size.width, height: geo.size.height - topContentOffset, alignment: .top)
                    .offset(y: topContentOffset)
            }
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
    }
}

private struct DashboardCanvas: View {
    @EnvironmentObject private var vm: AppViewModel

    // Sketch artboard y coordinates (px ÷ 2):
    //   Separator 1: y=347px → 173.5pt
    //   Separator 2: y=1327px → 663.5pt
    private let sep1: CGFloat = 173.5
    private let sep2: CGFloat = 663.5

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.surface

            // ── Section 1: Weather + Date/Time ─────────────────────────
            WeatherDateSection(weather: vm.weather)
                .environmentObject(vm)
                .frame(width: 768, height: sep1)

            // ── Horizontal divider ─────────────────────────────────────
            SectionDivider()
                .frame(width: 768)
                .offset(y: sep1)

            // ── Section 2: Calendar / Tasks / Transit ──────────────────
            // No vertical column dividers – mockup has none.
            HStack(spacing: 0) {
                CalendarPanel(events: vm.calendarEvents)
                    .frame(width: 256.5)
                TasksPanel()
                    .frame(width: 255)
                TransitPanel(stops: vm.transitStops)
                    .frame(width: 256.5)
            }
            .frame(width: 768, height: sep2 - sep1 - 1)
            .offset(y: sep1 + 1)

            // ── Horizontal divider ─────────────────────────────────────
            SectionDivider()
                .frame(width: 768)
                .offset(y: sep2)

            // ── Section 3: Home Automation + Door ──────────────────────
            HStack(spacing: 0) {
                DeviceControlsPanel(
                    tiles: vm.shortcutTiles,
                    destinations: ["solar": .solarbank]
                )
                    .frame(width: 407.5)
                DoorPanel(door: vm.door, lock: vm.lock)
                    .frame(width: 360.5)
            }
            .frame(width: 768, height: Layout.screenHeight - sep2 - 1)
            .offset(y: sep2 + 1)
        }
        .frame(width: Layout.screenWidth, height: Layout.screenHeight)
        .clipped()
    }
}

// MARK: - Dividers

/// Horizontal dark line between sections, matching the Sketch separator symbol.
private struct SectionDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color(hex: 0x1A2528))
            .frame(maxWidth: .infinity)
            .frame(height: 1)
    }
}

// MARK: - Preview

#Preview {
    DashboardView()
        .environmentObject(AppViewModel())
        .frame(width: 768, height: 1024)
}
