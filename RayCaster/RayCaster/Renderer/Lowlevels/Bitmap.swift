//
//  Bitmap.swift
//  RenderingTutorial
//
//  Copyright (c) 2024 Jeremy All rights reserved.
    

import Foundation

struct Bitmap {
    
    let width: Int
    var pixels: [Color]
    
    var height: Int {
        return pixels.count / width
    }
    
    init(width: Int, height: Int, color: Color) {
        pixels = Array(repeating: color, count: width * height)
        self.width = width
    }
    
    subscript(x: Int, y: Int) -> Color {
        get { return pixels[y * width + x] }
        set {
            guard (0..<width).contains(x),
                    (0..<height).contains(y)
            else {
                return
            }
            pixels[y * width + x] = newValue
        }
    }
    
    mutating func fill(rect: Rect, color: Color) {
        for y in Int(rect.min.y)..<Int(rect.max.y) {
            for x in Int(rect.min.x)..<Int(rect.max.x) {
                self[x, y] = color
            }
        }
    }
    
    mutating func drawLine(from: Vector, to: Vector, color: Color) {
        let difference = to - from
        let stepCount: Int
        let step: Vector
        
        if abs(difference.x) > abs(difference.y) {
            stepCount = Int(abs(difference.x).rounded(.up))
            let sign: Double = difference.x > 0 ? 1 : -1
            step = Vector(x: 1, y: difference.y/difference.x) * sign
        } else {
            stepCount = Int(abs(difference.y).rounded(.up))
            let sign: Double = difference.y > 0 ? 1 : -1
            step = Vector(x: difference.x/difference.y, y: 1) * sign
        }
        var position = from
        
        for _ in 0..<stepCount {
            self[Int(position.x), Int(position.y)] = color
            position += step
        }
    }
}

extension Color {
    
    var val: Int {
        return Int(r) + Int(g) + Int(b) + Int(a)
    }
    
    static func ==(lhs: Color, rhs: Color) -> Bool {
        return lhs.val == rhs.val
    }
}
