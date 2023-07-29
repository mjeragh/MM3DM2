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

    
    var forwardRenderPass: ForwardRenderPass
    var shadowRenderPass: ShadowRenderPass

   private init(view: MTKView) {
        forwardRenderPass = ForwardRenderPass(view: view)
        shadowRenderPass = ShadowRenderPass(view: view)
    }

    func resize(view: MTKView, size: CGSize) {
        forwardRenderPass.resize(view: view, size: size)
        shadowRenderPass.resize(view: view, size: size)
    }

    func draw(commandBuffer: MTLCommandBuffer, scene: GameScene, uniforms: Uniforms, params: Params, view: MTKView) {
        guard let descriptor = view.currentRenderPassDescriptor else {
            return
        }

        // shadowRenderPass.draw(commandBuffer: commandBuffer, scene: scene, uniforms: uniforms, params: params)

        forwardRenderPass.descriptor = descriptor
        forwardRenderPass.shadowTexture = shadowRenderPass.shadowTexture
        forwardRenderPass.draw(commandBuffer: commandBuffer, scene: scene, uniforms: uniforms, params: params)
    }
}

