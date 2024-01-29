import simd

class CameraSystem: System {
    var entities: [Entity] = []

    func setEntity(_ entities: [Entity]) {
        self.entities = entities
    }

    func update(deltaTime: Float) {
        for entity in entities {
            // Only proceed if both components are available.
            if var cameraComponent = entity.getComponent(CameraComponent.self),
               let transformComponent = entity.getComponent(TransformComponent.self) {
                
                // Update the camera based on its type.
                switch cameraComponent.type {
                case .firstPerson:
                    updateFirstPersonCamera(&cameraComponent, transformComponent, deltaTime: deltaTime)
                case .arcball:
                    updateArcballCamera(&cameraComponent, transformComponent, deltaTime: deltaTime)
                }
                
                // Update the projection matrix of the camera.
                cameraComponent.updateProjectionMatrix()
                
                // Apply the changes to the entity's component.
                entity.updateComponent(CameraComponent.self) { component in
                    component = cameraComponent
                }
            }
        }
    }

    private func updateFirstPersonCamera(_ camera: inout CameraComponent, _ transform: TransformComponent, deltaTime: Float) {
        // Update the camera's transform here based on input, etc.
        camera.viewMatrix = (float4x4(translation: transform.position) * float4x4(rotation: transform.rotation)).inverse
    }

    private func updateArcballCamera(_ camera: inout CameraComponent, _ transform: TransformComponent, deltaTime: Float) {
        // Update the camera's position around a target based on input, etc.
        let rotateMatrix = float4x4(rotationYXZ: [-transform.rotation.x, transform.rotation.y, 0])
        let distanceVector = float4(0, 0, -camera.distance, 0)
        let rotatedVector = rotateMatrix * distanceVector
        let position = camera.target + rotatedVector.xyz
        camera.viewMatrix = float4x4(eye: position, center: camera.target, up: [0, 1, 0])
    }

    private func entities(withComponents componentTypes: Component.Type...) -> [Entity] {
        return entities.filter { entity in
            componentTypes.allSatisfy { type in
                entity.getComponent(type) != nil
            }
        }
    }
}
