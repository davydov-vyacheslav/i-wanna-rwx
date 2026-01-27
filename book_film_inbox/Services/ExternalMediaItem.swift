//
//  ExternalMediaItem.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 26.01.2026.
//

import Foundation
import SwiftData


protocol ExternalMediaItem: Identifiable {
    
    var itemDescription: String? { get }
    var title: String { get }
    var sourceUrl: URL { get }
    var sourceName: String { get }
    var status: MediaStatus { get }
    var coverUrl: URL? { get }
    var coverImageData: Data? { get }
    var year: Int? { get }
  
}


