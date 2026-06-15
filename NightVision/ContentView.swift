import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @Environment(AppModel.self) private var appModel
    @State private var showAdvanced = false

    var body: some View {
        @Bindable var appModel = appModel
        VStack(spacing: 24) {
            Text("NightVision")
                .font(.title)

            ToggleImmersiveSpaceButton()

            Divider()

            DisclosureGroup("Advanced Settings", isExpanded: $showAdvanced) {
                VStack(spacing: 16) {
                    LabeledSlider(label: "Mesh Opacity", value: $appModel.meshOpacity, in: 0...0.3, format: "%d%%")
                    LabeledSlider(label: "Dots Opacity", value: $appModel.dotsOpacity, in: 0...0.5, format: "%d%%")
                    LabeledSlider(label: "Dot Density", value: $appModel.dotDensity, in: 0...100, format: "%d")
                    LabeledSlider(label: "Dot Size", value: $appModel.dotSize, in: 0.001...0.01, format: "%.4f")
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .frame(width: 360)
    }
}

struct LabeledSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let format: String

    init(label: String, value: Binding<Double>, in range: ClosedRange<Double>, format: String) {
        self.label = label
        self._value = value
        self.range = range
        self.format = format
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                Spacer()
                Text(formattedValue)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            Slider(value: $value, in: range)
        }
    }

    var formattedValue: String {
        if format.contains("%%") {
            return String(format: "%d%%", Int(value * 100))
        } else if format.contains("d") {
            return String(format: format, Int(value))
        } else {
            return String(format: format, value)
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
