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

      // Position and Normal
      var offset = 0
      vertexDescriptor.attributes[Position.index]
        = MDLVertexAttribute(
          name: MDLVertexAttributePosition,
          format: .float3,
          offset: 0,
          bufferIndex: VertexBuffer.index)
      offset += MemoryLayout<float3>.stride
      vertexDescriptor.attributes[Normal.index] =
        MDLVertexAttribute(
          name: MDLVertexAttributeNormal,
          format: .float3,
          offset: offset,
          bufferIndex: VertexBuffer.index)
      offset += MemoryLayout<float3>.stride
      vertexDescriptor.layouts[VertexBuffer.index]
        = MDLVertexBufferLayout(stride: offset)

      // UVs
      vertexDescriptor.attributes[UV.index] =
        MDLVertexAttribute(
          name: MDLVertexAttributeTextureCoordinate,
          format: .float2,
          offset: 0,
          bufferIndex: UVBuffer.index)
      vertexDescriptor.layouts[UVBuffer.index]
        = MDLVertexBufferLayout(stride: MemoryLayout<float2>.stride)

      // Vertex Color
      vertexDescriptor.attributes[Color.index] =
        MDLVertexAttribute(
          name: MDLVertexAttributeColor,
          format: .float3,
          offset: 0,
          bufferIndex: ColorBuffer.index)
      vertexDescriptor.layouts[ColorBuffer.index]
        = MDLVertexBufferLayout(stride: MemoryLayout<float3>.stride)

      vertexDescriptor.attributes[Tangent.index] =
        MDLVertexAttribute(
          name: MDLVertexAttributeTangent,
          format: .float3,
          offset: 0,
          bufferIndex: TangentBuffer.index)
      vertexDescriptor.layouts[TangentBuffer.index]
        = MDLVertexBufferLayout(stride: MemoryLayout<float3>.stride)
      vertexDescriptor.attributes[Bitangent.index] =
        MDLVertexAttribute(
          name: MDLVertexAttributeBitangent,
          format: .float3,
          offset: 0,
          bufferIndex: BitangentBuffer.index)
      vertexDescriptor.layouts[BitangentBuffer.index]
        = MDLVertexBufferLayout(stride: MemoryLayout<float3>.stride)
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

