//
//  RenderPassManager.swift
//  MM3DM2
//
//  Created by Mohammad Jeragh on 28/07/2023.
//

import Foundation
import MetalKit
class RenderPassManager {
    static let shared = RenderPassManager(view: MTKView())
    private var view: MTKView!
    
    
    var forwardRenderPass: ForwardRenderPass
    var shadowRenderPass: ShadowRenderPass

   private init(view: MTKView) {
        forwardRenderPass = ForwardRenderPass(view: view)
        shadowRenderPass = ShadowRenderPass(view: view)
       self.view = view
    
    }

    func resize(view: MTKView, size: CGSize) {
        forwardRenderPass.resize(view: view, size: size)
        shadowRenderPass.resize(view: view, size: size)
        self.view = view //Im not sure about this
    
    }

    func draw(commandBuffer: MTLCommandBuffer, scene: GameScene, uniforms: Uniforms, params: Params, view: MTKView) {
        
        guard /*let commandBuffer = try! DeviceManager.shared().commandQueue.makeCommandBuffer(),*/
            //I dont need to make another command buffer, I can use the one that is passed to me
            
                let descriptor = view.currentRenderPassDescriptor else {
            return
        }

        // shadowRenderPass.draw(commandBuffer: commandBuffer, scene: scene, uniforms: uniforms, params: params)

        forwardRenderPass.descriptor = descriptor
        forwardRenderPass.shadowTexture = shadowRenderPass.shadowTexture
        forwardRenderPass.draw(commandBuffer: commandBuffer, scene: scene, uniforms: uniforms, params: params)
    }
}

