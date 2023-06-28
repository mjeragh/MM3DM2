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

struct ForwardRenderPass: RenderPass {
  let label = "Forward Render Pass"
  var descriptor: MTLRenderPassDescriptor?

  var pipelineState: MTLRenderPipelineState!
  let depthStencilState: MTLDepthStencilState?
  weak var shadowTexture: MTLTexture?

  init(view: MTKView) {
      pipelineState = PipelineStates.createForwardPSO(colorPixelFormat: view.colorPixelFormat, functionConstants: ForwardRenderPass.makeFunctionConstants())
      depthStencilState = Self.buildDepthStencilState()
  }

  mutating func resize(view: MTKView, size: CGSize) {
  }

  func draw(
    commandBuffer: MTLCommandBuffer,
    scene: GameScene,
    uniforms: Uniforms,
    params: Params
  ) {
    guard let descriptor = descriptor,
    let renderEncoder =
      commandBuffer.makeRenderCommandEncoder(
        descriptor: descriptor) else {
      return
    }
    renderEncoder.label = label
    renderEncoder.setDepthStencilState(depthStencilState)
    renderEncoder.setRenderPipelineState(pipelineState)


    var lights = scene.lighting.lights
    
//      renderEncoder.setFragmentBytes(
//      &lights,
//      length: MemoryLayout<Light>.stride * lights.count,
//      index: LightBuffer.index)

      renderEncoder.setFragmentBuffer(scene.lighting.lightsBuffer, offset: 0, index: LightBuffer.index)
      renderEncoder.setFragmentTexture(shadowTexture, index: ShadowTexture.index)
    
     
      var fragment = params
      renderEncoder.setFragmentBytes(&fragment,
                               length: MemoryLayout<Params>.stride,
                               index: ParamsBuffer.index)
      
      
      for model in scene.models {
      renderEncoder.pushDebugGroup(model.name)
      model.render(
        encoder: renderEncoder,
        uniforms: uniforms,
        params: params)
      renderEncoder.popDebugGroup()
    }
    /* Debugging sun position
    var scene = scene
    DebugModel.debugDrawModel(
      renderEncoder: renderEncoder,
      uniforms: uniforms,
      model: scene.sun,
      color: [0.9, 0.8, 0.2])
    DebugCameraFrustum.draw(
      encoder: renderEncoder,
      scene: scene,
      uniforms: uniforms)
    // End Debugging*/
    renderEncoder.endEncoding()
  }
    
    
     static func makeFunctionConstants()
        -> MTLFunctionConstantValues {
            let functionConstants = MTLFunctionConstantValues()
            var property = false
            functionConstants.setConstantValue(&property, type: .bool, index: 0)
            functionConstants.setConstantValue(&property, type: .bool, index: 1)
            functionConstants.setConstantValue(&property, type: .bool, index: 2)
            
            functionConstants.setConstantValue(&property, type: .bool, index: 3)
            functionConstants.setConstantValue(&property, type: .bool, index: 4)
            functionConstants.setConstantValue(&property, type: .bool, index: 25)
            functionConstants.setConstantValue(&property, type: .bool, index: 26)
            return functionConstants
    }
}
