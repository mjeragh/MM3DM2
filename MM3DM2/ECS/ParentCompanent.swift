//
//  ParentCompanent.swift
//  MM3DM2
//
//  Created by Mohammad Jeragh on 09/07/2023.
//

import Foundation
struct ParentComponent: Component {
    var parent: Entity
}

struct ChildrenComponent: Component {
    var children: [Entity]
}

