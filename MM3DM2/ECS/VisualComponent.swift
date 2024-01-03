//
//  VisualComponent.swift
//  MM3DM2
//
//  Created by Mohammad Jeragh on 09/07/2023.
//

import Foundation

struct VisualComponent: Component {
    static var componentType  = "Visual"
    
    var material: Material
    var textures: TextureController
    var reflectivity: Float
    //transperancy I will deal with it later
}
