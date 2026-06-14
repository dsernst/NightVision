import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        @Bindable var appModel = appModel
        VStack(spacing: 20) {
            Text("NightVision")
                .font(.title)

            Slider(value: $appModel.meshOpacity, in: 0...1)
                .frame(width: 300)
            Text("Intensity: \(Int(appModel.meshOpacity * 100))%")

            ToggleImmersiveSpaceButton()
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
