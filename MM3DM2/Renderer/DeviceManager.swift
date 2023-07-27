//
//  DeviceManager.swift
//  MM3DM2
//
//  Created by Mohammad Jeragh on 27/07/2023.
//

import Foundation
import Metal

class DeviceManager{
    private static var sharedInstance: DeviceManager?
        
        var device: MTLDevice!
        var commandQueue: MTLCommandQueue!
        var library : MTLLibrary!
        
        private init() {
            guard
                let device = MTLCreateSystemDefaultDevice(),
                let commandQueue = device.makeCommandQueue() else {
                    return
            }
            self.device = device
            self.commandQueue = commandQueue
            self.library = device.makeDefaultLibrary()
        }
        
        static func shared() throws -> DeviceManager {
            if let instance = sharedInstance {
                return instance
            }
            
            guard let instance = DeviceManager() else {
                throw NSError(domain: "DeviceManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "GPU not available"])
            }
            
            sharedInstance = instance
            return instance
        }
    }
