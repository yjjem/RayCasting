//
//  Ray.swift
//  RenderingTutorial
//
//  Copyright (c) 2024 Jeremy All rights reserved.
    

import Foundation

struct Ray {
    
    let origin: Vector
    let direction: Vector
    
    init(origin: Vector, direction: Vector) {
        self.origin = origin
        self.direction = direction
    }
}
