//
//  RenderPassManager.swift
//  MM3DM2
//
//  Created by Mohammad Jeragh on 28/07/2023.
//

import Foundation
import MetalKit

class RenderPassManager {
    static var shared: RenderPassManager? // Singleton instance, to be initialized later
    
    private var view: MTKView // Private variable to hold the view
    var forwardRenderPass: ForwardRenderPass
    var shadowRenderPass: ShadowRenderPass

    private init() {
        // Initialize render passes with a placeholder view; will be updated later
        forwardRenderPass = ForwardRenderPass(view: MTKView())
        shadowRenderPass = ShadowRenderPass(view: MTKView())
    }

    // Singleton initialization method
    static func initialize(with view: MTKView) {
        shared = RenderPassManager()
        shared?.view = view // Set the view
        //shared?.forwardRenderPass.updateView(view: view) // Update render passes with the correct view
        //shared?.shadowRenderPass.updateView(view: view)
    }

    // Other methods remain the same

    func resize(view: MTKView, size: CGSize) {
        forwardRenderPass.resize(view: view, size: size)
        shadowRenderPass.resize(view: view, size: size)
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

