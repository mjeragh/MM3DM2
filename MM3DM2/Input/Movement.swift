//
//  Movement.swift
//  MM3DUI
//
//  Created by Mohammad Jeragh on 15/07/2022.
//

enum Settings {
    static var rotationSpeed : Float { 0.5 }
    static var translationSpeed : Float { 30.0 }
    static var mouseScrollSensitivity : Float { 0.1 }
    static var mousePanSensitivity : Float { 0.008 }
    static var touchZoomSensitivity: Float { 10 }
}

protocol Movement where Self : Transformable {
}

extension Movement {
    func updateInput(deltaTime: Float) -> TransformComponent {
        var transform = Transform()
        let rotationAmount = deltaTime * Settings.rotationSpeed
        let input = InputController.shared
        
        if input.keysPressed.contains(.leftArrow){
            transform.rotation.y -= rotationAmount
        }
        
        if input.keysPressed.contains(.rightArrow){
            transform.rotation.y += rotationAmount
        }
        
        if input.keysPressed.contains(.upArrow){
            transform.rotation.x -= rotationAmount
        }
        
        if input.keysPressed.contains(.downArrow){
            transform.rotation.x += rotationAmount
        }

        
        var direction: float3 = .zero
     
        if input.keysPressed.contains(.keyW){
            direction.z += 1
        }
        if input.keysPressed.contains(.keyS){
            direction.z -= 1
        }
        if input.keysPressed.contains(.keyA){
            direction.x -= 1
        }
        if input.keysPressed.contains(.keyD){
            direction.x += 1
        }
        if input.keysPressed.contains(.keyQ){
            direction.y += 1
        }
        if input.keysPressed.contains(.keyZ){
            direction.y -= 1
        }
        
        let translationAmount = deltaTime * Settings.translationSpeed
        if direction != .zero {
            direction = normalize(direction)
            transform.position += (direction.z * forwardVector + direction.x * rightVector + direction.y * upVector) * translationAmount
            //transform.position += (direction.y * upVector) * translationAmount
        }
        
        return transform
    }
    
    var forwardVector: float3 {
        normalize([sin(rotation.y),0,cos(rotation.y)])
    }
    
    var rightVector: float3 {
        [forwardVector.z, forwardVector.y, -forwardVector.x]
    }
  
    var upVector : float3 {
        [0,1,0]
    }
}
