//
//  ParentCompanent.swift
//  MM3DM2
//
//  Created by Mohammad Jeragh on 09/07/2023.
//

import Foundation
struct ParentComponent: Component {
    static var componentType  = "Parent"
    
    var parent: Entity
}

struct ChildrenComponent: Component {
    static var componentType  = "Children"
    
    
    var children: [Entity]
}

