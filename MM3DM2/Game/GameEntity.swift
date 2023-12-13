//
//  GameEntity.swift
//  MM3DM2
//
//  Created by Mohammad Jeragh on 09/12/2023.
//

import Foundation

class GameEntity: Entity {
    var entityID: UUID
    var components: [String: Component] = [:]

    init(id: UUID = UUID()) {
        self.entityID = id
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
