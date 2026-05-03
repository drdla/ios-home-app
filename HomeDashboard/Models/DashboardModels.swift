import Foundation

// Re-exports all types from HomeDashboardCore so SwiftUI targets
// can import a single module without depending on the SPM package directly.

public struct DashboardSnapshot: Equatable {
    var weather: WeatherSnapshot
    var calendarEvents: [CalendarEvent]
    var transitStops: [TransitStopGroup]
    var shortcutTiles: [ShortcutTile]
    var door: DoorSnapshot
    var lock: LockSnapshot
}

public struct WeatherSnapshot: Equatable {
    var currentTemperatureCelsius: Int
    var currentLowCelsius: Int
    var tomorrowHighCelsius: Int
    var tomorrowLowCelsius: Int
    var precipitationChancePercent: Int
    var condition: WeatherCondition
    /// Hourly temperatures for today, indices 0–23 (°C). Empty = fall back to synthetic curve.
    var hourlyTemperatures: [Double]
    /// Hourly precipitation probability for today, indices 0–23 (0–100). Empty = fall back to synthetic curve.
    var hourlyPrecipitationChances: [Int]
}

public enum WeatherCondition: String, Equatable {
    case sunny, storm, cloudy
}

public struct CalendarEvent: Equatable, Identifiable {
    public var id: UUID
    var title: String
    var startHour: Int
    var endHour: Int
    var column: Int
    var colorName: String
    init(id: UUID = UUID(), title: String, startHour: Int, endHour: Int, column: Int, colorName: String) {
        self.id = id; self.title = title; self.startHour = startHour
        self.endHour = endHour; self.column = column; self.colorName = colorName
    }
}

public struct TransitDeparture: Equatable, Identifiable {
    public var id: UUID
    var line: String
    var destination: String
    var planned: Date
    var realtime: Date
    var cancelled: Bool
    init(id: UUID = UUID(), line: String, destination: String, planned: Date, realtime: Date, cancelled: Bool) {
        self.id = id; self.line = line; self.destination = destination
        self.planned = planned; self.realtime = realtime; self.cancelled = cancelled
    }
    var delayMinutes: Int {
        max(0, Int(realtime.timeIntervalSince(planned) / 60))
    }
    func minutesUntil(from now: Date) -> Int {
        max(0, Int(realtime.timeIntervalSince(now) / 60))
    }
}

public struct TransitSection: Equatable, Identifiable {
    public var id: String { title }
    var title: String
    var departures: [TransitDeparture]
}

public struct TransitStopGroup: Equatable, Identifiable {
    public var id: String { name }
    var name: String
    var sections: [TransitSection]
}

public struct ShortcutTile: Equatable, Identifiable {
    public var id: String { title }
    var title: String
    var iconName: String
}

public struct DoorSnapshot: Equatable {
    var title: String
    var isAvailable: Bool
}

public struct LockSnapshot: Equatable {
    var state: LockState
}

public enum LockState: String, Equatable {
    case locked, unlocked, unknown
}

// MARK: - Mock Data (matches Sketch mockup: Monday 8 June 09:08)

extension DashboardSnapshot {
    static let mockup = DashboardSnapshot(
        weather: WeatherSnapshot(
            currentTemperatureCelsius: 24,
            currentLowCelsius: 14,
            tomorrowHighCelsius: 18,
            tomorrowLowCelsius: 9,
            precipitationChancePercent: 6,
            condition: .sunny,
            // Realistic summer day in Dachau: cool morning, peak ~24° at 14:00, mild evening.
            hourlyTemperatures: [
                14, 13, 13, 12, 12, 13, 15, 17, 19, 21, 22, 23,
                24, 24, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15
            ],
            hourlyPrecipitationChances: [
                 4,  4,  4,  3,  3,  3,  3,  4,  4,  5,  5,  6,
                 6,  6,  7,  7,  6,  6,  5,  5,  4,  4,  4,  4
            ]
        ),
        calendarEvents: [
            CalendarEvent(title: "Caffè Dominik",        startHour: 8,  endHour: 11, column: 0, colorName: "teal"),
            CalendarEvent(title: "Häkeln Fanny",         startHour: 6,  endHour: 11, column: 1, colorName: "green"),
            CalendarEvent(title: "Schwimmtraining Felix", startHour: 13, endHour: 16, column: 0, colorName: "purple")
        ],
        transitStops: [
            TransitStopGroup(name: "Dachau Stadt", sections: [
                TransitSection(title: "Richtung München", departures: [
                    TransitDeparture(line: "S2", destination: "Ostbahnhof", planned: mockDate(9, 21), realtime: mockDate(9, 21), cancelled: false),
                    TransitDeparture(line: "S2", destination: "Dachau",     planned: mockDate(9, 51), realtime: mockDate(9, 51), cancelled: false)
                ]),
                TransitSection(title: "Richtung Altomünster", departures: [
                    TransitDeparture(line: "S2", destination: "Altomünster", planned: mockDate(9, 27), realtime: mockDate(9, 27), cancelled: false),
                    TransitDeparture(line: "S2", destination: "Altomünster", planned: mockDate(9, 57), realtime: mockDate(9, 57), cancelled: false),
                    TransitDeparture(line: "S2", destination: "Altomünster", planned: mockDate(10, 27), realtime: mockDate(10, 27), cancelled: false)
                ])
            ]),
            TransitStopGroup(name: "Dachau Bahnhof", sections: [
                TransitSection(title: "Richtung München", departures: [
                    TransitDeparture(line: "S2", destination: "Ostbahnhof", planned: mockDate(9, 24), realtime: mockDate(9, 24), cancelled: false),
                    TransitDeparture(line: "S2", destination: "Ostbahnhof", planned: mockDate(9, 44), realtime: mockDate(9, 44), cancelled: false),
                    TransitDeparture(line: "RB", destination: "München", planned: mockDate(9, 52), realtime: mockDate(9, 52), cancelled: false)
                ])
            ])
        ],
        shortcutTiles: [
            ShortcutTile(title: "Solar",      iconName: "solar"),
            ShortcutTile(title: "Geräte",     iconName: "appliance"),
            ShortcutTile(title: "Licht",      iconName: "lighting"),
            ShortcutTile(title: "Temperatur", iconName: "temperature"),
            ShortcutTile(title: "Lüftung",    iconName: "ventilation"),
            ShortcutTile(title: "Pflanzen",   iconName: "plant"),
            ShortcutTile(title: "Musik",      iconName: "music"),
        ],
        door: DoorSnapshot(title: "Haustür", isAvailable: true),
        lock: LockSnapshot(state: .locked)
    )

    private static func mockDate(_ h: Int, _ m: Int) -> Date {
        DateComponents(calendar: Calendar(identifier: .gregorian),
                       timeZone: TimeZone(identifier: "Europe/Berlin"),
                       year: 2026, month: 6, day: 8, hour: h, minute: m).date ?? Date()
    }
}

// MARK: - Transit Grouper

enum TransitGrouper {
    static func sections(for departures: [TransitDeparture], now: Date, lineFilter: String = "S2") -> [TransitSection] {
        let filtered = departures.filter { ($0.line == lineFilter || $0.line == "RB") && !$0.cancelled }
        var buckets: [String: [TransitDeparture]] = [:]
        for dep in filtered {
            let dir = directionTitle(for: dep.destination)
            guard dir != nil else { continue }
            buckets[dir!, default: []].append(dep)
        }
        let preferredOrder = ["Richtung München", "Richtung Altomünster"]
        return preferredOrder.compactMap { title in
            guard let deps = buckets[title] else { return nil }
            return TransitSection(
                title: title,
                departures: Array(deps.sorted { $0.realtime < $1.realtime }.prefix(3))
            )
        }
    }

    static func directionTitle(for destination: String) -> String? {
        let munichKeywords = ["Ostbahnhof", "München", "Marienplatz", "Hauptbahnhof", "Riem", "Erding", "Leuchtenbergring"]
        let altKeywords    = ["Altomünster"]
        if munichKeywords.contains(where: { destination.contains($0) }) { return "Richtung München" }
        if altKeywords.contains(where:    { destination.contains($0) }) { return "Richtung Altomünster" }
        return nil
    }
}
