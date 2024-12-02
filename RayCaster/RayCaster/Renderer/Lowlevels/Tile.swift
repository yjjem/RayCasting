//
//  Tile.swift
//  RenderingTutorial
//
//  Copyright (c) 2024 Jeremy All rights reserved.
    

public enum Tile {
    case floor
    case wall
}

extension Tile {
    var isWall: Bool {
        switch self {
        case .wall: return true
        default: return false
        }
    }
}
