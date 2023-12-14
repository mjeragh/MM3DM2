//
//  InteractiveComponent.swift
//  MM3DM2
//
//  Created by Mohammad Jeragh on 17/07/2023.
//

import Foundation
struct InteractiveComponent: Component {
    static var componentType  = "Interactive"
    
    var nodeGPU : NodeGPU
    var interactive = true // I think it is redudnat here
}

