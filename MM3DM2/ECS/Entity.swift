//
//  Entity.swift
//  MM3DM2
//
//  Created by Mohammad Jeragh on 08/07/2023.
//

import Foundation
struct Entity {
    let id: UUID
    var components : [ComponentType: Component]
    
    mutating func addComponent(_ component: Component, type: ComponentType){
        components[type] = component
    }
    
    mutating func removeComponent(ofType type : ComponentType){
        components[type] = nil
    }
    
    func getComponent(ofType type : ComponentType) -> Component? {
        return components[type]
    }
}
