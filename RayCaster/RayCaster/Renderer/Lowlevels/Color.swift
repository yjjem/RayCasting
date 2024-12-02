//
//  Color.swift
//  RenderingTutorial
//
//  Copyright (c) 2024 Jeremy All rights reserved.
    

import UIKit

public struct Color {
    public var r, g, b, a: UInt8
    
    public init(r: UInt8, g: UInt8, b: UInt8, a: UInt8 = 255) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
}

public extension Color {
    static let clear = Color(r: 0, g: 0, b: 0, a: 0)
    static let black = Color(r: 0, g: 0, b: 0)
    static let white = Color(r: 255, g: 255, b: 255)
    static let gray = Color(r: 192, g: 192, b: 192)
    static let red = Color(r: 255, g: 0, b: 0)
    static let green = Color(r: 0, g: 255, b: 0)
    static let blue = Color(r: 0, g: 0, b: 255)
    
    static func scaledDark(_ scale: Double) -> Color {
        let r = Double(white.r) * scale
        let g = Double(white.g) * scale
        let b = Double(white.b) * scale
        return Color(r: UInt8(r), g: UInt8(g), b: UInt8(b))
    }
}
