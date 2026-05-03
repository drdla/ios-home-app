import Foundation
import Combine
import EventKit

@MainActor
final class AppViewModel: ObservableObject {
    @Published var weather: WeatherSnapshot = DashboardSnapshot.mockup.weather
    @Published var calendarEvents: [CalendarEvent] = DashboardSnapshot.mockup.calendarEvents
    @Published var transitStops: [TransitStopGroup] = DashboardSnapshot.mockup.transitStops
    @Published var shortcutTiles: [ShortcutTile] = DashboardSnapshot.mockup.shortcutTiles
    @Published var door: DoorSnapshot = DashboardSnapshot.mockup.door
    @Published var lock: LockSnapshot = DashboardSnapshot.mockup.lock
    @Published var isLoading = false
    @Published var lastRefresh: Date?
    @Published var errors: [String] = []

    private let weatherService: WeatherService
    private let calendarService: CalendarService
    private let transitService: TransitService
    private let doorBirdService: DoorBirdService
    private let tedeeService: TedeeService
    private let settings: AppSettings

    private var timerTasks: [Task<Void, Never>] = []

    init(
        weatherService: WeatherService = .live,
        calendarService: CalendarService = .live,
        transitService: TransitService = .live,
        doorBirdService: DoorBirdService = .live,
        tedeeService: TedeeService = .live,
        settings: AppSettings = .shared
    ) {
        self.weatherService = weatherService
        self.calendarService = calendarService
        self.transitService = transitService
        self.doorBirdService = doorBirdService
        self.tedeeService = tedeeService
        self.settings = settings
    }

    // MARK: - Foreground lifecycle

    func startPeriodicRefresh() {
        stopPeriodicRefresh()
        let transitInterval  = settings.transitRefreshInterval
        let weatherInterval  = settings.weatherRefreshInterval
        let calendarInterval = settings.calendarRefreshInterval

        timerTasks = [
            makeTimer(interval: transitInterval,  work: refreshTransit),
            makeTimer(interval: weatherInterval,  work: refreshWeather),
            makeTimer(interval: calendarInterval, work: refreshCalendar),
        ]
    }

    func stopPeriodicRefresh() {
        timerTasks.forEach { $0.cancel() }
        timerTasks = []
    }

    private func makeTimer(interval: TimeInterval, work: @escaping () async -> Void) -> Task<Void, Never> {
        Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(interval))
                guard !Task.isCancelled else { break }
                await work()
            }
        }
    }

    func refreshOnForeground() async {
        isLoading = true
        errors = []
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.refreshWeather() }
            group.addTask { await self.refreshCalendar() }
            group.addTask { await self.refreshTransit() }
            group.addTask { await self.refreshDoor() }
            group.addTask { await self.refreshLock() }
        }
        lastRefresh = Date()
        isLoading = false
    }

    // MARK: - Individual refreshes

    func refreshWeather() async {
        do {
            weather = try await weatherService.fetch()
        } catch {
            errors.append("Wetter: \(error.localizedDescription)")
        }
    }

    func refreshCalendar() async {
        do {
            calendarEvents = try await calendarService.fetchToday()
        } catch {
            errors.append("Kalender: \(error.localizedDescription)")
        }
    }

    func refreshTransit() async {
        do {
            transitStops = try await transitService.fetchStops()
        } catch {
            errors.append("S-Bahn: \(error.localizedDescription)")
        }
    }

    func refreshDoor() async {
        do {
            door = try await doorBirdService.fetchSnapshot()
        } catch {
            errors.append("Türklingel: \(error.localizedDescription)")
        }
    }

    func refreshLock() async {
        do {
            lock = try await tedeeService.fetchLockState()
        } catch {
            errors.append("Schloss: \(error.localizedDescription)")
        }
    }

    // MARK: - Actions

    func openDoor() async {
        do {
            try await doorBirdService.openDoor()
        } catch {
            errors.append("Türöffner: \(error.localizedDescription)")
        }
    }

    func toggleLock() async {
        do {
            if lock.state == .locked {
                try await tedeeService.unlock()
                lock = LockSnapshot(state: .unlocked)
            } else {
                try await tedeeService.lock()
                lock = LockSnapshot(state: .locked)
            }
        } catch {
            errors.append("Schloss: \(error.localizedDescription)")
        }
    }
}
