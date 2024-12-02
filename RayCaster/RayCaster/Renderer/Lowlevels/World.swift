//
//  World.swift
//  RenderingTutorial
//
//  Copyright (c) 2024 Jeremy All rights reserved.


import Foundation

struct World {
    let map: TileMap
    var player: Player
    
    var size: Vector {
        return map.size
    }
    
    init(map: TileMap) {
        self.map = map
        self.player = Player(position: map.firstEmptyPosition())
        self.player.direction = .init(x: 0, y: 1)
        player.position += player.rect.min
    }
}

extension Vector {
    
    func rotate(by radians: Double) -> Vector {
        let rotatedVector = Vector(
            x: x * cos(radians) + y * -sin(radians),
            y: x * sin(radians) + y * cos(radians)
        )
        return rotatedVector
    }
}

extension World {
    mutating func update(_ timestep: Double, _ input: Input) {
        
        player.direction = player.direction.rotate(by: input.velocity.x * player.turningSpeed * timestep)
        
        player.velocity = -input.velocity.y * player.direction * player.speed
        player.position += player.velocity * timestep
        
        // Autorotate
//        player.direction = player.direction.rotate(by: sin(timestep))
        
        while let intersection = player.intersection(with: map) {
            player.position -= intersection
        }
    }
}
