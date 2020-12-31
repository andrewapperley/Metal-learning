//
//  Node.swift
//  AppCraft
//
//  Created by Andrew Apperley on 2020-07-31.
//  Copyright © 2020 Andrew Apperley. All rights reserved.
//

import MetalKit

class Node {
    var parent: Node? = nil
    var children: [Node] = []
    
    var name: String = ""
    var position: float3 = [0, 0, 0]
    var rotation: float3 = [0, 0, 0]
    var scale: float3 = [1, 1, 1]
    
    var moveSpeed: Float = 4.0
    var rotationSpeed: Float = 1.0
    
    var modelMatrix: float4x4 {
        let translation = float4x4(translation: self.position)
        let rotation = float4x4(rotation: self.rotation)
        let scale = float4x4(scaling: self.scale)
        return translation * rotation * scale
    }
    
    var worldTransform: float4x4 {
        if let parent = parent { return parent.worldTransform * self.modelMatrix }
        return modelMatrix
    }
    
    var forwardVector: float3 {
        return normalize([sin(rotation.y), 0, cos(rotation.y)])
    }
    
    var rightVector: float3 {
        return normalize([forwardVector.z, forwardVector.y, -forwardVector.x])
    }
    
    final func add(node: Node) {
        children.append(node)
        node.parent = self
    }
    
    final func remove(node: Node) {
        for child in node.children {
            child.parent = self
            children.append(child)
        }
        node.children = []
        guard let index = (children.firstIndex {
            $0 === node
        }) else { return }
        children.remove(at: index)
        node.parent = nil
    }
    
    func update(delta: Float) {
        
    }
}
