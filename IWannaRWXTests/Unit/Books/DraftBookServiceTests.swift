//
//  DraftBookServiceTests.swift
//  book_film_inboxTests
//

import XCTest
@testable import IWannaRWX

@MainActor final class DraftBookServiceTests: XCTestCase {

    private var sut: DraftBookService { DraftBookService.shared }

    func test_single() {
        let item = sut.single(query: "My Custom Book")
        XCTAssertEqual(item.title, "My Custom Book")
        XCTAssertNil(item.sourceId)
        XCTAssertEqual(item.sourceName, DraftBookService.serviceName)
        XCTAssertTrue(sut.isDraft(item: item.toCommonMediaItem()))
    }

    func test_search() async throws {
        let results = try await sut.search(query: "Harry Potter", limit: 10)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "Harry Potter")
        XCTAssertNil(results.first?.sourceId)
        XCTAssertEqual(results.first?.sourceName, DraftBookService.serviceName)
        XCTAssertTrue(sut.isDraft(item: results.first!.toCommonMediaItem()))
    }

    func test_getDetails() async throws {
        let original = sut.single(query: "Foundation")
        let detailed = try await sut.getDetails(item: original)
        XCTAssertEqual(detailed.id, original.id)
        XCTAssertEqual(detailed.title, original.title)
    }
    
    func test_getSourceUrl_encodesTitle() throws {
        let item = ExternalBookItem(title: "Hello World", sourceId: nil, sourceName: DraftBookService.serviceName)
        let url = try sut.getSourceUrl(item: item.toCommonMediaItem())
        XCTAssertEqual(url.absoluteString, "https://google.com/search?q=Hello%20World")
    }

}
