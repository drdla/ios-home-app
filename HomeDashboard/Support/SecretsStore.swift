import Foundation
import Security

// All sensitive credentials are stored in the system Keychain.
// Never stored in UserDefaults, source code, or config files.

enum SecretsStore {

    // MARK: - DoorBird

    struct DoorBirdCredentials {
        let host: String
        let user: String
        let password: String
    }

    static func doorBirdCredentials() throws -> DoorBirdCredentials {
        guard
            let host     = string(for: "doorbird.host"),
            let user     = string(for: "doorbird.user"),
            let password = string(for: "doorbird.password")
        else { throw CredentialError.missing("DoorBird") }
        return DoorBirdCredentials(host: host, user: user, password: password)
    }

    static func saveDoorBird(host: String, user: String, password: String) {
        save(host,     for: "doorbird.host")
        save(user,     for: "doorbird.user")
        save(password, for: "doorbird.password")
    }

    // MARK: - Tedee

    struct TedeeCredentials {
        let personalKey: String
        let lockId: Int
    }

    static func tedeeCredentials() throws -> TedeeCredentials {
        guard
            let key    = string(for: "tedee.personalKey"),
            let idStr  = string(for: "tedee.lockId"),
            let lockId = Int(idStr)
        else { throw CredentialError.missing("Tedee") }
        return TedeeCredentials(personalKey: key, lockId: lockId)
    }

    // MARK: - Credential error

    enum CredentialError: LocalizedError {
        case missing(String)
        var errorDescription: String? {
            switch self { case .missing(let s): return "\(s)-Zugangsdaten fehlen. Bitte in Einstellungen eingeben." }
        }
    }

    static func saveTedee(personalKey: String, lockId: Int) {
        save(personalKey,     for: "tedee.personalKey")
        save(String(lockId),  for: "tedee.lockId")
    }

    // MARK: - Generic Keychain helpers

    static func save(_ value: String, for key: String) {
        let data = Data(value.utf8)
        let query: [CFString: Any] = [
            kSecClass:            kSecClassGenericPassword,
            kSecAttrService:      "HomeDashboard",
            kSecAttrAccount:      key,
            kSecValueData:        data,
            kSecAttrAccessible:   kSecAttrAccessibleAfterFirstUnlock
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    static func string(for key: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: "HomeDashboard",
            kSecAttrAccount: key,
            kSecReturnData:  true,
            kSecMatchLimit:  kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data,
              let str  = String(data: data, encoding: .utf8)
        else { return nil }
        return str
    }

    static func delete(for key: String) {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: "HomeDashboard",
            kSecAttrAccount: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
