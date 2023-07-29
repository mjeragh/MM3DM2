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

class RendererSystem: System {
    
    //@UnwrapOrThrow var device = try? DeviceManager.shared().device
    
   static var colorPixelFormat : MTLPixelFormat!
    
    var options: Options
    
    let depthStencilState: MTLDepthStencilState
    
    var uniforms = Uniforms()
    var params = Params()
    
    var shadowCamera = OrthographicCamera()
    
    init(metalView: MTKView, options: Options) {
        
        
        RendererSystem.colorPixelFormat = metalView.colorPixelFormat
       
        metalView.device = try! DeviceManager.shared().device
        
        metalView.depthStencilPixelFormat = .depth32Float
      
        depthStencilState = RendererSystem.buildDepthStencilState()!
        
        self.options = options
       // super.init()
        

        metalView.clearColor = MTLClearColor(
            red: 0.01,
          green: 0.0,
            blue: 0.1,
          alpha: 1.0)
        metalView.depthStencilPixelFormat = .depth32Float
        mtkView(metalView, drawableSizeWillChange: metalView.bounds.size)
      
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
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
     //   scene?.sceneSizeWillChange(to: view.bounds.size)//, textureSize: size)
        RenderPassManager.shared.resize(view: view, size: size)
        }
    
        
    
    func updateUniforms(scene: GameScene) {
        uniforms.projectionMatrix = scene.camera.projectionMatrix
        uniforms.viewMatrix = scene.camera.viewMatrix
        params.cameraPosition = scene.camera.position
        params.lightCount = uint(scene.lighting.lights.count)
        
        shadowCamera.viewSize = 1650
//        shadowCamera.far = 400
        //FIXME: shadowcameraposition is the actual sun now, we need to care of the deferredRendering, for now the shadows are acceptable
        let sun = scene.lighting.lights[0]
        shadowCamera.position = sun.position
        shadowCamera.rotation.x = π/2
        
         uniforms.shadowProjectionMatrix = shadowCamera.projectionMatrix
        uniforms.shadowViewMatrix = float4x4(eye: sun.position, center: .zero, up: [0,1,0])
//        uniforms.viewMatrix = uniforms.shadowViewMatrix
//        uniforms.projectionMatrix = uniforms.shadowProjectionMatrix
    }
    
    func draw(scene: GameScene, in view: MTKView) {
        guard
            let commandBuffer = try! DeviceManager.shared().commandQueue.makeCommandBuffer(),
            let descriptor = view.currentRenderPassDescriptor
        else {
            return
        }
        
        updateUniforms(scene: scene)
        
        
//        shadowRenderPass.draw(commandBuffer: commandBuffer, scene: scene, uniforms: uniforms, params: params)
        
       forwardRenderPass.descriptor = descriptor
            forwardRenderPass.shadowTexture = shadowRenderPass.shadowTexture
            forwardRenderPass.draw(
              commandBuffer: commandBuffer,
              scene: scene,
              uniforms: uniforms,
              params: params)
       
        

        
        guard let drawable = view.currentDrawable else {
          return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
}
