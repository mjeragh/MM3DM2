//
//  SizeAwareSystem.swift
//  MM3DM2
//
//  Created by Mohammad Jeragh on 01/02/2024.
//

import Foundation

protocol SizeAwareSystem : System {
    func update(size: CGSize, for scene: GameScene)
}
