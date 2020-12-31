//
//  Chunk.swift
//  AppCraft
//
//  Created by Andrew Apperley on 2020-10-29.
//  Copyright © 2020 Andrew Apperley. All rights reserved.
//

import MetalKit

class Chunk: Node, Renderable {
    var blocks: [Block] { children as! [Block] }
    
    override init() {
        super.init()
        generateChunk()
    }
    
    func generateChunk() {
        let block1 = Block(type: .Dirt)!
        block1.position = [
            (Float(4) + self.position.x),
            (Float(0) + self.position.y),
            (Float(4) + self.position.z)
        ]
        add(node: block1)
        
        let block2 = Block(type: .Dirt)!
        block2.position = [
            (Float(1) + self.position.x),
            (Float(0) + self.position.y),
            (Float(1) + self.position.z)
        ]
        add(node: block2)
//        for y in 0...1 {
//            for x in 0...1 {
//                for z in 0...1 {
//                    let block = Block(type: .Dirt)!
//                    block.position = [
//                        (Float(x) + self.position.x),
//                        (Float(y) + self.position.y),
//                        (Float(z) + self.position.z)
//                    ]
//                    blocks.append(block)
//                    add(node: block)
//                }
//            }
//        }
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder, uniforms: Uniforms, fragment: FragmentUniforms) {
        for block in self.blocks {
            block.render(renderEncoder: renderEncoder, uniforms: uniforms, fragment: fragment)
        }
    }
}
