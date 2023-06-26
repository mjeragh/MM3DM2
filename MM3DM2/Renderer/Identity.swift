//
//  Identity.swift
//  MM3DUI
//
//  Created by Mohammad Jeragh on 30/06/2022.
//

import Foundation
import ModelIO

struct ID {
    
    var name  = "untitled"
    var identifier = UUID()
}

protocol Identity {
    var id : ID {get set}
}

extension Identity{
    
    var name : String {
        get {id.name}
        set {id.name = newValue}
    }
    var identifier : UUID {
        get {id.identifier}
    }
}

struct Features {
    var reflection = false
    var interactive = false
    var materials = Material()
    //var boundingBox : MDLAxisAlignedBoundingBox
    var nodeGPU : NodeGPU
}

protocol Properties {
    var features : Features {get set}
}

extension Properties {
    var reflective : Bool {
        get {features.reflection}
        set {features.reflection = newValue}
    }
    var interactive : Bool {
        get {features.interactive}
        set {features.interactive = newValue}
    }
    var materials : Material {
        get {features.materials}
        set {features.materials = newValue}
    }
//    var boundingBox : MDLAxisAlignedBoundingBox {
//        get {features.boundingBox}
//        set {features.boundingBox = newValue}
//    }
    var nodeGPU : NodeGPU {
        get {features.nodeGPU}
        set {features.nodeGPU = newValue}
    }
}
