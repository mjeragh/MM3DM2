//
//  Renderer.swift
//  MM3DM1
//
//  Created by Mohammad Jeragh on 18/06/2021.
//

// Our platform independent renderer class

import Metal
import MetalKit
import simd

// The 256 byte aligned size of our uniform structure
//let alignedUniformsSize = (MemoryLayout<Uniforms>.size + 0xFF) & -0x100

let maxBuffersInFlight = 3



enum RendererError: Error {
    case badVertexDescriptor
}

class RendererSystem: SizeAwareSystem {
   
    var colorPixelFormat : MTLPixelFormat!
    var options: Options
    let depthStencilState: MTLDepthStencilState
    var uniforms = Uniforms()
    var params = Params()
    
    init(metalView: MTKView, options: Options) {
        self.colorPixelFormat = metalView.colorPixelFormat
        metalView.device = try! DeviceManager.shared().device
        metalView.depthStencilPixelFormat = .depth32Float
        depthStencilState = RendererSystem.buildDepthStencilState()!
        self.options = options
        metalView.clearColor = MTLClearColor(red: 0.01, green: 0.0, blue: 0.1, alpha: 1.0)
        metalView.depthStencilPixelFormat = .depth32Float
        mtkView(metalView, drawableSizeWillChange: metalView.bounds.size)
    }
    
    // This function will be called from the GameController
        func updateViewProjection(viewMatrix: float4x4, projectionMatrix: float4x4) {
            uniforms.viewMatrix = viewMatrix
            uniforms.projectionMatrix = projectionMatrix
        }
    
    
     static func buildDepthStencilState() -> MTLDepthStencilState? {
      let descriptor = MTLDepthStencilDescriptor()
      descriptor.depthCompareFunction = .lessEqual
      descriptor.isDepthWriteEnabled = true
      return
         try! DeviceManager.shared().device.makeDepthStencilState(descriptor: descriptor)
    }
    
    func initialize(_ scene: GameScene) {
//      TextureController.heap = TextureController.buildHeap()
//      for model in scene.models {
//        model.meshes = model.meshes.map { mesh in
//          var mesh = mesh
//          mesh.submeshes = mesh.submeshes.map { submesh in
//            var submesh = submesh
//            submesh.initializeMaterials()
//            return submesh
//          }
//          return mesh
//        }
//      }
    }
    
}
    
extension RendererSystem {
    
    
    func update(size: CGSize, for scene: GameScene) {
            // Update the aspect ratio and any other size-dependent states here.
            // This typically involves updating the camera's projection matrix to
            // accommodate the new aspect ratio of the view.

            // Ensure that you have a reference to the camera entity or component
            // to update its projection matrix. You could pass the GameScene or
            // CameraEntity to this function to access the camera component.

            // Example of updating the camera's aspect ratio:
          
        scene.updateCameraAspectRatio(size: size)
            // Notify the RenderPassManager about the size change if it's responsible
            // for handling render targets with specific sizes.
        //FIXME: RenderPassManager.shared?.resize(view: metalView, size: size) was not commetted out, but the forwardpass manager was empty, so I commented it out, I will figure it out later
        // RenderPassManager.shared?.resize(view: metalView, size: size)
        }
    func update(deltaTime: Float) {
        <#code#>
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
     //   scene?.sceneSizeWillChange(to: view.bounds.size)//, textureSize: size)
        RenderPassManager.shared!.resize(view: view, size: size)
        }
    
    
    func updateUniforms(scene: GameScene) {
        let cameraComponent = scene.cameraEntity.getComponent(CameraComponent.self)!
        uniforms.projectionMatrix = scene.cameraEntity.getComponent(CameraComponent.self)!.projectionMatrix
        uniforms.viewMatrix = scene.cameraEntity.getComponent(CameraComponent.self)!.viewMatrix
        params.cameraPosition = scene.cameraEntity.getComponent(TransformComponent.self)!.position
        params.lightCount = uint(scene.lighting.lights.count)
      
    }
    
    func draw(scene: GameScene, in view: MTKView) {
        guard
            let commandBuffer = try! DeviceManager.shared().commandQueue.makeCommandBuffer()
         else {
            return
        }
        updateUniforms(scene: scene)
        RenderPassManager.shared!.draw(commandBuffer: commandBuffer, scene: scene, uniforms: uniforms, params: params, view: view)
        guard let drawable = view.currentDrawable else {
          return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    
   
    
    
}
