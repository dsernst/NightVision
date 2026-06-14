import SwiftUI
import RealityKit
import ARKit

struct ImmersiveView: View {
    @Environment(AppModel.self) private var appModel

    let session = ARKitSession()
    let sceneReconstruction = SceneReconstructionProvider(modes: [.classification])
    
    @State private var meshEntities: [UUID: ModelEntity] = [:]
    @State private var rootEntity = Entity()
    
    var body: some View {
        RealityView { content in
            content.add(rootEntity)
        } update: { _ in
            updateAllMeshOpacity(appModel.meshOpacity)
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
    func updateAllMeshOpacity(_ opacity: Double) {
        for entity in meshEntities.values {
            entity.components.set(OpacityComponent(opacity: Float(opacity)))
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
        
        let meshDescriptor = anchor.geometry.asMeshDescriptor()
        guard let meshResource = try? MeshResource.generate(from: [meshDescriptor]) else { return }
        
        let entity = meshEntities[anchor.id] ?? ModelEntity()
        entity.transform = Transform(matrix: anchor.originFromAnchorTransform)
        
        var material = UnlitMaterial()
        material.color = .init(tint: .green.withAlphaComponent(CGFloat(appModel.meshOpacity)))
        entity.model = ModelComponent(mesh: meshResource, materials: [material])
        
        if meshEntities[anchor.id] == nil {
            meshEntities[anchor.id] = entity
            rootEntity.addChild(entity)
        }
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
