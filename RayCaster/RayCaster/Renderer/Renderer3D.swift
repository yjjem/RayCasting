//
//  Renderer3D.swift
//  RenderingTutorial
//
//  Copyright (c) 2024 Jeremy All rights reserved.


import Foundation

final class Renderer3D  {
    
    // MARK: Property(s)
    
    var bitmap: Bitmap
    let width: Int
    let height: Int
    
    // MARK: Initializer(s)
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        self.bitmap = Bitmap(width: width, height: height, color: .black)
    }
    
    // MARK: Function(s)
    
    func draw(_ world: World, focalLength: Double = 1, viewWidth: Double = 1) {
        self.bitmap = Bitmap(width: width, height: height, color: Color.black)
        let viewCenter = world.player.position + world.player.direction * focalLength
        let viewStart = viewCenter - world.player.direction.orthogonal * viewWidth / 2
        
        var position = viewStart
        let columns = bitmap.width
        let step = world.player.direction.orthogonal * viewWidth / Double(columns)
        
        for column in 0..<columns {
            let end = position - world.player.position
            let ray = Ray(origin: world.player.position, direction: end / end.length)
            
            let wallIntersection = world.map.hitTest(ray)
            position += step
            let wallHeight = 1.0
            let wallDistance = wallIntersection - world.player.position
            let height = focalLength * wallHeight / wallDistance.length * Double(bitmap.height)
            
            let wallStart = Vector(x: Double(column), y: Double(bitmap.height) / 2 - height / 2)
            let wallEnd = Vector(x: Double(column), y: Double(bitmap.height) / 2 + height / 2)
            
            let wallColor: Color
            
            if wallIntersection.x.rounded(.down) == wallIntersection.x {
                wallColor = .gray
            } else {
                wallColor = .white
            }
            
            bitmap.drawLine(from: wallStart, to: wallEnd, color: wallColor)
        }
    }
}
