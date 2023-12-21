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

struct GameScene {
 
    var counter = 0.0
    var entities : [GameEntity] = []
    //var selectedProperty : Properties! = nil
    var width : Float = 0.0
    var height : Float = 0.0
   var lighting = SceneLighting()
    var uniforms = Uniforms()
    
    let fpCameraEntity, arcballCameraEntity, sunEntity, moonEntity, landEntity : GameEntity
//    var pegs : [Model] = Array(repeating:Model(name: "peg.usda"), count: 8)
//    var colors : [float3] = [[1,0,0],[0,1,0],[0,0,1],[1,1,0],[1,0,1],[0,1,1],[0,0,0],[1,1,1]]
    
    //GPU Definition
    let sharedDevice = try! DeviceManager.shared().device
    let commandQueue = try! DeviceManager.shared().device.makeCommandQueue()
    var commandBuffer : MTLCommandBuffer!
    var computeEncoder : MTLComputeCommandEncoder!
    var computePipelineState: MTLComputePipelineState!
    var nodeGPUBuffer : MTLBuffer!
    var GPUBufferLength : Int
    let logger = Logger(subsystem: "com.lanterntech.MM3DUI", category: "Gamescene")
    let totalBuffer = try! DeviceManager.shared().device.makeBuffer(length: MemoryLayout<Int>.stride, options: [])
    
    var uniformBuffer = try! DeviceManager.shared().device.makeBuffer(length: MemoryLayout<Uniforms>.stride, options: [])
    let answer : UnsafeMutablePointer<Int>
    let uniformPointer : UnsafeMutablePointer<Uniforms>
    
  init() {
      answer = (totalBuffer?.contents().bindMemory(to: Int.self, capacity: 1))!
      uniformPointer = (uniformBuffer?.contents().bindMemory(to: Uniforms.self, capacity: 1))!
      landEntity = createModelEntity(name: "plane1000.usda", position: [0,0,0], rotation: float3(0,0,0), scale: 100, id: UUID())
      moonEntity = createModelEntity(name: "pegShader.usda", position: [2,22,43], rotation: float3(0,0,0), scale: 1.5, id: UUID())
      sunEntity = createModelEntity(name: "pegShader.usda", position: [0,20,0], rotation: float3(0,0,0), scale: 4.0, id: UUID())
      
      // Set additional properties on landEntity if needed

      //land.position = [0,0,0]
      //land.materials.baseColor = [0.01,0.51,0.01]
//      models.append(land)
//      for number in 0..<8 {
//          pegs[number] = Model(name: "pegShader.usda")
//          pegs[number].position = [150,8,Float(120 + number * -35)]
//          pegs[number].features.interactive = true
//          models.append(pegs[number])
//      }
//      moon = Model(name: "pegShader.usda")
//      moon.scale = 1.5
//      sun = Model(name: "pegShader.usda")
//      sun.scale = 4.0
//      
//      sun.position = [0,20,0]
//      moon.position = [2,22,43]
//      
//      models.append(sun)
//      models.append(moon)
//      
      sunEntity.entityID.name = "Sun"
      moonEntity.entityID.name = "Moon"
      landEntity.entityID.name = "land"
//      sun.materials.baseColor = [1,0,0]
//      sun.materials.secondColor = [1,0,1]
//      sun.materials.shininess = 32;
//      sun.materials.specularColor = [1,0,0]
//      moon.materials.baseColor = [0,0,1]
      
      //camera.far = 1000
      camera.position = [0,0,-320]
      camera.distance = length(camera.position)
      camera.target = [0, 0, 0]
      camera.rotation.x =  -π / 4
      
      lighting.lights[0].position = [0,200,-100]
      
//      GPUBufferLength = 0
//      buildGPUBuffers()
      uniforms.viewMatrix = camera.viewMatrix.inverse
      uniforms.projectionMatrix = camera.projectionMatrix.inverse
      
    }


  mutating func update(size: CGSize) {
    fpCameraEntity.update(size: size)
    arcballCameraEntity.update(size: size)
  }

  mutating func update(deltaTime: Float) {
//    let maxDistance: Float = 2
    let stride = 0.5 * deltaTime
      moon.position =  [30 * Float( cos(counter)), 22 ,-1.0 + 30 * Float(sin(counter))]
      counter = counter + Double(stride)
    for model in models {
      model.update(deltaTime: deltaTime)
    }
   
    camera.update(deltaTime: deltaTime)
//    print(camera.position, camera.rotation)
//      if !(InputController.shared.keysPressed.isEmpty) {
//          print("key Pressed \(String(describing: InputController.shared.keysPressed.popFirst()))")
//      }
  }
    mutating func handleInteraction(at point: CGPoint) {
       let startTime = CFAbsoluteTimeGetCurrent()
        uniforms.point.x = Float(point.x)
        uniforms.point.y = Float(point.y)
//        uniforms.projectionMatrix = camera.projectionMatrix
//        uniforms.viewMatrix = camera.viewMatrix
        
        
        uniformPointer.pointee = uniforms
        
        commandBuffer = commandQueue!.makeCommandBuffer()
        computeEncoder = commandBuffer.makeComputeCommandEncoder()
        computeEncoder.pushDebugGroup("handleInteraction")
        
//        uniforms.origin = worldRayOrigin
//        uniforms.direction = worldRayDir
        
        //setup local rays
        // I have to figure this out!
        
        answer.pointee = 8
        computeEncoder.setBuffer(totalBuffer, offset: 0, index: 2)
        
        computeEncoder?.setBuffer(nodeGPUBuffer, offset: 0, index: 0)
        computeEncoder.setBuffer(uniformBuffer, offset: 0, index: 1)
        let computeFunction = try! DeviceManager.shared().device.makeDefaultLibrary()?.makeFunction(name: "testKernel")!//(name: "raytracingKernel")!
        computePipelineState = try! DeviceManager.shared().device.makeComputePipelineState(function: computeFunction!)
        computeEncoder?.setComputePipelineState(computePipelineState)
        let threadsPerThreadGrid = MTLSizeMake(GPUBufferLength, 1, 1)
        computeEncoder?.dispatchThreadgroups(threadsPerThreadGrid, threadsPerThreadgroup: MTLSizeMake(1, 1, 1))
        computeEncoder?.endEncoding()
        computeEncoder?.popDebugGroup()
//        commandBuffer.addCompletedHandler{
//            _ in
//            (self.answer.pointee > 7) ? print("no hit") : print("Hit peg\(self.answer.pointee)")
//            print("CPU and GPU selected time:\(CFAbsoluteTimeGetCurrent() - startTime)")
//        }
        commandBuffer?.commit()
//        uniforms.viewMatrix = camera.viewMatrix.inverse
//        uniforms.projectionMatrix = camera.projectionMatrix.inverse
        commandBuffer?.waitUntilCompleted()

        (answer.pointee > 7) ? logger.debug("no hit") : print("Hit peg\(answer.pointee)")
        logger.debug("time: \(CFAbsoluteTimeGetCurrent() - startTime)")
//        logger.debug("CPU and GPU selected time:\(CFAbsoluteTimeGetCurrent() - startTime)")
//        pointer = nodeGPUBuffer?.contents().bindMemory(to: NodeGPU.self, capacity: GPUBufferLength) //debugging purpose
    }
    
    mutating func asyncInverse() async {
        uniforms.viewMatrix = await camera.viewMatrix.asyncInverse!
        uniforms.projectionMatrix = await camera.projectionMatrix.asyncInverse!
    }
    
    mutating func buildGPUBuffers() {
        
        //creating Bounding Buffer
        
        models.forEach{ model in
            GPUBufferLength += (model as! Properties).interactive ? 1 : 0
            }
        
        nodeGPUBuffer = try! DeviceManager.shared().device.makeBuffer(length: GPUBufferLength * MemoryLayout<NodeGPU>.stride, options: .storageModeShared)
     
        //need to compute the local rays
        var pointer = nodeGPUBuffer?.contents().bindMemory(to: NodeGPU.self, capacity: GPUBufferLength)
        
        //rootNode.children.forEach
        models.forEach{ model in
            if var item = model as? Properties {
                if item.interactive {
                                    item.nodeGPU.modelMatrix = model.transform.modelMatrix
                                    pointer?.pointee = item.nodeGPU
                                    pointer = pointer?.advanced(by: 1) //from page 451 metalbytutorialsV2
                            }
            }
            
       }//EachModel
        
        
    }
    //from #ChatGPT
    func createModelEntity(name: String, position: float3, rotation: float3, scale: Float, id: UUID = UUID()) -> GameEntity {
        var entity = GameEntity(name: name, id: id)
        let modelComponent = ModelComponent(name: name)
        let transformComponent = TransformComponent(position: position, rotation: rotation, scale: scale)
        entity.addComponent(modelComponent)
        entity.addComponent(transformComponent)
        entities.append(entity)
        return entity
    }

}
