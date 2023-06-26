//
//  Pipelines.swift
//  MM3DUI
//
//  Created by Mohammad Jeragh on 23/07/2022.
//

import MetalKit

enum PipelineStates {
    static func createPSO(descriptor: MTLRenderPipelineDescriptor)
      -> MTLRenderPipelineState {
      let pipelineState: MTLRenderPipelineState
      do {
        pipelineState =
        try Renderer.device.makeRenderPipelineState(
          descriptor: descriptor)
      } catch let error {
        fatalError(error.localizedDescription)
      }
      return pipelineState
    }
    
    static func createComputePSO(computeFunction: MTLFunction) -> MTLComputePipelineState {
        let pipelineState: MTLComputePipelineState
        do {
          pipelineState =
          try Renderer.device.makeComputePipelineState(function: computeFunction)
        } catch let error {
          fatalError(error.localizedDescription)
        }
        return pipelineState
    }
    
    
    static func createGBufferPSO(colorPixelFormat: MTLPixelFormat, functionConstants: MTLFunctionConstantValues,
                                 tiled: Bool = false) -> MTLRenderPipelineState {
        let vertexFunction = try! Renderer.library?.makeFunction(name: "vertex_main", constantValues: functionConstants)
        let fragmentFunction = try! Renderer.library?.makeFunction(name: "fragment_gBuffer", constantValues: functionConstants)
      let pipelineDescriptor = MTLRenderPipelineDescriptor()
      pipelineDescriptor.vertexFunction = vertexFunction
      pipelineDescriptor.fragmentFunction = fragmentFunction
      pipelineDescriptor.colorAttachments[0].pixelFormat = .invalid
        if tiled {
            pipelineDescriptor.colorAttachments[0].pixelFormat = colorPixelFormat
        }
        pipelineDescriptor.setColorAttachmentPixelFormats()
      pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float_stencil8
            pipelineDescriptor.stencilAttachmentPixelFormat = .depth32Float_stencil8
        
      pipelineDescriptor.vertexDescriptor = .defaultPrimitiveLayout
      return createPSO(descriptor: pipelineDescriptor)
    }
    
    
    static func createForwardPSO(colorPixelFormat: MTLPixelFormat, functionConstants: MTLFunctionConstantValues) -> MTLRenderPipelineState {
      let vertexFunction = try! Renderer.library?.makeFunction(name: "vertex_main", constantValues: functionConstants)
      let fragmentFunction = try! Renderer.library?.makeFunction(name: "fragment_main", constantValues: functionConstants)
      let pipelineDescriptor = MTLRenderPipelineDescriptor()
      pipelineDescriptor.vertexFunction = vertexFunction
      pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = colorPixelFormat//Renderer.colorPixelFormat
      pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
      pipelineDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultPrimitiveLayout
    
      return createPSO(descriptor: pipelineDescriptor)
    }
    
    static func createSunLightPSO(colorPixelFormat: MTLPixelFormat,
                                  tiled: Bool = false) -> MTLRenderPipelineState {
          let vertexFunction = Renderer.library?.makeFunction(name: "vertex_quad")
        let fragment = tiled ? "fragment_tiled_deferredSun" : "fragment_deferredSun"
        let fragmentFunction = Renderer.library?.makeFunction(name: fragment)
          let pipelineDescriptor = MTLRenderPipelineDescriptor()
          pipelineDescriptor.vertexFunction = vertexFunction
          pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.colorAttachments[0].pixelFormat = colorPixelFormat//Renderer.colorPixelFormat
        if tiled {
            pipelineDescriptor.setColorAttachmentPixelFormats()
        }
            pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float_stencil8
            pipelineDescriptor.stencilAttachmentPixelFormat = .depth32Float_stencil8
        
        return createPSO(descriptor: pipelineDescriptor)
        }
    
    static func createPointLightPSO(colorPixelFormat: MTLPixelFormat,
                                    tiled: Bool = false) -> MTLRenderPipelineState {
      let vertexFunction = Renderer.library?.makeFunction(name: "vertex_pointLight")
        let fragment = tiled ? "fragment_tiled_pointLight" : "fragment_pointLight"
        let fragmentFunction = Renderer.library?.makeFunction(name: fragment)
      let pipelineDescriptor = MTLRenderPipelineDescriptor()
      pipelineDescriptor.vertexFunction = vertexFunction
      pipelineDescriptor.fragmentFunction = fragmentFunction
      pipelineDescriptor.colorAttachments[0].pixelFormat = colorPixelFormat
        if tiled {
                    pipelineDescriptor.setColorAttachmentPixelFormats()
                }
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float_stencil8
        pipelineDescriptor.stencilAttachmentPixelFormat = .depth32Float_stencil8
    
      pipelineDescriptor.vertexDescriptor =
        MTLVertexDescriptor.defaultPrimitiveLayout
      let attachment = pipelineDescriptor.colorAttachments[0]
      attachment?.isBlendingEnabled = true
      attachment?.rgbBlendOperation = .add
      attachment?.alphaBlendOperation = .add
      attachment?.sourceRGBBlendFactor = .one
      attachment?.sourceAlphaBlendFactor = .one
      attachment?.destinationRGBBlendFactor = .one
      attachment?.destinationAlphaBlendFactor = .zero
      attachment?.sourceRGBBlendFactor = .one
      attachment?.sourceAlphaBlendFactor = .one
      return createPSO(descriptor: pipelineDescriptor)
    }
    
    static func createReflectivePSO(colorPixelFormat: MTLPixelFormat, functionConstants: MTLFunctionConstantValues) -> MTLRenderPipelineState {
      let vertexFunction = try! Renderer.library?.makeFunction(name: "vertex_water", constantValues: functionConstants)
      let fragmentFunction = try! Renderer.library?.makeFunction(name: "fragment_water", constantValues: functionConstants)
      let pipelineDescriptor = MTLRenderPipelineDescriptor()
      pipelineDescriptor.vertexFunction = vertexFunction
      pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = colorPixelFormat//Renderer.colorPixelFormat
      pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        pipelineDescriptor.vertexDescriptor = .defaultPrimitiveLayout
      return createPSO(descriptor: pipelineDescriptor)
    }
    
    static func createShadowPSO() -> MTLRenderPipelineState {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        let vertexFunction = Renderer.library?.makeFunction(name: "vertex_depth")
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .invalid
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        pipelineDescriptor.vertexDescriptor = .defaultPrimitiveLayout
        return createPSO(descriptor: pipelineDescriptor)
    }
   
}

extension MTLRenderPipelineDescriptor {
  func setColorAttachmentPixelFormats() {
    colorAttachments[RenderTargetAlbedo.index]
      .pixelFormat = .bgra8Unorm
    colorAttachments[RenderTargetNormal.index]
      .pixelFormat = .rgba16Float
    colorAttachments[RenderTargetPosition.index]
      .pixelFormat = .rgba16Float
  }
}
