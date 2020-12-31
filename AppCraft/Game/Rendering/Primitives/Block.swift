//
//  Block.swift
//  AppCraft
//
//  Created by Andrew Apperley on 2020-07-19.
//  Copyright © 2020 Andrew Apperley. All rights reserved.
//

import MetalKit

enum BlockType: String {
    case Air
    case Oak_Log
    case Glowstone
    case Dirt
}

class Block: Node, Renderable {
    let mesh: MTKMesh
    let pipelineState: MTLRenderPipelineState
    var textures: [MTLTexture?] = [nil, nil, nil] // Based on amount of textures in Textures struct
    static var vertexDescriptor: MDLVertexDescriptor = MDLVertexDescriptor.default
    
    init?(type: BlockType) {
        
        guard let library = Renderer.device.makeDefaultLibrary() else { return nil }
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        let asset = Renderer.modelService.loadModel(name: "block")
        let mdlMesh = asset.childObjects(of: MDLMesh.self).first as! MDLMesh
        mdlMesh.addTangentBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate,
                  tangentAttributeNamed: MDLVertexAttributeTangent,
                  bitangentAttributeNamed: MDLVertexAttributeBitangent)
        Block.vertexDescriptor = mdlMesh.vertexDescriptor
        guard let mesh = try? MTKMesh(mesh: mdlMesh, device: Renderer.device) else { return nil }
        self.mesh = mesh
        
        self.textures = Renderer.textureService.loadTextures(name: type.rawValue)
        
        let vertexFunction = library.makeFunction(name: "vertex_main")
        do {
            let fragmentFunction = try? library.makeFunction(name: "fragment_main", constantValues: Block.buildFragmentFunctionConstants(for: textures))
            pipelineDescriptor.fragmentFunction = fragmentFunction
        }
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(Block.vertexDescriptor)
        
        guard let pipelineState = try? Renderer.device.makeRenderPipelineState(descriptor: pipelineDescriptor) else { return nil }
        self.pipelineState = pipelineState
        
        super.init()
    }
    
    private static func buildFragmentFunctionConstants(for textures: [MTLTexture?]) -> MTLFunctionConstantValues {
        let constants = MTLFunctionConstantValues()
        // Check for Base Colour Texture
        var property = textures[Int(BaseColourTexture.rawValue)] != nil
        constants.setConstantValue(&property, type: .bool, index: Int(BaseColourTexture.rawValue))
        // Check for Normal Texture
        property = textures[Int(NormalTexture.rawValue)] != nil
        constants.setConstantValue(&property, type: .bool, index: Int(NormalTexture.rawValue))
        // Check for Specular Texture
        property = textures[Int(SpecularTexture.rawValue)] != nil
        constants.setConstantValue(&property, type: .bool, index: Int(SpecularTexture.rawValue))
        
        return constants
    }
    
    private static func buildSamplerState() -> MTLSamplerState? {
        let descriptor = MTLSamplerDescriptor()
        descriptor.sAddressMode = .repeat
        descriptor.tAddressMode = .repeat
        descriptor.mipFilter = .linear
        descriptor.maxAnisotropy = 8
        let samplerState =
            Renderer.device.makeSamplerState(descriptor: descriptor)
        return samplerState
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder, uniforms: Uniforms, fragment: FragmentUniforms) {
        
        var vertex = uniforms
        var fragment = fragment
        
        let currentLocalTransform: float4x4 = .identity()
        vertex.modelMatrix = worldTransform * currentLocalTransform
        vertex.normalMatrix = uniforms.modelMatrix.upperLeft
        
        renderEncoder.setRenderPipelineState(pipelineState)
        for (index, vertexBuffer) in mesh.vertexBuffers.enumerated() {
            renderEncoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, index: index)
        }
        renderEncoder.setVertexBytes(&vertex,
        length: MemoryLayout<Uniforms>.stride,
        index: Int(BufferIndexUniforms.rawValue))
        
        let baseColour = textures[Int(BaseColourTexture.rawValue)]
        renderEncoder.setFragmentTexture(baseColour, index: Int(BaseColourTexture.rawValue))
//        let normal = textures[Int(NormalTexture.rawValue)]
//        renderEncoder.setFragmentTexture(normal, index: Int(NormalTexture.rawValue))
//        let specular = textures[Int(SpecularTexture.rawValue)]
//        renderEncoder.setFragmentTexture(specular, index: Int(SpecularTexture.rawValue))
        renderEncoder.setFragmentSamplerState(Block.buildSamplerState(), index: 0)
        
        mesh.submeshes.forEach {
            renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: $0.indexCount, indexType: $0.indexType, indexBuffer: $0.indexBuffer.buffer, indexBufferOffset: $0.indexBuffer.offset)
        }
    }
}
