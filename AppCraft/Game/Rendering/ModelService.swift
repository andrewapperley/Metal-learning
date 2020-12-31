//
//  ModelService.swift
//  AppCraft
//
//  Created by Andrew Apperley on 2020-11-01.
//  Copyright © 2020 Andrew Apperley. All rights reserved.
//

import MetalKit

class ModelService {
    var models: [String: MDLAsset] = [:]
    
    func loadModel(name: String) -> MDLAsset {
        guard let model = models[name] else {
            let url = Bundle.main.url(forResource: name, withExtension: "obj")!
            let allocator = MTKMeshBufferAllocator(device: Renderer.device)
            
            let model = MDLAsset(
                url: url,
                vertexDescriptor: MDLVertexDescriptor.default,
                bufferAllocator: allocator
            )
            models[name] = model
            return model
        }
        
        return model
    }
}
