import SwiftUI

/// Right portion of the Home Automation section.
/// Shows DoorBird live/snapshot feed plus open-door and intercom buttons.
/// Sketch: Door group x=815 w=721 h=719 (÷2 → 360×359pt)
struct DoorPanel: View {
    let door: DoorSnapshot
    let lock: LockSnapshot
    @EnvironmentObject private var vm: AppViewModel
    @State private var showOpenConfirmation = false

    var body: some View {
        ZStack {
            // Video/snapshot feed
            DoorBirdFeedView(isAvailable: door.isAvailable)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()

            // Mute button – top right
            VStack {
                HStack {
                    Spacer()
                    MuteButton()
                        .padding(12)
                }
                Spacer()
            }

            // Action buttons – bottom
            VStack {
                Spacer()
                HStack {
                    // Open door
                    ActionButton(
                        systemImage: "key.horizontal",
                        tint: Color.buttonOpen,
                        accessibilityLabel: "Tür öffnen"
                    ) {
                        showOpenConfirmation = true
                    }
                    .padding(.leading, 12)

                    Spacer()

                    // Intercom / speak
                    ActionButton(
                        systemImage: "speaker.wave.2",
                        tint: Color.buttonSpeak,
                        accessibilityLabel: "Gegensprechanlage"
                    ) {
                        // Intercom action – to be wired in Phase 6
                    }
                    .padding(.trailing, 12)
                }
                .padding(.bottom, 10)
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .confirmationDialog("Tür öffnen?", isPresented: $showOpenConfirmation, titleVisibility: .visible) {
            Button("Öffnen", role: .destructive) {
                Task { await vm.openDoor() }
            }
            Button("Abbrechen", role: .cancel) {}
        }
    }
}

// MARK: - Live feed placeholder

private struct DoorBirdFeedView: View {
    let isAvailable: Bool

    var body: some View {
        if isAvailable {
            Image("DoorbirdMock")
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                Color.black
                VStack(spacing: 8) {
                    Image(systemName: "video.slash")
                        .font(.system(size: 40, weight: .thin))
                        .foregroundStyle(Color.textSecondary.opacity(0.4))
                    Text("Türklingel nicht erreichbar")
                        .font(DashboardFont.thin(Layout.fontSizeSmall))
                        .foregroundStyle(Color.textSecondary.opacity(0.6))
                }
            }
        }
    }
}

// MARK: - Action button (circular)

private struct ActionButton: View {
    let systemImage: String
    let tint: Color
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(tint)
                    .frame(width: 84, height: 84)
                Image(systemName: systemImage)
                    .font(.system(size: 32, weight: .thin))
                    .foregroundStyle(Color.white)
            }
        }
        .accessibilityLabel(accessibilityLabel)
    }
}

// MARK: - Mute button (small, top right)

private struct MuteButton: View {
    @State private var muted = false

    var body: some View {
        Button { muted.toggle() } label: {
            ZStack {
                Circle()
                    .fill(Color.surface.opacity(0.85))
                    .frame(width: 63, height: 63)
                Image(systemName: muted ? "speaker.slash" : "speaker.wave.2")
                    .font(.system(size: 24, weight: .thin))
                    .foregroundStyle(Color.textPrimary)
            }
        }
        .accessibilityLabel(muted ? "Ton ein" : "Ton aus")
    }
}

#Preview {
    DoorPanel(door: DoorSnapshot(title: "Haustür", isAvailable: true),
              lock: LockSnapshot(state: .locked))
        .environmentObject(AppViewModel())
        .frame(width: 360, height: 354)
}
