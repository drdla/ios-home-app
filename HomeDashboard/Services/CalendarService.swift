import Foundation
import EventKit

struct CalendarService {
    var fetchToday: () async throws -> [CalendarEvent]

    static let live = CalendarService {
        let store = EKEventStore()

        // iOS 17+ / iOS 16 compatible access request
        let granted: Bool
        if #available(iOS 17.0, *) {
            granted = try await store.requestFullAccessToEvents()
        } else {
            granted = try await store.requestAccess(to: .event)
        }

        guard granted else {
            throw CalendarError.accessDenied
        }

        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end   = cal.date(byAdding: .day, value: 1, to: start)!

        // Resolve which EKCalendars to query.
        // An empty enabledCalendarIdentifiers means "show all".
        let enabledIds = AppSettings.shared.enabledCalendarIdentifiers
        let allCalendars = store.calendars(for: .event)
        let filtered = enabledIds.isEmpty
            ? allCalendars
            : allCalendars.filter { enabledIds.contains($0.calendarIdentifier) }

        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: filtered.isEmpty ? nil : filtered)
        let ekEvents = store.events(matching: predicate)

        return ekEvents.compactMap { CalendarEvent(from: $0) }
    }

    static let mock = CalendarService { DashboardSnapshot.mockup.calendarEvents }
}

enum CalendarError: LocalizedError {
    case accessDenied

    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Kalenderzugriff verweigert. Bitte in Einstellungen aktivieren."
        }
    }
}

// MARK: - EKEvent → CalendarEvent

private extension CalendarEvent {
    init?(from event: EKEvent) {
        guard let start = event.startDate, let end = event.endDate else { return nil }
        let cal = Calendar.current
        let startHour = cal.component(.hour, from: start)
        let endHour   = cal.component(.hour, from: end)
        guard startHour < endHour else { return nil }
        self.init(
            title:      event.title ?? "",
            startHour:  startHour,
            endHour:    endHour,
            column:     0,    // Column layout is resolved in the view
            colorName:  Self.colorName(for: event.calendar?.cgColor)
        )
    }

    static func colorName(for cgColor: CGColor?) -> String {
        guard let c = cgColor?.components, c.count >= 3 else { return "teal" }
        let r = c[0], g = c[1], b = c[2]
        if r > g && r > b { return "purple" }
        if g > r && g > b { return "green" }
        return "teal"
    }
}
