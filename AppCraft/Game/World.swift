//
//  World.swift
//  AppCraft
//
//  Created by Andrew Apperley on 2020-07-31.
//  Copyright © 2020 Andrew Apperley. All rights reserved.
//

import MetalKit

class World {
    weak var inputController: InputController?
    
    let rootNode = Node()
    var renderables: [Renderable] = []
    var uniforms = Uniforms()
    var fragmentUniforms = FragmentUniforms()
    var lights: [Light] = []
    var player: Player = Player()
    private var cameras: [Camera] = [Camera()]
    private var currentCamera: Int = 0
    private var camera: Camera { cameras[currentCamera] }
    
    var cameraPosition: float3 { camera.position }
    var projectionMatrix: float4x4 { camera.projectionMatrix }
    var viewMatrix: float4x4 { camera.viewMatrix }
    
    func rotate(delta: float2) {
        camera.rotate(delta: delta)
    }
    
    var viewSize: CGSize
    init(viewSize: CGSize) {
        self.viewSize = viewSize
        setup()
    }
    
    func setup() {
        cameras.append(FirstPersonCamera())
        currentCamera = 1
        add(node: player)
    }
    
    final func update(delta: Float) {
        updatePlayer(delta: delta)
        uniforms.projectionMatrix = camera.projectionMatrix
        uniforms.viewMatrix = camera.viewMatrix
        fragmentUniforms.cameraPosition = cameraPosition
        
        updateWorld(delta: delta)
        
        update(nodes: rootNode.children, delta: delta)
    }
    
    private func update(nodes: [Node], delta: Float) {
        nodes.forEach { node in
            node.update(delta: delta)
            update(nodes: node.children, delta: delta)
        }
    }
    
    func updateWorld(delta: Float) {
        
    }
    
    private func updatePlayer(delta: Float) {
        inputController?.updatePlayer(delta: delta, player: player, camera: camera)
    }
    
    final func add(node: Node, parent: Node? = nil, render: Bool = true) {
        if let parent = parent {
            parent.add(node: node)
        } else {
            rootNode.add(node: node)
        }
        guard render == true, let renderable = node as? Renderable else { return }
        renderables.append(renderable)
    }
    
    final func remove(node: Node) {
        if let parent = node.parent {
            parent.remove(node: node)
        } else {
            for child in node.children {
                child.parent = nil
            }
            node.children = []
        }
        guard node is Renderable,
              let index = (renderables.firstIndex {
                $0 as? Node === node
              }) else { return }
        renderables.remove(at: index)
    }
    
    func viewSizeWillChange(to size: CGSize) {
        for camera in cameras {
            camera.aspect = Float(size.width / size.height)
        }
        viewSize = size
    }
}
