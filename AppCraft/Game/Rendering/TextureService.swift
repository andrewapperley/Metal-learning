//
//  TextureService.swift
//  AppCraft
//
//  Created by Andrew Apperley on 2020-11-01.
//  Copyright © 2020 Andrew Apperley. All rights reserved.
//

import MetalKit

enum TextureIndex {
    case BaseColor
    case Normal
    case Specular
}

class TextureService {
    var textures: [String: [MTLTexture?]] = [:]
    let textureLoaderOptions: [MTKTextureLoader.Option: Any] = [.origin: MTKTextureLoader.Origin.topLeft, .SRGB: false]
    
    func loadTextures(name: String) -> [MTLTexture?] {
        guard let textures = textures[name] else {
            do {
                let textureLoaderOptions: [MTKTextureLoader.Option: Any] = [.origin: MTKTextureLoader.Origin.topLeft, .SRGB: false]
                let newTextures = [
                    try? MTKTextureLoader(device: Renderer.device).newTexture(name: name, scaleFactor: 1, bundle: Bundle.main, options: textureLoaderOptions),
                    try? MTKTextureLoader(device: Renderer.device).newTexture(name: "\(name)_n", scaleFactor: 1, bundle: Bundle.main, options: textureLoaderOptions),
                    try? MTKTextureLoader(device: Renderer.device).newTexture(name: "\(name)_s", scaleFactor: 1, bundle: Bundle.main, options: textureLoaderOptions)
                ]
                self.textures[name] = newTextures
                return newTextures
            }
        }
        return textures
    }
}
