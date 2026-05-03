import SwiftUI

struct WeatherDateSection: View {
    let weather: WeatherSnapshot
    @EnvironmentObject private var vm: AppViewModel

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.surface

            // Current weather graphs (Sketch x=0..384px -> 0..192pt)
            WeatherGraphPanel(weather: weather)
                .frame(width: 192, height: 173.5)

            // Today icon panel (Sketch x=384..768px -> 192..384pt)
            TodayWeatherIconPanel(weather: weather)
                .frame(width: 192, height: 173.5)
                .offset(x: 192)

            // Tomorrow icon panel (Sketch x=768..1152px -> 384..576pt)
            TomorrowWeatherIconPanel(weather: weather)
                .frame(width: 192, height: 173.5)
                .offset(x: 384)

            // Date/time panel (Sketch x=1152..1536px -> 576..768pt)
            ClockPanel()
                .environmentObject(vm)
                .frame(width: 192, height: 173.5)
                .offset(x: 576)
        }
        .frame(width: 768, height: 173.5)
        .clipped()
    }
}

private struct WeatherGraphPanel: View {
    let weather: WeatherSnapshot

    // Sparkline geometry (panel is 192pt wide)
    private let chartLeft:  CGFloat = 12    // left edge of the 168pt sparkline
    private let chartWidth: CGFloat = 168
    private let barCount:   CGFloat = 24

    // X centre of the current-hour bar within the 192pt panel.
    // No clamping here — BarAlignedLabel clamps the label itself.
    private var currentBarX: CGFloat {
        let hour = CGFloat(Calendar.current.component(.hour, from: Date()))
        return chartLeft + (hour + 0.5) * (chartWidth / barCount)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Temperature: ° sits as superscript
            BarAlignedLabel(
                number: "\(weather.currentTemperatureCelsius)",
                unit: "°",
                isSuperscriptUnit: true,
                barX: currentBarX,
                y: 24
            )

            TemperatureBarChart(weather: weather)
                .frame(width: chartWidth, height: 30)
                .position(x: 96, y: 72)

            // Precipitation: % sits at baseline
            BarAlignedLabel(
                number: "\(weather.precipitationChancePercent)",
                unit: "%",
                isSuperscriptUnit: false,
                barX: currentBarX,
                y: 118
            )

            PrecipitationBarChart(weather: weather)
                .frame(width: chartWidth, height: 18)
                .position(x: 96, y: 153)
        }
    }
}

/// Renders [number][unit] such that the centre of the LAST digit of
/// the number aligns horizontally with barX.
///
/// - The "°" is positioned as a superscript via baselineOffset.
/// - The "%" sits on the text baseline (no offset).
private struct BarAlignedLabel: View {
    let number: String
    let unit: String
    let isSuperscriptUnit: Bool   // true → "°" raised; false → "%" at baseline
    let barX: CGFloat
    let y: CGFloat

    @State private var numberWidth: CGFloat = 38

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 1) {
            Text(number)
                .font(DashboardFont.thin(Layout.fontSizeLarge))
                .foregroundStyle(Color.textPrimary)
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear { numberWidth = geo.size.width }
                            .onChange(of: number) { _ in numberWidth = geo.size.width }
                    }
                )
            Text(unit)
                .font(DashboardFont.thin(Layout.fontSizeSmall + 2))
                .foregroundStyle(Color.textSecondary)
                // Raise "°" to superscript height; leave "%" on baseline.
                .baselineOffset(isSuperscriptUnit ? Layout.fontSizeLarge * 0.45 : 0)
        }
        // Centre of the last digit at barX.
        // For N digits each of width ≈ numberWidth/N, the last digit centre is
        // numberWidth/2 - numberWidth/(2N) to the right of the number text centre.
        // Shift the label left by that amount so the last digit lands on barX.
        .position(x: lastDigitCentreX, y: y)
    }

    private var lastDigitCentreX: CGFloat {
        let n        = max(1, CGFloat(number.count))
        // Approximate half-width of the unit glyph + 1pt spacing.
        // Needed because .position() centres the whole HStack, so we must
        // compensate for the unit sitting to the right of the number.
        let unitHalf: CGFloat = isSuperscriptUnit ? 4.0 : 5.0
        // Shift the HStack so the last digit's centre lands on barX:
        //   hstackCentre = barX - numberWidth*(N-1)/(2N) + unitHalf
        let ideal = barX - numberWidth * (n - 1) / (2 * n) + unitHalf
        // Clamp so the label stays within the 192pt panel.
        return max(numberWidth / 2 + 4, min(ideal, 192 - 12))
    }
}

// MARK: - Today (left half of weather section)
/// Sketch: x=0 y=0 w=768 h=352 (÷2 → 384×176pt)
/// Shows temperature bar chart, big temperature, precipitation %, and "Heute" label.

struct WeatherTodayPanel: View {
    let weather: WeatherSnapshot

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Right sub-panel: weather icon (sun)
            HStack(spacing: 0) {
                // Left sub-panel: bar chart + big temperature + precipitation
                VStack(alignment: .leading, spacing: 0) {
                    // Big temperature
                    Text("\(weather.currentTemperatureCelsius)°")
                        .font(DashboardFont.thin(Layout.fontSizeLarge))
                        .foregroundStyle(Color.textPrimary)
                        .padding(.top, Layout.panelPadding)
                        .padding(.leading, Layout.panelPadding)

                    // Temperature bar chart (schematic)
                    TemperatureBarChart(weather: weather)
                        .frame(height: 24)
                        .padding(.horizontal, Layout.panelPadding)

                    Spacer()

                    // Precipitation row
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(weather.precipitationChancePercent)")
                            .font(DashboardFont.thin(Layout.fontSizeLarge))
                            .foregroundStyle(Color.textPrimary)
                        Text("%")
                            .font(DashboardFont.thin(Layout.fontSizeSmall + 2))
                            .foregroundStyle(Color.textPrimary)
                    }
                    .padding(.leading, Layout.panelPadding)

                    // Precipitation bar chart
                    PrecipitationBarChart(weather: weather)
                        .frame(height: 24)
                        .padding(.horizontal, Layout.panelPadding)
                        .padding(.bottom, Layout.panelPadding)
                }
                .frame(maxWidth: .infinity)

                // Right: sun + high/low labels, matching the Sketch weather tile.
                TodayWeatherIconPanel(weather: weather)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.surface)
    }
}

// MARK: - Tomorrow (second quarter of weather section)
/// Sketch: x=768 y=2 w=384 h=350 (÷2 → 192×175pt)

struct WeatherTomorrowPanel: View {
    let weather: WeatherSnapshot

    var body: some View {
        ZStack {
            TomorrowWeatherIconPanel(weather: weather)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.surface)
    }
}

// MARK: - Weather Icon Panel

private struct TodayWeatherIconPanel: View {
    let weather: WeatherSnapshot

    var body: some View {
        ZStack {
            Image(systemName: "sun.max")
                .font(.system(size: 68, weight: .thin))
                .foregroundStyle(Color.textSecondary)

            Text("\(weather.currentTemperatureCelsius + 4)°")
                .font(DashboardFont.thin(Layout.fontSizeLarge))
                .foregroundStyle(Color.textSecondary)
                .position(x: 150, y: 23)

            Text("\(weather.currentLowCelsius)°")
                .font(DashboardFont.thin(Layout.fontSizeLarge))
                .foregroundStyle(Color.textSecondary)
                .position(x: 46, y: 126)

            Text("Heute")
                .font(DashboardFont.thin(Layout.fontSizeSmall))
                .foregroundStyle(Color.textSecondary)
                .position(x: 103, y: 159)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct TomorrowWeatherIconPanel: View {
    let weather: WeatherSnapshot

    var body: some View {
        ZStack {
            Image(systemName: "cloud.bolt.rain")
                .font(.system(size: 62, weight: .thin))
                .foregroundStyle(Color.textSecondary)
                .position(x: 95, y: 76)

            Text("\(weather.tomorrowHighCelsius)°")
                .font(DashboardFont.thin(Layout.fontSizeLarge))
                .foregroundStyle(Color.textPrimary)
                .position(x: 154, y: 23)

            Text("\(weather.tomorrowLowCelsius)°")
                .font(DashboardFont.thin(Layout.fontSizeLarge))
                .foregroundStyle(Color.textSecondary)
                .position(x: 38, y: 126)

            Text("Morgen")
                .font(DashboardFont.thin(Layout.fontSizeSmall))
                .foregroundStyle(Color.textSecondary)
                .position(x: 96, y: 159)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Temperature bar chart

private struct TemperatureBarChart: View {
    let weather: WeatherSnapshot
    private var currentHour: Int { Calendar.current.component(.hour, from: Date()) }

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 1) {
                ForEach(0..<24, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(i == currentHour ? Color.textPrimary : Color.textTertiary.opacity(0.65))
                        .frame(height: max(4, geo.size.height * barFraction(hour: i)))
                        .frame(maxHeight: geo.size.height, alignment: .bottom)
                }
            }
        }
    }

    private func barFraction(hour: Int) -> Double {
        let temps = weather.hourlyTemperatures
        guard temps.count == 24 else {
            // Synthetic fallback: bell curve peaking at 14:00
            let raw = exp(-pow(Double(hour) - 14.0, 2) / (2 * 6.0 * 6.0))
            return 0.2 + 0.8 * raw
        }
        let lo = temps.min() ?? 0
        let hi = temps.max() ?? 1
        guard hi > lo else { return 0.5 }
        return 0.15 + 0.85 * ((temps[hour] - lo) / (hi - lo))
    }
}

// MARK: - Precipitation bar chart

private struct PrecipitationBarChart: View {
    let weather: WeatherSnapshot
    private var currentHour: Int { Calendar.current.component(.hour, from: Date()) }

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 1) {
                ForEach(0..<24, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(i == currentHour ? Color.textPrimary : Color.textTertiary.opacity(0.65))
                        .frame(height: max(2, geo.size.height * barFraction(hour: i)))
                        .frame(maxHeight: geo.size.height, alignment: .bottom)
                }
            }
        }
    }

    private func barFraction(hour: Int) -> Double {
        let chances = weather.hourlyPrecipitationChances
        guard chances.count == 24 else {
            // Synthetic fallback: sine wave scaled by current chance
            let chance = Double(weather.precipitationChancePercent)
            return max(0.08, chance / 100.0 * (0.5 + 0.5 * sin(Double(hour) / 3.0)))
        }
        return max(0.08, Double(chances[hour]) / 100.0)
    }
}

#Preview("Today") {
    WeatherTodayPanel(weather: DashboardSnapshot.mockup.weather)
        .frame(width: 384, height: 176)
        .background(Color.surface)
}

#Preview("Tomorrow") {
    WeatherTomorrowPanel(weather: DashboardSnapshot.mockup.weather)
        .frame(width: 192, height: 176)
        .background(Color.surface)
}
