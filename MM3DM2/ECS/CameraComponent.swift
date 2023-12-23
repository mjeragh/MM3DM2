//
//  CameraComponent.swift
//  MM3DM2
//
//  Created by Mohammad Jeragh on 17/12/2023.
//

import Foundation
struct CameraComponent: Component {
    static var componentType = "Camera"
    
    var projectionMatrix: float4x4
    var viewMatrix: float4x4
    var aspect: Float
    var fov: Float
    var near: Float
    var far: Float

    init(aspect: Float, fov: Float, near: Float, far: Float) {
        self.aspect = aspect
        self.fov = fov
        self.near = near
        self.far = far
        self.projectionMatrix = float4x4(projectionFov: fov, near: near, far: far, aspect: aspect)
        self.viewMatrix = float4x4.identity // Initially set to identity matrix
    }

    mutating func updateProjectionMatrix() {
        projectionMatrix = float4x4(projectionFov: fov, near: near, far: far, aspect: aspect)
    }
}


struct FPCameraComponent: Component {
    static var componentType = "FPCamera"
    
    var transform: TransformComponent

    init(transform: TransformComponent) {
        self.transform = transform
    }

    mutating func updateViewMatrix() -> float4x4 {
        return (float4x4(translation: transform.position) * float4x4(rotation: transform.rotation)).inverse
    }
}

struct ArcballCameraComponent: Component {
    static var componentType = "ArcballCamera"
    
    var transform: TransformComponent
    var target: float3
    var distance: Float

    init(transform: TransformComponent, target: float3, distance: Float) {
        self.transform = transform
        self.target = target
        self.distance = distance
    }

    mutating func updateViewMatrix() -> float4x4 {
        let upDirection = float3(0, 1, 0)  // Assuming up is in the y-direction
        let cameraPosition = calculateCameraPosition()
        
        return float4x4(eye: cameraPosition, center: target, up: upDirection)
    }

    private func calculateCameraPosition() -> float3 {
        // Calculate spherical coordinates
        let sphericalRadius = distance
        let sphericalTheta = transform.rotation.x  // Assuming rotation.x is the azimuth angle
        let sphericalPhi = transform.rotation.y  // Assuming rotation.y is the elevation angle

        // Convert spherical coordinates to Cartesian coordinates for the camera position
        let x = sphericalRadius * sin(sphericalPhi) * cos(sphericalTheta)
        let y = sphericalRadius * cos(sphericalPhi)
        let z = sphericalRadius * sin(sphericalPhi) * sin(sphericalTheta)

        return float3(x, y, z) + target
    }

}
