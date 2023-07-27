//
//  MovementSystem.swift
//  MM3DM2
//
//  Created by Mohammad Jeragh on 26/07/2023.
//

import Foundation

struct MovementSystem: System {
    
    // A reference to the array of entities in the game world
    var entities: [Entity]
    
    func update() {
        // Loop through each entity in the array
        for var entity in entities {
            // Check if the entity has both a position and a velocity component
            if let position = entity.getComponent(PositionComponent.self),
               let velocity = entity.getComponent(VelocityComponent.self) {
                // Update the position based on the velocity
                position.x += velocity.dx
                position.y += velocity.dy
                
                // Update the entity with the new position component
                entity.addComponent(position)
            }
        }
    }
}
