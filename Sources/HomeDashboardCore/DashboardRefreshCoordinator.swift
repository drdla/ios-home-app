import Foundation

public protocol DashboardRefreshSource: AnyObject, Sendable {
    func refresh() async
}

public actor DashboardRefreshCoordinator {
    private let sources: [any DashboardRefreshSource]

    public init(sources: [any DashboardRefreshSource]) {
        self.sources = sources
    }

    /// Triggers a full parallel refresh of all registered sources.
    /// Called when the app enters the foreground or is unlocked.
    public func refreshOnForeground() async {
        await withTaskGroup(of: Void.self) { group in
            for source in sources {
                group.addTask { await source.refresh() }
            }
        }
    }
}
