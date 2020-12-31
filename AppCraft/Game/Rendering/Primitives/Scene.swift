//
//  Scene.swift
//  AppCraft
//
//  Created by Andrew Apperley on 2020-07-31.
//  Copyright © 2020 Andrew Apperley. All rights reserved.
//

import MetalKit

class World {
    var rootNode = Node()
    var nodes: [Node] = []
    var renderables: [Renderable] = []
    let camera: FirstPersonCamera = FirstPersonCamera()
}
