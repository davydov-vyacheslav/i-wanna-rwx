//
//  BookPersistenceServiceTests.swift
//  book_film_inboxTests
//

import XCTest
import SwiftData
@testable import IWannaRWX

@MainActor
final class BookPersistenceServiceTests: XCTestCase {

    private var container: ModelContainer!
    private var sut: BookPersistenceService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let schema = Schema([BookItem.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
        sut = BookPersistenceService(context: container.mainContext)
    }

    override func tearDown() {
        sut = nil
        container = nil
        super.tearDown()
    }

    private func makeBook(
        title: String = "Test Book",
        isbn: String? = nil,
        status: MediaStatus = .planned,
        isFavorite: Bool = false,
        rating: Double = 0.0
    ) -> BookItem {
        let book = BookItem(
            isFavorite: isFavorite,
            rating: rating,
            status: status,
            title: title,
            year: 2024,
            isbn: isbn,
            mainAuthor: "Test Author",
            sourceName: "Open Library",
            sourceId: "OL1W"
        )
        return book
    }

    private func fetchAll() throws -> [BookItem] {
        try container.mainContext.fetch(FetchDescriptor<BookItem>())
    }

    func test_add_multipleItems_allPersisted() throws {
        sut.add(makeBook(title: "Book A"))
        sut.add(makeBook(title: "Book B"))
        sut.add(makeBook(title: "Book C"))

        let books = try fetchAll()
        XCTAssertEqual(books.count, 3)
    }

    func test_add_preservesAllFields() throws {
        let book = makeBook(title: "Foundation", isbn: "9780553293357", status: .done)
        sut.add(book)

        let fetched = try fetchAll().first!
        XCTAssertEqual(fetched.title, "Foundation")
        XCTAssertEqual(fetched.isbn, "9780553293357")
        XCTAssertEqual(MediaItemHelper.getStatus(from: fetched), .done)
    }

    func test_delete_onlyRemovesTargetItem() throws {
        let book1 = makeBook(title: "Keep This")
        let book2 = makeBook(title: "Delete This")
        sut.add(book1)
        sut.add(book2)

        sut.delete(book2)

        let remaining = try fetchAll()
        XCTAssertEqual(remaining.count, 1)
        XCTAssertEqual(remaining.first?.title, "Keep This")
        
        let book = makeBook()
        XCTAssertNoThrow(sut.delete(book))
    }

    func test_toggleFavorite() throws {
        let book = makeBook(isFavorite: false)
        sut.add(book)
        sut.toggleFavorite(book)
        let fetched = try fetchAll().first!
        XCTAssertTrue(fetched.isFavorite)
        
        sut.toggleFavorite(book)
        let fetched2 = try fetchAll().first!
        XCTAssertFalse(fetched2.isFavorite)
    }

    func test_changeStatus() throws {
        let book = makeBook(status: .planned)
        sut.add(book)
        sut.changeStatus(book, to: .done)
        let fetched = try fetchAll().first!
        XCTAssertEqual(MediaItemHelper.getStatus(from: fetched), .done)
        
        sut.changeStatus(book, to: .planned)

        let fetched2 = try fetchAll().first!
        XCTAssertEqual(MediaItemHelper.getStatus(from: fetched2), .planned)
    }

     func test_isInLibrary() throws {
         let bookWithoutIsbn = makeBook(title: "No ISBN", isbn: nil)
         let bookItem = makeBook(isbn: "9780441013593")
         sut.add(bookItem)
         sut.add(bookWithoutIsbn)
         sut.add(makeBook(isbn: "9780441013594"))

         XCTAssertTrue(sut.isInLibrary("9780441013593"))
         XCTAssertTrue(sut.isInLibrary("9780441013594"))
         XCTAssertFalse(sut.isInLibrary("123456778890"))
         
         sut.delete(bookItem)
         XCTAssertFalse(sut.isInLibrary("9780441013593"))
         XCTAssertTrue(sut.isInLibrary("9780441013594"))
     }

    func test_addAndFetch_itemSurvivesAfterMultipleOperations() throws {
        let book = makeBook(title: "Persistent Book", isbn: "5555555555")
        sut.add(book)
        sut.toggleFavorite(book)
        sut.changeStatus(book, to: .done)

        let fetched = try fetchAll().first!
        XCTAssertEqual(fetched.title, "Persistent Book")
        XCTAssertTrue(fetched.isFavorite)
        XCTAssertEqual(MediaItemHelper.getStatus(from: fetched), .done)
    }
}
