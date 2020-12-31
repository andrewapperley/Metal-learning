//
//  Light.swift
//  AppCraft
//
//  Created by Andrew Apperley on 2020-08-03.
//  Copyright © 2020 Andrew Apperley. All rights reserved.
//

import Foundation

extension Light {
    private static func build() -> Light {
        var light = Light()
        light.position = [0, 0, 0]
        light.colour = [1, 1, 1]
        light.specularColour = [0.6, 0.6, 0.6]
        light.intensity = 1
        light.attenuation = float3(1, 0, 0)
        
        return light
    }
    
    static func buildSunlight() -> Light {
        var light = Light.build()
        light.type = Sunlight
        light.intensity = 5
        return light
    }
    
    static func buildSpotlight() -> Light {
        var light = Light.build()
        light.coneAngle = Float(40).degreesToRadians
        light.coneDirection = [-2, 0, -1.5]
        light.coneAttenuation = 12
        light.type = Spotlight
        return light
    }
    
    static func buildPointlight() -> Light {
        var light = Light.build()
        light.attenuation = float3(1, 3, 4)
        light.type = Pointlight
        return light
    }
    
    static func buildAmbientlight() -> Light {
        var light = Light.build()
        light.intensity = 0.4
        light.type = Ambientlight
        return light
    }
}
