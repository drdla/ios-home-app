import Foundation

public struct DashboardSnapshot: Equatable, Sendable {
    public var weather: WeatherSnapshot
    public var calendarEvents: [CalendarEvent]
    public var transitSections: [TransitSection]
    public var shortcutTiles: [ShortcutTile]
    public var door: DoorSnapshot
    public var lock: LockSnapshot

    public init(
        weather: WeatherSnapshot,
        calendarEvents: [CalendarEvent],
        transitSections: [TransitSection],
        shortcutTiles: [ShortcutTile],
        door: DoorSnapshot,
        lock: LockSnapshot
    ) {
        self.weather = weather
        self.calendarEvents = calendarEvents
        self.transitSections = transitSections
        self.shortcutTiles = shortcutTiles
        self.door = door
        self.lock = lock
    }
}

public struct WeatherSnapshot: Equatable, Sendable {
    public var currentTemperatureCelsius: Int
    public var currentLowCelsius: Int
    public var tomorrowHighCelsius: Int
    public var tomorrowLowCelsius: Int
    public var precipitationChancePercent: Int
    public var condition: WeatherCondition

    public init(
        currentTemperatureCelsius: Int,
        currentLowCelsius: Int,
        tomorrowHighCelsius: Int,
        tomorrowLowCelsius: Int,
        precipitationChancePercent: Int,
        condition: WeatherCondition
    ) {
        self.currentTemperatureCelsius = currentTemperatureCelsius
        self.currentLowCelsius = currentLowCelsius
        self.tomorrowHighCelsius = tomorrowHighCelsius
        self.tomorrowLowCelsius = tomorrowLowCelsius
        self.precipitationChancePercent = precipitationChancePercent
        self.condition = condition
    }
}

public enum WeatherCondition: String, Equatable, Sendable {
    case sunny
    case storm
    case cloudy
}

public struct CalendarEvent: Equatable, Identifiable, Sendable {
    public var id: UUID
    public var title: String
    public var startHour: Int
    public var endHour: Int
    public var column: Int
    public var colorName: String

    public init(id: UUID = UUID(), title: String, startHour: Int, endHour: Int, column: Int, colorName: String) {
        self.id = id
        self.title = title
        self.startHour = startHour
        self.endHour = endHour
        self.column = column
        self.colorName = colorName
    }
}

public struct TransitDeparture: Equatable, Identifiable, Sendable {
    public var id: UUID
    public var line: String
    public var destination: String
    public var planned: Date
    public var realtime: Date
    public var cancelled: Bool

    public init(id: UUID = UUID(), line: String, destination: String, planned: Date, realtime: Date, cancelled: Bool) {
        self.id = id
        self.line = line
        self.destination = destination
        self.planned = planned
        self.realtime = realtime
        self.cancelled = cancelled
    }
}

public struct TransitSection: Equatable, Identifiable, Sendable {
    public var id: String { title }
    public var title: String
    public var departures: [TransitDeparture]

    public init(title: String, departures: [TransitDeparture]) {
        self.title = title
        self.departures = departures
    }
}

public struct ShortcutTile: Equatable, Identifiable, Sendable {
    public var id: String { title }
    public var title: String
    public var iconName: String

    public init(title: String, iconName: String) {
        self.title = title
        self.iconName = iconName
    }
}

public struct DoorSnapshot: Equatable, Sendable {
    public var title: String
    public var isAvailable: Bool

    public init(title: String, isAvailable: Bool) {
        self.title = title
        self.isAvailable = isAvailable
    }
}

public struct LockSnapshot: Equatable, Sendable {
    public var state: LockState

    public init(state: LockState) {
        self.state = state
    }
}

public enum LockState: String, Equatable, Sendable {
    case locked
    case unlocked
    case unknown
}
