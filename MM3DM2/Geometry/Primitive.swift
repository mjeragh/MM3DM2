/**
 * Copyright (c) 2018 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import MetalKit

enum Shapes {
    case cube
    case sphere
    case plane
    case icosahedron
}

class Primitive : Renderable, Properties {
    var features: Features
    var id: ID
    var transform: Transform
    
    let vertexBuffer: MTLBuffer
    let mesh: MTKMesh
    let instanceCount: Int
//    let pipelineState: MTLRenderPipelineState
    //let debugBoundingBox: DebugBoundingBox
    let vertexDescriptor : MDLVertexDescriptor
    init(name: String = "untitled", shape: Shapes, size: Float, reflective: Bool = false, interactive: Bool = false,
         textureSize: CGSize = CGSize(width: 0, height: 0), instanceCount: Int = 1) {
        let allocator = MTKMeshBufferAllocator(device: Renderer.device)
        let mdlMesh : MDLMesh!
        self.instanceCount = instanceCount
        switch shape {
            case .cube:
                mdlMesh = MDLMesh(boxWithExtent: [size, size, size],
                              segments: [1, 1, 1],
                              inwardNormals: false, geometryType: .triangles,
                              allocator: allocator)
            case .sphere:
                mdlMesh = MDLMesh(sphereWithExtent: [size, size, size], segments: [100,100], inwardNormals: false, geometryType: .triangles, allocator: allocator)
            case .plane:
                mdlMesh = MDLMesh.newPlane(withDimensions: [size, size], segments: [1,1], geometryType: .triangles, allocator: allocator)
            case .icosahedron:
                mdlMesh = MDLMesh.newIcosahedron(withRadius: size, inwardNormals: false, geometryType: .triangles, allocator: allocator)
        }
        
                // add tangent and bitangent here
        mdlMesh.addTangentBasis(forTextureCoordinateAttributeNamed:
                                    MDLVertexAttributeTextureCoordinate,
                                    tangentAttributeNamed: MDLVertexAttributeTangent,
                                    bitangentAttributeNamed: MDLVertexAttributeBitangent)
        
        self.mesh = try! MTKMesh(mesh: mdlMesh, device: Renderer.device)

        self.vertexBuffer = self.mesh.vertexBuffers[0].buffer
   
       // debugBoundingBox = DebugBoundingBox(boundingBox: mdlMesh.boundingBox)
        self.vertexDescriptor = mdlMesh.vertexDescriptor
//        pipelineState =  PipelineStates.createForwardPSO(colorPixelFormat: <#MTLPixelFormat#>, functionConstants: ForwardRenderPass.makeFunctionConstants())
        
        id = ID(name: name)
        transform = Transform()
        let boundingBox = BoundingBox(minBounds: mdlMesh.boundingBox.minBounds, maxBounds: mdlMesh.boundingBox.maxBounds)
        let nodeGPU = NodeGPU(localRay: LocalRay(localOrigin: float3(), localDirection: float3()), boundingBox: boundingBox, parameter: 0.0, modelMatrix: transform.modelMatrix, debug: 0)
        features = Features(reflection: reflective, interactive: interactive, nodeGPU: nodeGPU)//, materials: Material())
        features.materials.metallic = 0.1
        features.materials.roughness = 0.9
        features.materials.ambientOcclusion = 0.9
    }
    
    
    
}
extension Primitive {
    
    func update(deltaTime: Float) {
        
    }

    
    func render(encoder: MTLRenderCommandEncoder, uniforms vertex: Uniforms, params fragment: Params) {
        var uniforms = vertex
        uniforms.modelMatrix = transform.modelMatrix
        uniforms.normalMatrix = transform.modelMatrix.upperLeft
        
        //renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        // render multiple buffers
        // replace the following two lines
        // this only sends the MTLBuffer containing position, normal and UV
        //July 14, 22 I think it adds the tangent and bittangnet. from the debugger I saw it
        for (index, vertexBuffer) in mesh.vertexBuffers.enumerated() {
          encoder.setVertexBuffer(vertexBuffer.buffer,
                                        offset: 0, index: index)
        }
        encoder.setVertexBytes(&uniforms,
                               length: MemoryLayout<Uniforms>.stride,
                               index: UniformsBuffer.index)
//
//
//
//
//        var params = fragment
//        encoder.setFragmentBytes(&params,
//                                 length: MemoryLayout<Params>.stride,
//                                 index: ParamsBuffer.index)
        
        encoder.setFragmentBytes(&features.materials,
                                       length: MemoryLayout<Material>.stride,
                                       index: MaterialBuffer.index)

        
       // encoder.setRenderPipelineState(pipelineState)
        for submesh in mesh.submeshes{
            encoder.drawIndexedPrimitives(type: .triangle, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset, instanceCount: instanceCount)
        }
//        if debugRenderBoundingBox {
//          debugBoundingBox.render(renderEncoder: renderEncoder, uniforms: uniforms)
//        }
    }
    
}




