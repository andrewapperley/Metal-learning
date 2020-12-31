//
//  Renderer.swift
//  AppCraft
//
//  Created by Andrew Apperley on 2020-07-12.
//  Copyright © 2020 Andrew Apperley. All rights reserved.
//

import MetalKit

class Renderer: NSObject {
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!
    static let textureService = TextureService()
    static let modelService = ModelService()
    static var colorPixelFormat: MTLPixelFormat!
    static var fps: Int!
    
    let depthStencilState: MTLDepthStencilState
    var world: World? = nil
    
    init(metalView: MTKView) {
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue() else {
                fatalError("GPU not available")
        }
        Renderer.device = device
        Renderer.commandQueue = commandQueue
        Renderer.library = device.makeDefaultLibrary()
        Renderer.colorPixelFormat = metalView.colorPixelFormat
        Renderer.fps = metalView.preferredFramesPerSecond
        
        depthStencilState = Renderer.buildDepthStencilState()!
        super.init()
        metalView.device = device
        metalView.delegate = self
        
        mtkView(metalView, drawableSizeWillChange: metalView.bounds.size)
    }
    
    static func buildDepthStencilState() -> MTLDepthStencilState? {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        return
            Renderer.device.makeDepthStencilState(descriptor: descriptor)
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        world?.viewSizeWillChange(to: size)
    }
    
    func draw(in view: MTKView) {
        guard
            let world = world,
            let descriptor = view.currentRenderPassDescriptor,
            let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
            let renderEncoder =
            commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
                return
        }
        let delta = 1 / Float(Renderer.fps)
        world.update(delta: delta)
        
        renderEncoder.setDepthStencilState(depthStencilState)
        renderEncoder.setFragmentBytes(&world.lights, length: MemoryLayout<Light>.stride * world.lights.count, index: Int(BufferIndexLights.rawValue))
        
        for renderable in world.renderables {
            renderable.render(
                renderEncoder: renderEncoder,
                uniforms: world.uniforms,
                fragment: world.fragmentUniforms
            )
        }
        
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
