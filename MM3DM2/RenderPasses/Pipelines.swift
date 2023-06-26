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
    
    
    
    
    
    static func createForwardPSO(colorPixelFormat: MTLPixelFormat, functionConstants: MTLFunctionConstantValues) -> MTLRenderPipelineState {
      let vertexFunction = try! Renderer.library?.makeFunction(name: "vertex_main", constantValues: functionConstants)
      let fragmentFunction = try! Renderer.library?.makeFunction(name: "fragment_normals", constantValues: functionConstants)
      let pipelineDescriptor = MTLRenderPipelineDescriptor()
      pipelineDescriptor.vertexFunction = vertexFunction
      pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = colorPixelFormat//Renderer.colorPixelFormat
      pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
      pipelineDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultLayout
    
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
        pipelineDescriptor.vertexDescriptor = .defaultLayout
      return createPSO(descriptor: pipelineDescriptor)
    }
    
    static func createShadowPSO() -> MTLRenderPipelineState {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        let vertexFunction = Renderer.library?.makeFunction(name: "vertex_depth")
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .invalid
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        pipelineDescriptor.vertexDescriptor = .defaultLayout
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
