//
//  GameController.swift
//  AppCraft
//
//  Created by Andrew Apperley on 2020-07-12.
//  Copyright © 2020 Andrew Apperley. All rights reserved.
//

import MetalKit
import AppKit

class GameController: NSViewController {
    
    private enum Constants {
        static let defaultScreenSize = CGRect(x: 0, y: 0, width: 800, height: 600)
    }
    
    private var renderer: Renderer!
    var mtkview: MTKView { self.view as! MTKView }
    let inputController = InputController()
    
    override func loadView() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (event) -> NSEvent? in
            self.keyDown(with: event)
            return nil
        }
        self.view = MTKView(frame: NSScreen.main?.frame ?? Constants.defaultScreenSize)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mtkview.addTrackingArea(
            NSTrackingArea(
                rect: mtkview.bounds,
                options: [
                    .activeInActiveApp,
                    .mouseEnteredAndExited,
                    .mouseMoved
                ],
                owner: self,
                userInfo: nil)
        )
        mtkview.colorPixelFormat = .bgra8Unorm
        mtkview.clearColor = MTLClearColorMake(0.5, 0.5, 0.5, 1)
        mtkview.depthStencilPixelFormat = .depth32Float
        renderer = Renderer(metalView: self.mtkview)
        let world = OverWorld(viewSize: self.mtkview.bounds.size)
        world.inputController = self.inputController
        renderer?.world = world
    }
    
    override func mouseEntered(with event: NSEvent) {
        NSCursor.hide()
    }
    
    override func mouseExited(with event: NSEvent) {
        NSCursor.unhide()
    }
    
    override func mouseMoved(with event: NSEvent) {
        let screenFrame = NSScreen.main?.frame ?? .zero
        var rect = view.frame
        view.frame = view.convert(rect, to: nil)
        rect = view.window?.convertToScreen(rect) ?? rect
        CGWarpMouseCursorPosition(NSPoint(x: (rect.origin.x + view.bounds.midX),
                                          y: (screenFrame.height - rect.origin.y - view.bounds.midY) ))
        self.inputController.rotate(event: event)
    }
    
    override func keyDown(with event: NSEvent) {
        self.inputController.move(event: event)
    }
    
    override func scrollWheel(with event: NSEvent) {
        self.inputController.handleScrollWheel(event: event)
    }
}

class InputController {
    private var keysCurrentlyPressed: [KeyboardButtons] = []
    private var currentRotation: float2 = float2()
    
    private enum KeyboardButtons: Int {
        case Up = 126
        case Down = 123
        case Left = 125
        case Right = 124
        case W = 13
        case A = 0
        case S = 1
        case D = 2
        case Space = 49
        case Enter = 36
        case Escape = 53
        case Unknown = -1
    }
    
    private enum MouseButtons {
        case Left
        case Right
        case Middle
    }
    
    fileprivate func move(event: NSEvent) {
        keysCurrentlyPressed.append(KeyboardButtons(rawValue: Int(event.keyCode)) ?? .Unknown)
    }
    
    fileprivate func rotate(event: NSEvent) {
        let delta = float2(
            Float(event.deltaX),
            Float(event.deltaY)
        )
        currentRotation = delta
    }
    
    fileprivate func handleScrollWheel(event: NSEvent) {
        
    }
    
    public func updatePlayer(delta: Float, player: Player, camera: Camera) {
        let moveSpeed = delta * player.moveSpeed
        let rotateSpeed = delta * player.rotationSpeed
        var direction: float3 = [0, 0, 0]
        
        // handle move
        for key in keysCurrentlyPressed {
            switch key {
                case .Up: break
                case .Down: break
                case .Left: break
                case .Right: break
            case .W: direction.z += 1
            case .A: direction.x -= 1
            case .S: direction.z -= 1
            case .D: direction.x += 1
                case .Space: break
                case .Enter: break
                case .Escape: break
                case .Unknown: break
            }
        }
        if direction != [0, 0, 0] {
            direction = normalize(direction)
            player.position +=
                (direction.z * player.forwardVector
                        + direction.x * player.rightVector) * moveSpeed
        }
        keysCurrentlyPressed = []
        
        // handle rotation
        camera.rotate(delta: float2(-currentRotation.x * rotateSpeed, currentRotation.y * rotateSpeed))
        currentRotation = float2()
    }
}
