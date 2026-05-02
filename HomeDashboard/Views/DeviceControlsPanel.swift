import SwiftUI

/// Left portion of the Home Automation section – 6 shortcut icon tiles in a 3×2 grid.
/// Each cell fills exactly one-third of the width and one-half of the height.
/// Sketch: two Tile rows each 811×359px (÷2 → 405.5×179.5pt)
/// Controls are visually rendered but inert in v1.
struct DeviceControlsPanel: View {
    let tiles: [ShortcutTile]

    var body: some View {
        GeometryReader { geo in
            let cellW = geo.size.width / 3
            let cellH = geo.size.height / 2

            ZStack(alignment: .topLeading) {
                Color.surface

                ForEach(Array(tiles.prefix(6).enumerated()), id: \.offset) { index, tile in
                    let col = index % 3
                    let row = index / 3

                    ShortcutTileView(tile: tile)
                        .frame(width: cellW, height: cellH)
                        .offset(x: CGFloat(col) * cellW, y: CGFloat(row) * cellH)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Single tile

private struct ShortcutTileView: View {
    let tile: ShortcutTile

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 10) {
                Image(systemName: tile.iconName)
                    .font(.system(size: geo.size.height * 0.28, weight: .thin))
                    .foregroundStyle(Color.textSecondary)
                    .frame(width: geo.size.height * 0.36, height: geo.size.height * 0.36)

                Text(tile.title)
                    .font(DashboardFont.thin(Layout.fontSizeSmall))
                    .foregroundStyle(Color.textSecondary)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    DeviceControlsPanel(tiles: DashboardSnapshot.mockup.shortcutTiles)
        .frame(width: 405, height: 354)
        .background(Color.surface)
}
