//
//  CommonFilterType.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 11.03.2026.
//

protocol FilterTypeOption: CaseIterable, Identifiable, Hashable {
    var icon: String { get }
    var label: String { get }
    static var all: Self { get }
}

protocol CommonFilterState: Equatable {
    associatedtype FilterType: FilterTypeOption
    var isActive: Bool { get }
    var activeCount: Int { get }
    var itemType: FilterType { get set }
}
