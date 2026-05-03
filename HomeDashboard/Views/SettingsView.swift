import SwiftUI
import EventKit

/// Settings panel – opened via a long-press on the clock.
/// Stores non-sensitive settings in UserDefaults; credentials go to Keychain.
struct SettingsView: View {
    @ObservedObject private var settings = AppSettings.shared
    @Environment(\.dismiss) private var dismiss

    @State private var doorBirdHost = ""
    @State private var doorBirdUser = ""
    @State private var doorBirdPassword = ""
    @State private var tedeeKey = ""
    @State private var tedeeLockId = ""
    @State private var showSaved = false
    @State private var availableCalendars: [EKCalendar] = []

    var body: some View {
        NavigationStack {
            Form {
                // MARK: Location
                Section("Heimatstandort") {
                    HStack {
                        Text("Breitengrad")
                        Spacer()
                        TextField("48.2600", value: $settings.homeLat, format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                    }
                    HStack {
                        Text("Längengrad")
                        Spacer()
                        TextField("11.4342", value: $settings.homeLon, format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                    }
                }

                // MARK: Calendar
                Section {
                    if availableCalendars.isEmpty {
                        Text("Kein Kalenderzugriff")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(availableCalendars, id: \.calendarIdentifier) { cal in
                            let id = cal.calendarIdentifier
                            let isEnabled = settings.enabledCalendarIdentifiers.isEmpty
                                || settings.enabledCalendarIdentifiers.contains(id)
                            Button {
                                toggleCalendar(id)
                            } label: {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color(cgColor: cal.cgColor))
                                        .frame(width: 12, height: 12)
                                    Text(cal.title)
                                        .foregroundStyle(Color.primary)
                                    Spacer()
                                    if isEnabled {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue)
                                    }
                                }
                            }
                        }
                    }
                } header: {
                    Text("Kalender")
                } footer: {
                    Text("Alle Kalender sind aktiv, wenn keine Auswahl getroffen wurde.")
                        .font(.caption)
                }

                // MARK: Transit
                Section("S-Bahn") {
                    HStack {
                        Text("Dachau Stadt")
                        Spacer()
                        Text("de:09174:6850")
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    }
                    HStack {
                        Text("Dachau Bahnhof")
                        Spacer()
                        Text("de:09174:6800")
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    }
                    Stepper("Abfahrten: \(settings.transitDepartureLimit)",
                            value: $settings.transitDepartureLimit, in: 3...20)
                }

                // MARK: DoorBird
                Section("DoorBird") {
                    TextField("IP / Hostname", text: $doorBirdHost)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    TextField("Benutzername", text: $doorBirdUser)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    SecureField("Passwort", text: $doorBirdPassword)
                }

                // MARK: Tedee
                Section("Tedee") {
                    Picker("Verbindung", selection: $settings.tedeeMode) {
                        ForEach(AppSettings.TedeeMode.allCases) { mode in
                            Text(mode.label).tag(mode)
                        }
                    }
                    SecureField("Personal Access Key", text: $tedeeKey)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    TextField("Schloss-ID", text: $tedeeLockId)
                        .keyboardType(.numberPad)
                }

                // MARK: Diagnose
                Section("Diagnose") {
                    NavigationLink("API-Status & letzte Aktualisierung") {
                        DiagnosticsView()
                    }
                }
            }
            .navigationTitle("Einstellungen")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        saveCredentials()
                        showSaved = true
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Schließen") { dismiss() }
                }
            }
            .alert("Gespeichert", isPresented: $showSaved) {
                Button("OK") { dismiss() }
            }
        }
        .onAppear {
            loadCredentials()
            loadCalendars()
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Helpers

    private func loadCalendars() {
        let store = EKEventStore()
        Task {
            let granted: Bool
            if #available(iOS 17.0, *) {
                granted = (try? await store.requestFullAccessToEvents()) ?? false
            } else {
                granted = (try? await store.requestAccess(to: .event)) ?? false
            }
            guard granted else { return }
            await MainActor.run {
                availableCalendars = store.calendars(for: .event)
                    .sorted { $0.title < $1.title }
            }
        }
    }

    private func toggleCalendar(_ id: String) {
        var ids = settings.enabledCalendarIdentifiers

        // On first tap, "all enabled" (empty set) should become
        // "all except this one", so we materialise the full set first.
        if ids.isEmpty {
            ids = Set(availableCalendars.map { $0.calendarIdentifier })
        }

        if ids.contains(id) {
            ids.remove(id)
        } else {
            ids.insert(id)
        }

        // If everything is checked again, collapse back to "all" (empty set).
        if ids.count == availableCalendars.count {
            ids = []
        }

        settings.enabledCalendarIdentifiers = ids
    }

    private func loadCredentials() {
        if let c = try? SecretsStore.doorBirdCredentials() {
            doorBirdHost     = c.host
            doorBirdUser     = c.user
            doorBirdPassword = c.password
        }
        if let c = try? SecretsStore.tedeeCredentials() {
            tedeeKey    = c.personalKey
            tedeeLockId = String(c.lockId)
        }
    }

    private func saveCredentials() {
        if !doorBirdHost.isEmpty {
            SecretsStore.saveDoorBird(host: doorBirdHost, user: doorBirdUser, password: doorBirdPassword)
        }
        if !tedeeKey.isEmpty, let id = Int(tedeeLockId) {
            SecretsStore.saveTedee(personalKey: tedeeKey, lockId: id)
        }
    }
}

// MARK: - Diagnostics

private struct DiagnosticsView: View {
    @EnvironmentObject private var vm: AppViewModel

    var body: some View {
        List {
            Section("Letzte Aktualisierung") {
                if let last = vm.lastRefresh {
                    Text(last.formatted(.dateTime.hour().minute().second()))
                } else {
                    Text("Noch nicht aktualisiert")
                        .foregroundStyle(.secondary)
                }
            }
            if !vm.errors.isEmpty {
                Section("Fehler") {
                    ForEach(vm.errors, id: \.self) { err in
                        Text(err)
                            .foregroundStyle(Color.highlight)
                            .font(.caption)
                    }
                }
            }
        }
        .navigationTitle("Diagnose")
        .preferredColorScheme(.dark)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppViewModel())
}
