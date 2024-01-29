//
//  CameraComponent.swift
//  MM3DM2
//
//  Created by Mohammad Jeragh on 17/12/2023.
//

import simd

enum CameraType {
    case firstPerson
    case arcball
}

struct CameraComponent: Component {
    static var componentType = "Camera"
    
    var type: CameraType
    var transform: TransformComponent
    var aspect: Float
    var fov: Float
    var near: Float
    var far: Float
    var target: float3 = .zero // Default target for arcball camera
    var distance: Float = 1.0 // Default distance for arcball camera
    var viewMatrix: float4x4 = float4x4.identity
    var projectionMatrix: float4x4

    init(type: CameraType, transform: TransformComponent, aspect: Float, fov: Float, near: Float, far: Float) {
        self.type = type
        self.transform = transform
        self.aspect = aspect
        self.fov = fov
        self.near = near
        self.far = far
        self.projectionMatrix = float4x4(projectionFov: fov, near: near, far: far, aspect: aspect)
    }

    mutating func updateProjectionMatrix() {
        projectionMatrix = float4x4(projectionFov: fov, near: near, far: far, aspect: aspect)
    }
}
