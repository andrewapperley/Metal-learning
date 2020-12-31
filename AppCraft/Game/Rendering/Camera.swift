//
//  Camera.swift
//  AppCraft
//
//  Created by Andrew Apperley on 2020-07-31.
//  Copyright © 2020 Andrew Apperley. All rights reserved.
//

import MetalKit

class Camera: Node {
    var fov: Float = 70
    var fovRadians: Float { fov.degreesToRadians }
    var far: Float = 100
    var near: Float = 0.1
    var aspect: Float = 1
    
    var projectionMatrix: float4x4 {
        return float4x4(
            projectionFov: fovRadians,
            near: near,
            far: far,
            aspect: aspect
        )
    }
    
    var viewMatrix: float4x4 {
        let translateMatrix = float4x4(translation: position)
        let rotateMatrix = float4x4(rotation: rotation)
        let scaleMatrix = float4x4(scaling: scale)
        return (translateMatrix * scaleMatrix * rotateMatrix).inverse
    }
    
    func updateViewMatrix() {}
    func zoom(delta: Float) {}
    func rotate(delta: float2) {}
}

class FirstPersonCamera: Camera {
    
    var minDistance: Float = 0.5
    var maxDistance: Float = 10
    var target: float3 = [0, 0, 0] {
        didSet {
            updateViewMatrix()
        }
    }
    
    var distance: Float = 0 {
        didSet {
            updateViewMatrix()
        }
    }
    
    override var rotation: float3 {
        didSet {
            updateViewMatrix()
        }
    }
    
    override var viewMatrix: float4x4 {
        return _viewMatrix
    }
    private var _viewMatrix = float4x4.identity()
    
    override init() {
        super.init()
        updateViewMatrix()
    }
    
    override func updateViewMatrix() {
        let translateMatrix = float4x4(translation: [target.x, target.y, target.z - distance])
        let rotateMatrix = float4x4(rotationYXZ: [-rotation.x,
                                                  rotation.y,
                                                  0])
        let matrix = (rotateMatrix * translateMatrix).inverse
        position = rotateMatrix.upperLeft * -matrix.columns.3.xyz
        _viewMatrix = matrix
    }
    
    override func rotate(delta: float2) {
        let sensitivity: Float = 0.5
        var r = rotation
        r.y += delta.x * sensitivity
        r.x += delta.y * sensitivity
        r.x = max(-Float.pi/2,
                  min(r.x,
                      Float.pi/2))
        rotation = r
        updateViewMatrix()  
    }
}

class ThirdPersonCamera: Camera {
    var focus: Node
    var focusDistance: Float = 3
    var focusHeight: Float = 1.2
    
    override var viewMatrix: float4x4 {
        position = focus.position - focusDistance * focus.forwardVector
        position.y = focusHeight
        rotation.y = focus.rotation.y
        return super.viewMatrix
    }
    
    override func rotate(delta: float2) {
        let sensitivity: Float = 0.5
        var r = rotation
        r.y += delta.x * sensitivity
        r.x += delta.y * sensitivity
        r.x = max(-Float.pi/2,
                  min(r.x,
                      Float.pi/2))
        rotation = r
    }
    
    init(focus: Node) {
        self.focus = focus
        super.init()
    }
}
