import SwiftUI

@main
struct AudioSourceApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: AudioRoutingViewModel())
                .frame(minWidth: 900, minHeight: 620)
        }
        .windowStyle(.titleBar)
    }
}

struct ContentView: View {
    @StateObject var viewModel: AudioRoutingViewModel

    var body: some View {
        NavigationSplitView {
            SidebarView(routingMode: $viewModel.routingMode)
        } detail: {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HeaderView(
                        globalOutput: $viewModel.globalOutput,
                        globalInput: $viewModel.globalInput,
                        captureEnabled: $viewModel.captureEnabled
                    )
                    AudioSourceListView(sources: viewModel.sources)
                    OutputDeviceListView(devices: viewModel.outputDevices)
                }
                .padding(24)
            }
        }
    }
}

struct SidebarView: View {
    @Binding var routingMode: RoutingMode

    var body: some View {
        List {
            Section("Routing") {
                ForEach(RoutingMode.allCases, id: \.self) { mode in
                    Label(mode.title, systemImage: mode.icon)
                        .tag(mode)
                }
            }
        }
        .listStyle(.sidebar)
    }
}

struct HeaderView: View {
    @Binding var globalOutput: AudioDevice
    @Binding var globalInput: AudioDevice
    @Binding var captureEnabled: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Audio Routing Studio")
                .font(.largeTitle.bold())
            Text("Split, mix, and re-route sound sources across devices. This prototype showcases the UI wiring for per-app routing and capture controls.")
                .foregroundStyle(.secondary)
            HStack(spacing: 16) {
                DevicePicker(
                    label: "System Output",
                    device: $globalOutput,
                    devices: AudioDevice.sampleOutputs
                )
                DevicePicker(
                    label: "System Input",
                    device: $globalInput,
                    devices: AudioDevice.sampleInputs
                )
                Toggle("Capture Loopback", isOn: $captureEnabled)
                    .toggleStyle(.switch)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(nsColor: .windowBackgroundColor))
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
        )
    }
}

struct AudioSourceListView: View {
    let sources: [AudioSource]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sources")
                .font(.title2.bold())
            ForEach(sources) { source in
                AudioSourceRow(source: source)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct AudioSourceRow: View {
    @State var source: AudioSource

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(source.tint.opacity(0.15))
                Image(systemName: source.icon)
                    .font(.title2)
                    .foregroundStyle(source.tint)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(source.name)
                        .font(.headline)
                    if source.isCapturing {
                        Label("Recording", systemImage: "waveform")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
                Text(source.description)
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                HStack(spacing: 12) {
                    DevicePicker(label: "Output", device: $source.output, devices: AudioDevice.sampleOutputs)
                    DevicePicker(label: "Input", device: $source.input, devices: AudioDevice.sampleInputs)
                    Toggle("Mute", isOn: $source.isMuted)
                        .toggleStyle(.switch)
                        .labelsHidden()
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                Text(source.level)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ProgressView(value: source.meter)
                    .progressViewStyle(.linear)
                    .frame(width: 120)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }
}

struct OutputDeviceListView: View {
    let devices: [AudioDevice]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Outputs")
                .font(.title2.bold())
            ForEach(devices) { device in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(device.name)
                            .font(.headline)
                        Text(device.details)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if device.isDefault {
                        Label("Default", systemImage: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct DevicePicker: View {
    let label: String
    @Binding var device: AudioDevice
    let devices: [AudioDevice]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Picker(label, selection: $device) {
                ForEach(devices) { item in
                    Text(item.name).tag(item)
                }
            }
            .pickerStyle(.menu)
        }
    }
}

final class AudioRoutingViewModel: ObservableObject {
    @Published var globalOutput: AudioDevice
    @Published var globalInput: AudioDevice
    @Published var captureEnabled: Bool
    @Published var routingMode: RoutingMode
    @Published var sources: [AudioSource]
    @Published var outputDevices: [AudioDevice]

    init() {
        globalOutput = AudioDevice.sampleOutputs[0]
        globalInput = AudioDevice.sampleInputs[0]
        captureEnabled = true
        routingMode = .perApp
        sources = AudioSource.sample
        outputDevices = AudioDevice.sampleOutputs
    }
}

enum RoutingMode: String, CaseIterable {
    case perApp
    case perChannel
    case broadcast

    var title: String {
        switch self {
        case .perApp: "Per App"
        case .perChannel: "Per Channel"
        case .broadcast: "Broadcast"
        }
    }

    var icon: String {
        switch self {
        case .perApp: "app.badge"
        case .perChannel: "slider.horizontal.3"
        case .broadcast: "dot.radiowaves.left.and.right"
        }
    }
}

struct AudioSource: Identifiable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let icon: String
    let tint: Color
    var output: AudioDevice
    var input: AudioDevice
    var isMuted: Bool
    var isCapturing: Bool
    var meter: Double
    var level: String

    static let sample: [AudioSource] = [
        AudioSource(
            id: UUID(),
            name: "Ableton Live",
            description: "Route tracks to external interfaces or stream mixdowns.",
            icon: "pianokeys",
            tint: .purple,
            output: AudioDevice.sampleOutputs[1],
            input: AudioDevice.sampleInputs[0],
            isMuted: false,
            isCapturing: true,
            meter: 0.74,
            level: "-6 dB"
        ),
        AudioSource(
            id: UUID(),
            name: "Zoom",
            description: "Separate call audio from notifications.",
            icon: "video",
            tint: .blue,
            output: AudioDevice.sampleOutputs[2],
            input: AudioDevice.sampleInputs[1],
            isMuted: false,
            isCapturing: false,
            meter: 0.42,
            level: "-12 dB"
        ),
        AudioSource(
            id: UUID(),
            name: "Safari",
            description: "Send browser audio to speakers and record the mix.",
            icon: "safari",
            tint: .orange,
            output: AudioDevice.sampleOutputs[0],
            input: AudioDevice.sampleInputs[0],
            isMuted: true,
            isCapturing: false,
            meter: 0.18,
            level: "-24 dB"
        )
    ]
}

struct AudioDevice: Identifiable, Hashable {
    let id: UUID
    let name: String
    let details: String
    let isDefault: Bool

    static let sampleOutputs: [AudioDevice] = [
        AudioDevice(
            id: UUID(),
            name: "Studio Display",
            details: "USB-C, 2 channel output",
            isDefault: true
        ),
        AudioDevice(
            id: UUID(),
            name: "Focusrite 2i2",
            details: "USB, 4 channel output",
            isDefault: false
        ),
        AudioDevice(
            id: UUID(),
            name: "Loopback Virtual",
            details: "Virtual, 8 channel output",
            isDefault: false
        )
    ]

    static let sampleInputs: [AudioDevice] = [
        AudioDevice(
            id: UUID(),
            name: "Built-in Mic",
            details: "1 channel input",
            isDefault: true
        ),
        AudioDevice(
            id: UUID(),
            name: "Shure MV7",
            details: "USB, 2 channel input",
            isDefault: false
        )
    ]
}
