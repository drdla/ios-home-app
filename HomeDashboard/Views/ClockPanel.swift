import SwiftUI

/// Top-right quadrant of the Weather section.
/// Shows day name, large time, and date – all in PorscheNextTT-Thin.
/// Sketch layout: x=1152 y=0 w=384 h=357 (÷2 → 192×179pt)
struct ClockPanel: View {
    @EnvironmentObject private var vm: AppViewModel
    @State private var now = Date()
    @State private var showSettings = false
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // Day name – e.g. "Montag"
            Text(now.formatted(.dateTime.weekday(.wide).locale(Locale(identifier: "de_DE"))))
                .font(DashboardFont.thin(Layout.fontSizeLarge))
                .foregroundStyle(Color.textTertiary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 0)

            Spacer(minLength: 2)

            // Time – large digits, leading zero on hours
            Text(now.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute().locale(Locale(identifier: "de_DE"))))
                .font(DashboardFont.thin(Layout.fontSizeXLarge))
                .foregroundStyle(Color.textSecondary)
                .monospacedDigit()
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer(minLength: 2)

            // Date – e.g. "8. Juni"
            Text(now.formatted(.dateTime.day().month(.wide).locale(Locale(identifier: "de_DE"))))
                .font(DashboardFont.thin(Layout.fontSizeLarge))
                .foregroundStyle(Color.textTertiary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 0)
        }
        .padding(.horizontal, 0)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.surface)
        .onReceive(timer) { t in now = t }
        .onLongPressGesture(minimumDuration: 1.5) { showSettings = true }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(vm)
        }
    }
}

#Preview {
    ClockPanel()
        .environmentObject(AppViewModel())
        .frame(width: 192, height: 179)
        .background(Color.surface)
}
