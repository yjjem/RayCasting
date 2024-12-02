//
//  BitmapRenderer.swift
//  RenderingTutorial
//
//  Copyright (c) 2024 Jeremy All rights reserved.
    

import Foundation

struct Renderer {
    
    // MARK: Property(s)
    
    var bitmap: Bitmap
    
    // MARK: Initializer(s)
    
    init(width: Int, height: Int) {
        self.bitmap = Bitmap(width: width, height: height, color: .white)
    }
    
    // MARK: Function(s)
    
    mutating func draw(_ world: World, focalLength: Double = 1.0, viewWidth: Double = 1.0) {
        
        let scale = Double(bitmap.width) / world.size.y
        
        for y in 0..<world.map.height {
            for x in 0..<world.map.width {
                
                let minVector = Vector(x: Double(x) * scale, y: Double(y) * scale)
                let rect = Rect(min: minVector, max: minVector + Vector(x: scale, y: scale))
                
                if world.map[x, y].isWall {
                    bitmap.fill(rect: rect, color: .white)
                } else {
                    bitmap.fill(rect: rect, color: .black)
                }
            }
        }
        
        let viewCenter = world.player.position + world.player.direction * focalLength
        let viewStart = viewCenter - world.player.direction.orthogonal * viewWidth / 2
        let viewEnd = viewCenter + world.player.direction.orthogonal * viewWidth / 2
        
        var position = viewStart
        let columns = bitmap.width
        let step = world.player.direction.orthogonal * viewWidth / Double(columns)
        
        for _ in 0..<columns {
            let end = position - world.player.position
            let ray = Ray(origin: world.player.position, direction: end / end.length)
            let rayEnd = world.map.hitTest(ray)
            bitmap.drawLine(from: world.player.position * scale, to: rayEnd * scale, color: .green)
            position += step
        }
        
        bitmap.fill(rect: world.player.rect * scale, color: .blue)
        bitmap.drawLine(from: viewStart * scale, to: viewEnd * scale, color: .red)
    }
}
