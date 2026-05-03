import SwiftUI
import UIKit

/// Full-screen detail sheet for the Anker Solarbank integration.
/// Presented when the user taps the Solarbank shortcut tile on the dashboard.
struct SolarbankDetailView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: 0x1C2A2E).ignoresSafeArea()

                VStack(spacing: 32) {
                    EnergyFlowSection()
                    Divider().overlay(Color(hex: 0x2E3C41))
                    MetricsGrid()
                    Spacer()
                    OpenAnkerAppButton()
                    Text("Solarbank-Integration wird eingerichtet.\nModbus TCP wird in Kürze verbunden.")
                        .font(DashboardFont.thin(14))
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 32)
                }
                .padding(.top, 24)
                .padding(.horizontal, 32)
            }
            .navigationTitle("Solarbank")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Schließen") { dismiss() }
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .toolbarBackground(Color(hex: 0x1C2A2E), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Energy flow

private struct EnergyFlowSection: View {
    var body: some View {
        HStack(spacing: 0) {
            FlowNode(icon: "sun.max", label: "Solar", value: "– W", accent: Color(hex: 0xF5C542))
            FlowArrow()
            FlowNode(icon: "battery.75", label: "Akku", value: "– %", accent: Color(hex: 0x4BC5E3))
            FlowArrow()
            FlowNode(icon: "house", label: "Haus", value: "– W", accent: Color.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
    }
}

private struct FlowNode: View {
    let icon: String
    let label: String
    let value: String
    let accent: Color

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 36, weight: .thin))
                .foregroundStyle(accent)
                .frame(height: 44)

            Text(value)
                .font(DashboardFont.thin(28))
                .foregroundStyle(Color.textPrimary)
                .monospacedDigit()

            Text(label)
                .font(DashboardFont.thin(13))
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct FlowArrow: View {
    var body: some View {
        Image(systemName: "arrow.right")
            .font(.system(size: 18, weight: .thin))
            .foregroundStyle(Color.textTertiary.opacity(0.5))
            .padding(.bottom, 24)
    }
}

// MARK: - Metrics grid

private struct MetricsGrid: View {
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            MetricCard(icon: "bolt.fill",         label: "Netz",            value: "– W",  note: "Import / Export", accent: Color(hex: 0xF7E81C))
            MetricCard(icon: "battery.100.bolt",  label: "Laden / Entladen",value: "– W",  note: "Richtung",        accent: Color(hex: 0x4BC5E3))
            MetricCard(icon: "chart.bar",         label: "Heute erzeugt",   value: "– kWh",note: "Gesamt",          accent: Color(hex: 0xF5C542))
            MetricCard(icon: "clock.arrow.circlepath", label: "Letzte Aktualisierung", value: "–", note: "Modbus TCP", accent: Color.textSecondary)
        }
    }
}

private struct MetricCard: View {
    let icon: String
    let label: String
    let value: String
    let note: String
    let accent: Color

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .thin))
                .foregroundStyle(accent)
                .frame(width: 28)
                .padding(.top, 3)

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(DashboardFont.thin(22))
                    .foregroundStyle(Color.textPrimary)
                    .monospacedDigit()
                Text(label)
                    .font(DashboardFont.thin(13))
                    .foregroundStyle(Color.textSecondary)
                Text(note)
                    .font(DashboardFont.thin(11))
                    .foregroundStyle(Color.textTertiary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0x243338), in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Open Anker app

private struct OpenAnkerAppButton: View {
    // Anker SOLIX does not publish an official URL scheme.
    // We try the most common pattern first; if the app isn't installed
    // (or uses a different scheme) we fall back to the App Store page.
    private let appScheme    = URL(string: "ankersolix://")!
    private let appStorePage = URL(string: "https://apps.apple.com/app/anker-solix/id1671678447")!

    var body: some View {
        Button {
            let app = UIApplication.shared
            if app.canOpenURL(appScheme) {
                app.open(appScheme)
            } else {
                app.open(appStorePage)
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "arrow.up.forward.app")
                    .font(.system(size: 16, weight: .thin))
                Text("Anker SOLIX App öffnen")
                    .font(DashboardFont.thin(16))
            }
            .foregroundStyle(Color.textPrimary)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color(hex: 0x2E3C41), in: RoundedRectangle(cornerRadius: 10))
        }
    }
}

// MARK: - Preview

#Preview {
    SolarbankDetailView()
}
