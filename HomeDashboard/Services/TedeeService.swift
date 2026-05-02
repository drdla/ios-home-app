import Foundation

// Tedee Cloud API v38
// Auth: Personal Access Key stored in Keychain.
// Alternative: Tedee Bridge local API (same operations, LAN only).

struct TedeeService {
    var fetchLockState: () async throws -> LockSnapshot
    var lock:   () async throws -> Void
    var unlock: () async throws -> Void

    static let live = TedeeService(
        fetchLockState: {
            let creds = try SecretsStore.tedeeCredentials()
            let url = URL(string: "https://api.tedee.com/api/v38/my/lock/\(creds.lockId)/sync")!
            var req = URLRequest(url: url)
            req.setValue("PersonalKey \(creds.personalKey)", forHTTPHeaderField: "Authorization")
            let (data, _) = try await URLSession.shared.data(for: req)
            return try TedeeLockParser.parse(data)
        },
        lock: {
            try await tedeeOperation(path: "lock")
        },
        unlock: {
            try await tedeeOperation(path: "unlock")
        }
    )

    static let mock = TedeeService(
        fetchLockState: { DashboardSnapshot.mockup.lock },
        lock:   { },
        unlock: { }
    )

    private static func tedeeOperation(path: String) async throws {
        let creds = try SecretsStore.tedeeCredentials()
        let url = URL(string: "https://api.tedee.com/api/v38/my/lock/\(creds.lockId)/operation/\(path)")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("PersonalKey \(creds.personalKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let (_, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw TedeeError.operationFailed(path)
        }
    }
}

enum TedeeError: LocalizedError {
    case operationFailed(String)

    var errorDescription: String? {
        switch self {
        case .operationFailed(let op): return "Schloss-\(op) fehlgeschlagen."
        }
    }
}

// MARK: - Response parser

enum TedeeLockParser {
    private struct SyncResponse: Decodable {
        let result: LockStateResult
        struct LockStateResult: Decodable {
            let lockState: Int
        }
    }

    // Tedee lock state values: 1=uncalibrated, 2=calibrating, 3=locked, 4=unlocking,
    // 5=unlocked, 6=locking, 7=pulled, 9=unknown
    static func parse(_ data: Data) throws -> LockSnapshot {
        let r = try JSONDecoder().decode(SyncResponse.self, from: data)
        switch r.result.lockState {
        case 3, 6:  return LockSnapshot(state: .locked)
        case 5, 4:  return LockSnapshot(state: .unlocked)
        default:    return LockSnapshot(state: .unknown)
        }
    }
}
