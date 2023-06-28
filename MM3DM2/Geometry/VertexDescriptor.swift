//
//  VertexDescriptor.swift
//  MM3DUI
//
//  Created by Mohammad Jeragh on 12/06/2022.
//

import MetalKit

extension MTLVertexDescriptor {
  static var defaultLayout: MTLVertexDescriptor? {
    MTKMetalVertexDescriptorFromModelIO(.defaultLayout)
  }
}

extension MDLVertexDescriptor {
    
    static var defaultLayout: MDLVertexDescriptor = {
      let vertexDescriptor = MDLVertexDescriptor()

        var offset = 0
        // position attribute
        vertexDescriptor.attributes[Position.index]
          = MDLVertexAttribute(name: MDLVertexAttributePosition,
                               format: .float3,
                               offset: 0,
                               bufferIndex: VertexBuffer.index)
        offset += MemoryLayout<float3>.stride
        
        // normal attribute
        vertexDescriptor.attributes[Normal.index] =
          MDLVertexAttribute(name: MDLVertexAttributeNormal,
                             format: .float3,
                             offset: offset,
                             bufferIndex: VertexBuffer.index)
        offset += MemoryLayout<float3>.stride
        
        // add the uv attribute here
        vertexDescriptor.attributes[UV.index] =
          MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate,
                             format: .float2,
                             offset: offset,
                             bufferIndex: VertexBuffer.index)
        offset += MemoryLayout<float2>.stride
        
        vertexDescriptor.attributes[Tangent.index] =
          MDLVertexAttribute(name: MDLVertexAttributeTangent,
                             format: .float3,
                             offset: 0,
                             bufferIndex: 1)
        
        vertexDescriptor.attributes[Bitangent.index] =
          MDLVertexAttribute(name: MDLVertexAttributeBitangent,
                             format: .float3,
                             offset: 0,
                             bufferIndex: 2)
        
        // color attribute
        vertexDescriptor.attributes[Color.index] =
          MDLVertexAttribute(name: MDLVertexAttributeColor,
                             format: .float3,
                             offset: offset,
                             bufferIndex: VertexBuffer.index)
        
        offset += MemoryLayout<float3>.stride
        
        // joints attribute
        vertexDescriptor.attributes[Joints.index] =
          MDLVertexAttribute(name: MDLVertexAttributeJointIndices,
                             format: .uShort4,
                             offset: offset,
                             bufferIndex: VertexBuffer.index)
        offset += MemoryLayout<ushort>.stride * 4
        
        vertexDescriptor.attributes[Weights.index] =
          MDLVertexAttribute(name: MDLVertexAttributeJointWeights,
                             format: .float4,
                             offset: offset,
                             bufferIndex: VertexBuffer.index)
        offset += MemoryLayout<float4>.stride
         

        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: offset)
        //these two layout are for the bittangent
        vertexDescriptor.layouts[1] =
          MDLVertexBufferLayout(stride: MemoryLayout<float3>.stride)
        vertexDescriptor.layouts[2] =
          MDLVertexBufferLayout(stride: MemoryLayout<float3>.stride)
        return vertexDescriptor
    }()
}

extension BufferIndices {
    var index : Int {
        return Int(self.rawValue)
    }
}

extension Attributes {
    var index : Int {
        return Int(self.rawValue)
    }
}

extension Gradient {
    var index : Int {
        return Int(self.rawValue)
    }
}

extension TexturesIndices {
    var index : Int {
        return Int(self.rawValue)
    }
}
    
extension RenderTargetIndecies {
        var index: Int {
            return Int(self.rawValue)
        }
}

