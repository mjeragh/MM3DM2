//
//  Entity.swift
//  MM3DM2
//
//  Created by Mohammad Jeragh on 08/07/2023.
//

import Foundation
// A protocol that defines the common interface for all entities
protocol Entity {
    // A unique identifier for each entity instance
    var entityID: Int { get }
    // A dictionary that stores the components attached to this entity
    var components: [String: Component] { get set }
    // A method that adds a component to this entity
    mutating func addComponent(_ component: Component)
    // A method that removes a component from this entity
    mutating func removeComponent(_ componentType: String)
    // A method that returns a component of a given type from this entity
    func getComponent<T: Component>(_ componentType: T.Type) -> T?
}
