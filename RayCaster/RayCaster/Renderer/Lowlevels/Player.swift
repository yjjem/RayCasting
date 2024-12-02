//
//  Player.swift
//  RenderingTutorial
//
//  Copyright (c) 2024 Jeremy All rights reserved.
    

import Foundation

extension Rect {
    
    static func *(lhs: Rect, rhs: Double) -> Rect {
        return Rect(min: lhs.min * rhs, max: lhs.max * rhs)
    }
}

struct Player {
    
    var rect: Rect {
        let halfSize = Vector(x: radius / 2, y: radius / 2)
        return Rect(min: position - halfSize, max: position + halfSize)
    }
    
    var direction: Vector
    var position: Vector
    var velocity: Vector
    var speed: Double = 2.0
    let radius: Double = 0.25
    let turningSpeed: Double = 2.0
    
    init(position: Vector) {
        self.position = position
        self.velocity = .init(x: 0, y: 0)
        self.direction = Vector(x: 1, y: 0)
    }
    
    func intersection(with map: TileMap) -> Vector? {
        let minX = Int(rect.min.x), maxX = Int(rect.max.x)
        let minY = Int(rect.min.y), maxY = Int(rect.max.y)
        var largestIntersection: Vector?
        for y in minY ... maxY {
            for x in minX ... maxX where map[x, y].isWall {
                let wallRect = Rect(
                    min: Vector(x: Double(x), y: Double(y)),
                    max: Vector(x: Double(x + 1), y: Double(y + 1))
                )
                if let intersection = rect.intersection(with: wallRect),
                    intersection.length > largestIntersection?.length ?? 0 {
                    largestIntersection = intersection
                }
            }
        }
        return largestIntersection
    }
}
