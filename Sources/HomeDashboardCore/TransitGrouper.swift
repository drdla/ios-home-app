import Foundation

// Groups S2 departures into direction sections. Directions are inferred from
// the destination name: destinations containing "München", "Ostbahnhof", or "Dachau"
// (when starting from Dachau Stadt) go towards Munich; others go towards Altomünster/Petershausen.

public enum TransitGrouper {

    public static func sections(
        for departures: [TransitDeparture],
        now: Date,
        lineFilter: String = "S2"
    ) -> [TransitSection] {
        let filtered = departures.filter { $0.line == lineFilter && !$0.cancelled }

        var directionBuckets: [String: [TransitDeparture]] = [:]
        for dep in filtered {
            let direction = directionTitle(for: dep.destination)
            directionBuckets[direction, default: []].append(dep)
        }

        let sorted = directionBuckets.map { title, deps in
            TransitSection(title: title, departures: deps.sorted { $0.realtime < $1.realtime })
        }.sorted { $0.title < $1.title }

        return sorted
    }

    // Maps a destination to the displayed "Richtung …" group title.
    static func directionTitle(for destination: String) -> String {
        let munichTerminals: Set<String> = [
            "Ostbahnhof", "München", "Marienplatz", "Hauptbahnhof"
        ]
        let altTerminals: Set<String> = [
            "Altomünster", "Altomünster Bf"
        ]
        let petersTerminals: Set<String> = [
            "Petershausen"
        ]

        for t in munichTerminals where destination.contains(t) {
            return "Richtung München"
        }
        for t in altTerminals where destination.contains(t) {
            return "Richtung Altomünster"
        }
        for t in petersTerminals where destination.contains(t) {
            return "Richtung Petershausen"
        }
        return "Richtung \(destination)"
    }
}
