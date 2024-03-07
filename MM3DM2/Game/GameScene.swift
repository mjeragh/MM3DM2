/// Copyright (c) 2022 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import MetalKit
import os.log

class GameScene {
 
    var entities = [GameEntity]()
    private var systems = [System]()
    var width : Float = 0.0
    var height : Float = 0.0
    var lighting = SceneLighting()
    var uniforms = Uniforms()
    var cameraEntity : GameEntity?
    
    let sunEntity, moonEntity, landEntity : GameEntity
    var counter = 0.0
    var cameraSystem : CameraSystem?
    //Note: I dont to access the renderSystem since Im passing the gamescene to the draw methoed in the rendereSystem
    //var redererSystem : RendererSystem?
    
    let logger = Logger(subsystem: "com.lanterntech.MM3DUI", category: "Gamescene")
   
  init() {
      
     landEntity = GameEntity(name: "land", id: UUID())
        moonEntity = GameEntity(name: "Moon", id: UUID())
      sunEntity = GameEntity(name: "Sun", id: UUID())
      
      addModelToEntity(entity: landEntity, name: "plane1000.usda", position: [0,0,0], rotation: float3(0,0,0), scale: 100)
      addModelToEntity(entity: sunEntity,name: "pegShader.usda", position: [2,22,43], rotation: float3(0,0,0), scale: 1.5)
      addModelToEntity(entity: sunEntity, name: "pegShader.usda", position: [0,20,0], rotation: float3(0,0,0), scale: 4.0)
      

      //chat set the sun as the light source
      //lighting.lights[0].position = [0,200,-100]
      cameraSetup()//This will add the camera to the entities array
      cameraSystem = CameraSystem()
      
      addSystem(cameraSystem!)
    }

    func cameraSetup() {
        // Create transform components for cameras
        let cameraTransform = TransformComponent(position: [0, 0, -320], rotation: [0, 0, 0])
        
        // Create a first person camera component
        let fpCameraComponent = CameraComponent(type: .firstPerson,
                                                transform: cameraTransform,
                                                aspect: 1.0, // Set the initial aspect ratio
                                                fov: Float(70).degreesToRadians,
                                                near: 0.1,
                                                far: 1000)
        
        // Create an arcball camera component
        var arcballCameraComponent = CameraComponent(type: .arcball,
                                                     transform: cameraTransform,
                                                     aspect: 1.0, // Set the initial aspect ratio
                                                     fov: Float(70).degreesToRadians,
                                                     near: 0.1,
                                                     far: 1000)
        arcballCameraComponent.target = [0,0,0]// Set the initial distance if needed
        arcballCameraComponent.distance = 320 // Set the initial distance if needed
        
        // Choose the camera type you want to create
        let chosenCameraComponent = arcballCameraComponent // or fpCameraComponent for first-person
        
        // Create camera entity and add components
        cameraEntity = GameEntity(name: "Camera")
        cameraEntity!.addComponent(cameraTransform)
        cameraEntity!.addComponent(chosenCameraComponent)
        
        // Append the camera entity to the entities array
        entities.append(cameraEntity!)
    }

    func update(size: CGSize) {
        self.width = Float(size.width)
        self.height = Float(size.height)
        uniforms.width = Float(size.width)
        uniforms.height = Float(size.height)
            // Here, you'd adjust any game-specific elements that depend on the size.
            // For example, if you have UI elements or gameplay areas that need to be resized
            // or repositioned based on the new view size, handle those adjustments here.
            
            // The camera aspect ratio and projection matrix updates are assumed to be handled by
            // the RendererSystem directly, as discussed.
            
            // If there are other systems or entities that need to be informed about the size change,
            // consider how best to propagate this information in a way that fits the ECS architecture.
       
    }
    
    func update(deltaTime: Float) {
//    let maxDistance: Float = 2
        let stride = 0.5 * deltaTime
        moonEntity.updateComponent(TransformComponent.self) { transform in
          transform.position = [30 * Float(cos(counter)), 22, -1.0 + 30 * Float(sin(counter))]
      }
      counter = counter + Double(stride)
    for system in systems {
      system.update(deltaTime: deltaTime)
    }

  }

    
    func addEntity(_ entity: GameEntity) {
            entities.append(entity)
            //redererSystem?.setEntities(entities)
        }

    func addSystem(_ system: System) {
            systems.append(system)
        }
    
   
    //from #ChatGPT
    func addModelToEntity(entity: GameEntity, name: String, position: float3, rotation: float3, scale: Float) {
        let modelComponent = ModelComponent(name: name)
        let transformComponent = TransformComponent(position: position, rotation: rotation, scale: scale)
        entity.addComponent(modelComponent)
        entity.addComponent(transformComponent)
        entities.append(entity)
    }

    
    func updateCameraAspectRatio(size: CGSize) {
        let aspectRatio = Float(size.width / size.height)
        
        for entity in entities where entity.hasComponent(CameraComponent.self) {
            if var cameraComponent = entity.getComponent(CameraComponent.self) {
                cameraComponent.aspect = aspectRatio
                cameraComponent.updateProjectionMatrix()
                entity.updateComponent(CameraComponent.self) { component in
                    component = cameraComponent
                }
            }
        }
    }

    
    func handleInteraction(at point: CGPoint){
        
    }
    
    func asyncInverse(){
        
    }
}
