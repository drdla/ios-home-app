@testable import HomeDashboard
import XCTest

final class DashboardCoreTests: XCTestCase {

    // MARK: - Mockup sanity

    func testMockupWeatherMatchesSketchValues() {
        let snap = DashboardSnapshot.mockup
        XCTAssertEqual(snap.weather.currentTemperatureCelsius, 24)
        XCTAssertEqual(snap.weather.tomorrowHighCelsius, 18)
        XCTAssertEqual(snap.weather.precipitationChancePercent, 6)
    }

    func testMockupContainsThreeCalendarEvents() {
        XCTAssertEqual(DashboardSnapshot.mockup.calendarEvents.count, 3)
        XCTAssertEqual(DashboardSnapshot.mockup.calendarEvents.map(\.title), [
            "Caffè Dominik", "Häkeln Fanny", "Schwimmtraining Felix"
        ])
    }

    func testMockupContainsSixShortcutTiles() {
        XCTAssertEqual(DashboardSnapshot.mockup.shortcutTiles.count, 6)
    }

    // MARK: - Transit grouper

    func testGroupsS2TowardsMunich() {
        let deps = [
            TransitDeparture(line: "S2", destination: "Ostbahnhof", planned: date(9, 21), realtime: date(9, 21), cancelled: false),
            TransitDeparture(line: "S2", destination: "Dachau",     planned: date(9, 51), realtime: date(9, 51), cancelled: false)
        ]
        let sections = TransitGrouper.sections(for: deps, now: date(9, 8))
        XCTAssertEqual(sections.count, 1)
        XCTAssertEqual(sections[0].title, "Richtung München")
        XCTAssertEqual(sections[0].departures.count, 2)
    }

    func testGroupsS2TowardsAltomünster() {
        let deps = [
            TransitDeparture(line: "S2", destination: "Altomünster", planned: date(9, 27), realtime: date(9, 27), cancelled: false)
        ]
        let sections = TransitGrouper.sections(for: deps, now: date(9, 8))
        XCTAssertEqual(sections[0].title, "Richtung Altomünster")
    }

    func testFiltersOutNonS2Lines() {
        let deps = [
            TransitDeparture(line: "S2", destination: "Ostbahnhof", planned: date(9, 21), realtime: date(9, 21), cancelled: false),
            TransitDeparture(line: "S8", destination: "Flughafen", planned: date(9, 25), realtime: date(9, 25), cancelled: false)
        ]
        let sections = TransitGrouper.sections(for: deps, now: date(9, 8))
        let allLines = sections.flatMap(\.departures).map(\.line)
        XCTAssertFalse(allLines.contains("S8"))
    }

    func testFiltersOutCancelledDepartures() {
        let deps = [
            TransitDeparture(line: "S2", destination: "Ostbahnhof", planned: date(9, 21), realtime: date(9, 21), cancelled: true)
        ]
        let sections = TransitGrouper.sections(for: deps, now: date(9, 8))
        XCTAssertTrue(sections.isEmpty)
    }

    func testDeparturesSortedByRealtime() {
        let deps = [
            TransitDeparture(line: "S2", destination: "Dachau",     planned: date(9, 51), realtime: date(9, 51), cancelled: false),
            TransitDeparture(line: "S2", destination: "Ostbahnhof", planned: date(9, 21), realtime: date(9, 21), cancelled: false)
        ]
        let sections = TransitGrouper.sections(for: deps, now: date(9, 8))
        XCTAssertEqual(sections[0].departures.first?.destination, "Ostbahnhof")
    }

    // MARK: - Helpers

    private func date(_ hour: Int, _ minute: Int) -> Date {
        DateComponents(
            calendar: .current,
            year: 2026, month: 6, day: 8,
            hour: hour, minute: minute
        ).date!
    }
}
