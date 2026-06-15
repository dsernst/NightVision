import SwiftUI
import RealityKit
import ARKit

struct ImmersiveView: View {
    @Environment(AppModel.self) private var appModel

    let session = ARKitSession()
    let sceneReconstruction = SceneReconstructionProvider(modes: [.classification])

    @State private var meshEntities: [UUID: Entity] = [:]
    @State private var rootEntity = Entity()

    var body: some View {
        RealityView { content in
            content.add(rootEntity)
        } update: { _ in
            updateAllOpacity()
        }
        .task {
            do {
                try await session.run([sceneReconstruction])
                for await update in sceneReconstruction.anchorUpdates {
                    await updateMesh(update: update)
                }
            } catch {
                print("ARKit error: \(error)")
            }
        }
    }

    @MainActor
    func updateAllOpacity() {
        for container in meshEntities.values {
            for child in container.children {
                guard let modelChild = child as? ModelEntity else { continue }
                if modelChild.name == "dot" {
                    modelChild.components.set(OpacityComponent(opacity: Float(appModel.dotsOpacity)))
                } else if modelChild.name == "mesh" {
                    modelChild.components.set(OpacityComponent(opacity: Float(appModel.meshOpacity)))
                }
            }
        }
    }

    @MainActor
    func updateMesh(update: AnchorUpdate<MeshAnchor>) async {
        let anchor = update.anchor

        if update.event == .removed {
            meshEntities[anchor.id]?.removeFromParent()
            meshEntities.removeValue(forKey: anchor.id)
            return
        }

        meshEntities[anchor.id]?.removeFromParent()

        let geometry = anchor.geometry
        let anchorTransform = anchor.originFromAnchorTransform
        let containerEntity = Entity()
        containerEntity.transform = Transform(matrix: anchorTransform)

        // --- Base solid mesh (faint) ---
        let meshDescriptor = geometry.asMeshDescriptor()
        if let meshResource = try? MeshResource.generate(from: [meshDescriptor]) {
            var material = UnlitMaterial()
            material.color = .init(tint: UIColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 1.0))
            let meshEntity = ModelEntity(mesh: meshResource, materials: [material])
            meshEntity.name = "mesh"
            meshEntity.components.set(OpacityComponent(opacity: Float(appModel.meshOpacity)))
            containerEntity.addChild(meshEntity)
        }

        // --- Point cloud dots ---
        let vertexCount = geometry.vertices.count
        let vertexStride = geometry.vertices.stride
        let vertexBuffer = geometry.vertices.buffer.contents()
        let step = max(20, Int(101 - appModel.dotDensity))

        for i in stride(from: 0, to: vertexCount, by: step) {
            let ptr = vertexBuffer.advanced(by: i * vertexStride)
            var localPos = SIMD3<Float>()
            memcpy(&localPos, ptr, MemoryLayout<SIMD3<Float>>.size)

            let worldPos = (anchorTransform * SIMD4<Float>(localPos.x, localPos.y, localPos.z, 1)).xyz
            let distance = length(worldPos)
            let radius = Float(max(0.001, appModel.dotSize - Double(distance) * 0.001))

            let dot = ModelEntity(mesh: .generateSphere(radius: radius), materials: [])
            var material = UnlitMaterial()
            material.color = .init(tint: UIColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 1.0))
            dot.model?.materials = [material]
            dot.name = "dot"
            dot.position = localPos
            dot.components.set(OpacityComponent(opacity: Float(appModel.dotsOpacity)))
            containerEntity.addChild(dot)
        }

        meshEntities[anchor.id] = containerEntity
        rootEntity.addChild(containerEntity)
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}

extension MeshAnchor.Geometry {
    func asMeshDescriptor() -> MeshDescriptor {
        var descriptor = MeshDescriptor()

        let vertexCount = vertices.count
        let vertexStride = vertices.stride
        let vertexBuffer = vertices.buffer.contents()
        var positions: [SIMD3<Float>] = []
        for i in 0..<vertexCount {
            let ptr = vertexBuffer.advanced(by: i * vertexStride)
            var v = SIMD3<Float>()
            memcpy(&v, ptr, MemoryLayout<SIMD3<Float>>.size)
            positions.append(v)
        }
        descriptor.positions = MeshBuffers.Positions(positions)

        let faceCount = faces.count
        let indexBuffer = faces.buffer.contents()
        var indices: [UInt32] = []
        for i in 0..<(faceCount * 3) {
            let ptr = indexBuffer.advanced(by: i * MemoryLayout<UInt32>.size)
            var idx: UInt32 = 0
            memcpy(&idx, ptr, MemoryLayout<UInt32>.size)
            indices.append(idx)
        }
        descriptor.primitives = .triangles(indices)

        return descriptor
    }
}

extension SIMD4 {
    var xyz: SIMD3<Scalar> { SIMD3(x, y, z) }
}
