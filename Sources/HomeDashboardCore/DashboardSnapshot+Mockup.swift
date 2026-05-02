import Foundation

extension DashboardSnapshot {
    /// Mock data matching the Sketch mockup (Monday 8 June, 09:08).
    public static let mockup = DashboardSnapshot(
        weather: WeatherSnapshot(
            currentTemperatureCelsius: 24,
            currentLowCelsius: 14,
            tomorrowHighCelsius: 18,
            tomorrowLowCelsius: 9,
            precipitationChancePercent: 6,
            condition: .sunny
        ),
        calendarEvents: [
            CalendarEvent(title: "Caffè Dominik",        startHour: 8,  endHour: 11, column: 0, colorName: "teal"),
            CalendarEvent(title: "Häkeln Fanny",         startHour: 6,  endHour: 11, column: 1, colorName: "green"),
            CalendarEvent(title: "Schwimmtraining Felix", startHour: 13, endHour: 16, column: 0, colorName: "purple")
        ],
        transitSections: [
            TransitSection(title: "Richtung München", departures: [
                TransitDeparture(line: "S2", destination: "Ostbahnhof", planned: mockDate(hour: 9, minute: 21), realtime: mockDate(hour: 9, minute: 21), cancelled: false),
                TransitDeparture(line: "S2", destination: "Dachau",     planned: mockDate(hour: 9, minute: 51), realtime: mockDate(hour: 9, minute: 51), cancelled: false)
            ]),
            TransitSection(title: "Richtung Altomünster", departures: [
                TransitDeparture(line: "S2", destination: "Altomünster", planned: mockDate(hour: 9, minute: 27), realtime: mockDate(hour: 9, minute: 27), cancelled: false),
                TransitDeparture(line: "S2", destination: "Altomünster", planned: mockDate(hour: 9, minute: 57), realtime: mockDate(hour: 9, minute: 57), cancelled: false)
            ])
        ],
        shortcutTiles: [
            ShortcutTile(title: "Licht",      iconName: "lightbulb"),
            ShortcutTile(title: "Musik",      iconName: "music.note"),
            ShortcutTile(title: "Geräte",     iconName: "poweroutlet.type.b"),
            ShortcutTile(title: "Pflanzen",   iconName: "leaf"),
            ShortcutTile(title: "Lüftung",    iconName: "wind"),
            ShortcutTile(title: "Sicherheit", iconName: "lock.shield")
        ],
        door: DoorSnapshot(title: "Haustür", isAvailable: true),
        lock: LockSnapshot(state: .locked)
    )

    private static func mockDate(hour: Int, minute: Int) -> Date {
        DateComponents(
            calendar: Calendar(identifier: .gregorian),
            timeZone: TimeZone(identifier: "Europe/Berlin"),
            year: 2026, month: 6, day: 8,
            hour: hour, minute: minute
        ).date ?? Date()
    }
}
