//
//  Renderable.swift
//  AppCraft
//
//  Created by Andrew Apperley on 2020-07-29.
//  Copyright © 2020 Andrew Apperley. All rights reserved.
//

import MetalKit

protocol Renderable {
    func render(renderEncoder: MTLRenderCommandEncoder, uniforms: Uniforms,
                fragment: FragmentUniforms)
}
