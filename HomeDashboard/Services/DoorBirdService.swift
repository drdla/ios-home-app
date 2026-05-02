import Foundation

// DoorBird local LAN API
// All communication is over the local network (NSLocalNetworkUsageDescription required).
// Credentials are stored in Keychain via SecretsStore.

struct DoorBirdService {
    var fetchSnapshot: () async throws -> DoorSnapshot
    var openDoor: () async throws -> Void

    static let live = DoorBirdService(
        fetchSnapshot: {
            let creds = try SecretsStore.doorBirdCredentials()
            let url = URL(string: "http://\(creds.host)/bha-api/image.cgi")!
            var req = URLRequest(url: url, timeoutInterval: 5)
            req.setValue(basicAuth(user: creds.user, password: creds.password), forHTTPHeaderField: "Authorization")
            let (_, response) = try await URLSession.shared.data(for: req)
            let ok = (response as? HTTPURLResponse)?.statusCode == 200
            return DoorSnapshot(title: "Haustür", isAvailable: ok)
        },
        openDoor: {
            let creds = try SecretsStore.doorBirdCredentials()
            let url = URL(string: "http://\(creds.host)/bha-api/open-door.cgi?r=1")!
            var req = URLRequest(url: url, timeoutInterval: 5)
            req.setValue(basicAuth(user: creds.user, password: creds.password), forHTTPHeaderField: "Authorization")
            let (_, response) = try await URLSession.shared.data(for: req)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                throw DoorBirdError.openFailed
            }
        }
    )

    static let mock = DoorBirdService(
        fetchSnapshot: { DashboardSnapshot.mockup.door },
        openDoor: { }
    )

    // HTTP Basic Auth header value
    private static func basicAuth(user: String, password: String) -> String {
        let cred = Data("\(user):\(password)".utf8).base64EncodedString()
        return "Basic \(cred)"
    }
}

enum DoorBirdError: LocalizedError {
    case openFailed

    var errorDescription: String? {
        switch self {
        case .openFailed: return "Tür konnte nicht geöffnet werden."
        }
    }
}

// MARK: - MJPEG Live Stream URL helper (used in DoorPanel Phase 6)

extension DoorBirdService {
    static func liveStreamURL(host: String, user: String, password: String) -> URL? {
        // DoorBird MJPEG endpoint – credentials embedded as query params per DoorBird API spec
        var comps = URLComponents(string: "http://\(host)/bha-api/video.cgi")
        comps?.queryItems = [
            URLQueryItem(name: "http-user",     value: user),
            URLQueryItem(name: "http-password", value: password)
        ]
        return comps?.url
    }
}
