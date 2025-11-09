import SwiftUI
import AppKit

@main
struct HourlyChimeApp: App {
    @StateObject private var scheduler = HourlyChimeScheduler()

    var body: some Scene {
        MenuBarExtra {
            MenuContentView(viewModel: scheduler)
        } label: {
            Label("Hourly Chime", systemImage: scheduler.menuBarIconName)
        }
        .menuBarExtraStyle(.window)
    }
}

struct MenuContentView: View {
    @ObservedObject var viewModel: HourlyChimeScheduler

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Toggle(isOn: $viewModel.isEnabled) {
                Text(viewModel.isEnabled ? "Chime enabled" : "Chime paused")
            }
            .toggleStyle(.switch)

            VStack(alignment: .leading, spacing: 4) {
                Text("Next chime")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(viewModel.nextChimeDescription)
                    .font(.title3.weight(.medium))
            }

            HStack {
                Button("Ring Now") {
                    viewModel.ringNow()
                }
                .disabled(!viewModel.canRingNow)

                Spacer()

                Button("Quit") {
                    NSApp.terminate(nil)
                }
            }
        }
        .padding(20)
        .frame(width: 260)
    }
}

@MainActor
final class HourlyChimeScheduler: ObservableObject {
    @Published var isEnabled: Bool = true {
        didSet {
            if isEnabled {
                scheduleNextChime()
            } else {
                cancelTimer()
            }
        }
    }

    @Published private(set) var nextChimeDate: Date?

    var menuBarIconName: String {
        isEnabled ? "bell.fill" : "bell.slash"
    }

    var nextChimeDescription: String {
        guard let nextChimeDate else {
            return isEnabled ? "Scheduling…" : "Disabled"
        }

        return Self.timeFormatter.string(from: nextChimeDate)
    }

    var canRingNow: Bool {
        isEnabled
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()

    private let calendar = Calendar(identifier: .gregorian)
    private var timer: Timer?
    private let chimeSound: NSSound? = {
        let sound = NSSound(named: NSSound.Name("Glass"))
        sound?.loops = false
        sound?.volume = 1.0
        return sound
    }()

    init() {
        scheduleNextChime()
    }

    func ringNow() {
        guard canRingNow else { return }
        playChime()
        scheduleNextChime()
    }

    private func scheduleNextChime() {
        cancelTimer()

        guard isEnabled else {
            nextChimeDate = nil
            return
        }

        let now = Date()
        guard let nextHour = nextTopOfHour(from: now) else {
            nextChimeDate = nil
            return
        }

        nextChimeDate = nextHour
        let timer = Timer(
            fireAt: nextHour,
            interval: 0,
            target: self,
            selector: #selector(handleTimerFire),
            userInfo: nil,
            repeats: false
        )
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    private func nextTopOfHour(from date: Date) -> Date? {
        var components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        components.minute = 0
        components.second = 0
        if let hour = components.hour {
            components.hour = hour + 1
        }
        return calendar.date(from: components)
    }

    private func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }

    @objc
    private func handleTimerFire() {
        playChime()
        scheduleNextChime()
    }

    private func playChime() {
        if let chimeSound {
            chimeSound.stop()
            chimeSound.currentTime = 0
            chimeSound.play()
        } else {
            NSSound.beep()
        }
    }
}
