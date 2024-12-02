//
//  TileMap.swift
//  RenderingTutorial
//
//  Copyright (c) 2024 Jeremy All rights reserved.


struct TileMap {
    
    let tiles: [Tile]
    let width: Int
    
    var height: Int {
        return tiles.count / width
    }
    
    var size: Vector {
        return Vector(x: Double(width), y: Double(height))
    }
    
    subscript(x: Int, y: Int) -> Tile {
        return tiles[y * width + x]
    }
}

// MARK: Function(s)

extension TileMap {
    
    func firstEmptyPosition() -> Vector {
        let firstIndex = tiles.firstIndex(of: .floor) ?? .zero
        return Vector(x: Double(firstIndex % width), y: (Double(firstIndex) / 10).rounded())
    }
    
    func hitTest(_ ray: Ray) -> Vector {
        var position = ray.origin
        let slope = ray.direction.x / ray.direction.y
        
        repeat {
            let edgeDistanceX, edgeDistanceY: Double
            
            if ray.direction.x > 0 {
                edgeDistanceX = position.x.rounded(.down) + 1 - position.x
            } else {
                edgeDistanceX = position.x.rounded(.up) - 1 - position.x
            }
            
            if ray.direction.y > 0 {
                edgeDistanceY = position.y.rounded(.down) + 1 - position.y
            } else {
                edgeDistanceY = position.y.rounded(.up) - 1 - position.y
            }
            
            let step1 = Vector(x: edgeDistanceX, y: edgeDistanceX / slope)
            let step2 = Vector(x: edgeDistanceY * slope, y: edgeDistanceY)
                
            if step1.length < step2.length {
                position += step1
            } else {
                position += step2
            }
        } while !tile(at: position, from: ray.direction).isWall
        
        return position
    }
    
    func tile(at position: Vector, from direction: Vector) -> Tile {
        let x = Int(position.x)
         let y = Int(position.y)
         if position.x.rounded() == position.x {
             return self[direction.x > 0 ? x : x - 1, y]
         } else {
             return self[x, direction.y > 0 ? y : y - 1]
         }
    }
}

// MARK: Default Map

extension TileMap {
    static let defaultMap = TileMap(
        tiles: [
            .wall, .wall, .wall, .wall, .wall, .wall, .wall, .wall,
            .wall, .floor, .wall, .wall, .floor, .floor, .floor, .wall,
            .wall, .floor, .floor, .floor, .floor, .floor, .floor, .wall,
            .wall, .floor, .wall, .wall, .wall, .wall, .floor, .wall,
            .wall, .floor, .wall, .floor, .wall, .floor, .floor, .wall,
            .wall, .floor, .wall, .floor, .wall, .wall, .floor, .wall,
            .wall, .floor, .wall, .floor, .floor, .floor, .floor, .wall,
            .wall, .wall, .wall, .wall, .wall, .wall, .wall, .wall,
        ],
        width: 8
    )
}
