import Foundation
import Combine

// Non-sensitive user preferences stored in UserDefaults.
// Sensitive credentials always go to SecretsStore (Keychain).

final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    // Home location (Dachau, Bavaria default)
    @Published var homeLat: Double {
        didSet { UserDefaults.standard.set(homeLat, forKey: Keys.homeLat) }
    }
    @Published var homeLon: Double {
        didSet { UserDefaults.standard.set(homeLon, forKey: Keys.homeLon) }
    }

    // Transit
    @Published var transitStationId: String {
        didSet { UserDefaults.standard.set(transitStationId, forKey: Keys.stationId) }
    }
    @Published var transitDepartureLimit: Int {
        didSet { UserDefaults.standard.set(transitDepartureLimit, forKey: Keys.depLimit) }
    }

    // Calendar – set of EKCalendar.calendarIdentifier strings to show.
    // Empty means "show all" (default until the user makes a selection).
    @Published var enabledCalendarIdentifiers: Set<String> {
        didSet { UserDefaults.standard.set(Array(enabledCalendarIdentifiers), forKey: Keys.calendarIds) }
    }

    // Tedee control mode
    @Published var tedeeMode: TedeeMode {
        didSet { UserDefaults.standard.set(tedeeMode.rawValue, forKey: Keys.tedeeMode) }
    }

    // Refresh intervals (seconds)
    @Published var weatherRefreshInterval: TimeInterval = 600   // 10 min
    @Published var transitRefreshInterval: TimeInterval = 30    // 30 sec
    @Published var calendarRefreshInterval: TimeInterval = 300  // 5 min

    private init() {
        let d = UserDefaults.standard
        homeLat              = d.object(forKey: Keys.homeLat)    as? Double ?? 48.26698246733924
        homeLon              = d.object(forKey: Keys.homeLon)    as? Double ?? 11.437766913838852
        transitStationId     = d.string(forKey: Keys.stationId)  ?? "de:09174:6850"
        transitDepartureLimit = d.object(forKey: Keys.depLimit)  as? Int ?? 10
        let modeRaw          = d.string(forKey: Keys.tedeeMode)  ?? TedeeMode.cloud.rawValue
        tedeeMode            = TedeeMode(rawValue: modeRaw) ?? .cloud
        let savedIds         = d.stringArray(forKey: Keys.calendarIds) ?? []
        enabledCalendarIdentifiers = Set(savedIds)
    }

    enum TedeeMode: String, CaseIterable, Identifiable {
        case cloud  = "cloud"
        case bridge = "bridge"
        case ble    = "ble"

        var id: String { rawValue }
        var label: String {
            switch self {
            case .cloud:  return "Tedee Cloud API"
            case .bridge: return "Tedee Bridge (lokal)"
            case .ble:    return "Tedee BLE"
            }
        }
    }

    private enum Keys {
        static let homeLat     = "home.lat"
        static let homeLon     = "home.lon"
        static let stationId   = "transit.stationId"
        static let depLimit    = "transit.limit"
        static let tedeeMode   = "tedee.mode"
        static let calendarIds = "calendar.enabledIds"
    }
}
