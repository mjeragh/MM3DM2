//
//  GameEntity.swift
//  MM3DM2
//
//  Created by Mohammad Jeragh on 09/12/2023.
//

import Foundation

struct ID {
    
    var name  = "untitled"
    var identifier = UUID()
}


class GameEntity: Entity {
    func updateComponent<T>(_ componentType: T.Type, update: (inout T) -> Void) where T : Component {
        if var component = getComponent(componentType) {
            update(&component)
            
            if T.self is AnyClass {
                // If component is a class, it's already updated.
            } else {
                // If component is a struct, replace the old component.
                addComponent(component)
            }
        }
    }
    
    var entityID: ID
    var components: [String: Component] = [:]

    init(name: String, id: UUID = UUID()) {
        entityID = ID()
        self.entityID.name = name
        self.entityID.identifier = id
    }

    func addComponent(_ component: Component) {
        components[String(describing: type(of: component))] = component
    }

    func removeComponent(_ componentType: String) {
        components.removeValue(forKey: componentType)
    }

    func getComponent<T: Component>(_ componentType: T.Type) -> T? {
        let typeName = String(describing: componentType)
        return components[typeName] as? T
    }
    
}
