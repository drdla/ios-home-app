import SwiftUI

// MARK: - Destinations

/// All detail views reachable by tapping a shortcut tile.
/// Add a new case here when wiring up a new tile.
enum ShortcutDestination: String, Identifiable {
    case solarbank
    var id: String { rawValue }
}

// MARK: - Panel

/// Left portion of the Home Automation section – 6 shortcut icon tiles in a 3×2 grid.
/// Each cell fills exactly one-third of the width and one-half of the height.
/// Sketch: two Tile rows each 811×359px (÷2 → 405.5×179.5pt)
///
/// Pass `destinations` to make specific tiles open a detail sheet.
/// Key = tile.iconName, value = destination to present.
struct DeviceControlsPanel: View {
    let tiles: [ShortcutTile]
    var destinations: [String: ShortcutDestination] = [:]

    @State private var presented: ShortcutDestination?

    var body: some View {
        GeometryReader { geo in
            let cellW = geo.size.width / 3
            let cellH = geo.size.height / 3

            ZStack(alignment: .topLeading) {
                Color.surface

                ForEach(0..<9, id: \.self) { index in
                    let col = index % 3
                    let row = index / 3

                    if index < tiles.count {
                        let tile = tiles[index]
                        let dest = destinations[tile.iconName]

                        ShortcutTileView(tile: tile, isLinked: dest != nil) {
                            presented = dest
                        }
                        .frame(width: cellW, height: cellH)
                        .offset(x: CGFloat(col) * cellW, y: CGFloat(row) * cellH)
                    }
                    // empty cells render as plain surface background — no view needed
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(item: $presented) { dest in
            switch dest {
            case .solarbank:
                SolarbankDetailView()
            }
        }
    }
}

// MARK: - Single tile

private struct ShortcutTileView: View {
    let tile: ShortcutTile
    let isLinked: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            GeometryReader { geo in
                let iconSize = geo.size.height * 0.72

                VStack(spacing: 6) {
                    Image(tile.iconName)
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(isLinked ? Color.textPrimary : Color.textPrimary.opacity(0.45))
                        .frame(width: iconSize, height: iconSize)

                    Text(tile.title)
                        .font(DashboardFont.thin(Layout.fontSizeSmall))
                        .foregroundStyle(isLinked ? Color.textSecondary : Color.textSecondary.opacity(0.45))
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            }
        }
        .buttonStyle(TileButtonStyle())
        .disabled(!isLinked)
    }
}

/// Subtle press feedback: dims to 70% while held, no animation lag.
private struct TileButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.7 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

#Preview {
    DeviceControlsPanel(
        tiles: DashboardSnapshot.mockup.shortcutTiles,
        destinations: ["appliance": .solarbank]
    )
    .frame(width: 405, height: 354)
    .background(Color.surface)
}
