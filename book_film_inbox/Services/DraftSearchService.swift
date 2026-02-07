//
//  DraftServiceProtocol.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 07.02.2026.
//

protocol DraftSearchService: SearchService {
    func isDraft<T: CommonMediaItem>(item: T) -> Bool
    func single(query: String) -> SearchResultItem
}
