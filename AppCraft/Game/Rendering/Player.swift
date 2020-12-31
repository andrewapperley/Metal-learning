//
//  Player.swift
//  AppCraft
//
//  Created by Andrew Apperley on 2020-10-30.
//  Copyright © 2020 Andrew Apperley. All rights reserved.
//

import MetalKit

class Player: Node, Renderable {
    var jumpLocked = false
    func jump() {
        guard !jumpLocked else { return }
    }
    
    override func update(delta: Float) {
        super.update(delta: delta)
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder, uniforms: Uniforms, fragment: FragmentUniforms) {
        
    }
}
