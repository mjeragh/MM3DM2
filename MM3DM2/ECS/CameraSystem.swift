//
//  CameraSystem.swift
//  MM3DM2
//
//  Created by Mohammad Jeragh on 28/01/2024.
//

import simd

class CameraSystem: System {
    var entities : [Entity] = []
    
    func setEntity(_ entities: [Entity]) {
        self.entities = entities
    }
    
    func update(deltaTime: Float) {
        for entity in entities(withComponents: CameraComponent.self, TransformComponent.self) {
            guard var cameraComponent = entity.getComponent(CameraComponent.self),
                  let transformComponent = entity.getComponent(TransformComponent.self) else { continue }
            
            switch cameraComponent.type {
            case .firstPerson:
                updateFirstPersonCamera(&cameraComponent, transformComponent, deltaTime: deltaTime)
            case .arcball:
                updateArcballCamera(&cameraComponent, transformComponent, deltaTime: deltaTime)
            }

            cameraComponent.updateProjectionMatrix() // Update projection matrix
            entity.updateComponent(cameraComponent)
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
}
