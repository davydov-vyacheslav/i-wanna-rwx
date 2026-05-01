//
//  TriState.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 30.04.2026.
//

enum TriState: Equatable {
    case all, include, exclude

    mutating func cycle() {
        switch self {
        case .all:     self = .include
        case .include: self = .exclude
        case .exclude: self = .all
        }
    }
}
