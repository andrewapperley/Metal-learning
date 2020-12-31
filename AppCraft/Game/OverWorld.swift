//
//  OverWorld.swift
//  AppCraft
//
//  Created by Andrew Apperley on 2020-11-27.
//  Copyright © 2020 Andrew Apperley. All rights reserved.
//

import MetalKit

class OverWorld: World {
    let chunk = Chunk()
    
    override func setup() {
        add(node: chunk)
    }
    
    override func updateWorld(delta: Float) {
        
    }
}
