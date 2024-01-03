////
////  Children.swift
////  MM3DUI
////
////  Created by Mohammad Jeragh on 30/06/2022.
////
//
//import Foundation
//
//class Storage { //I will work it out later
//    weak var parent: Node?
//    var children: [Node] = []
//}
//
//protocol Node : AnyObject {
//    var parent: Node? {get set}//must be declared weak
//    var children: [Node]{get set}// =[]
//    func add(childNode: Node);
//    func remove(childNode: Node);
//    func removeFromParent();
//    var worldTransform: float4x4 {get}
//    
//}
//
//extension Node where Self : Transformable {
//    func add(childNode: Node) {
//      children.append(childNode)
//      childNode.parent = self
//    }
//    
//    func remove(childNode: Node)
//     {
//      for child in childNode.children {
//        child.parent = self
//        children.append(child)
//      }
//      childNode.children = []
//      guard let index = (children.firstIndex {
//        $0 === childNode
//      }) else { return }
//      children.remove(at: index)
//      childNode.parent = nil
//    }
//    
//    func removeFromParent() {
//        parent?.remove(childNode: self)
//    }
//    
//    var worldTransform: float4x4 {
//        if let parent = parent {
//            return parent.worldTransform * self.transform.modelMatrix
//      }
//        return transform.modelMatrix
//    }
//}
