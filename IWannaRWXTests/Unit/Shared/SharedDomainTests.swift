//
//  SharedDomainTests.swift
//  book_film_inboxTests
//

import XCTest
import SwiftData
@testable import IWannaRWX

@MainActor final class MediaItemHelperTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let schema = Schema([BookItem.self, MovieItem.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
        context = container.mainContext
    }

    // MARK: - Book's getStatus and getRatingText

    func test_getStatus_planned_returnsPlanned() {
        let book = makeBook(status: .planned, rating: 0.0)
        XCTAssertEqual(MediaItemHelper.getStatus(from: book), .planned)
        XCTAssertEqual(MediaItemHelper.getRatingText(from: book), "N/A")
    }

    func test_getStatus_done_returnsDone() {
        let book = makeBook(status: .done, rating: 8.765)
        XCTAssertEqual(MediaItemHelper.getStatus(from: book), .done)
        XCTAssertEqual(MediaItemHelper.getRatingText(from: book), "8.8")
    }

    func test_getStatus_invalidRaw_defaultsToPlanned() {
        let book = makeBook(status: .planned, rating: 7.0)
        book.statusRaw = "garbage"
        XCTAssertEqual(MediaItemHelper.getStatus(from: book), .planned)
        XCTAssertEqual(MediaItemHelper.getRatingText(from: book), "7.0")
    }

    // MARK: - Movie's getTvSeriesStatus and getVideoType

    func test_getTvSeriesStatus_nil_returnsNil() {
        let movie = makeMovie(type: .movie, tvSeriesStatus: nil)
        XCTAssertEqual(MediaItemHelper.getVideoType(from: movie), .movie)
        XCTAssertNil(MediaItemHelper.getTvSeriesStatus(from: movie))
    }

    func test_getTvSeriesStatus_ongoing_returnsOngoing() {
        let movie = makeMovie(type: .tvSeries, tvSeriesStatus: .ongoing)
        XCTAssertEqual(MediaItemHelper.getVideoType(from: movie), .tvSeries)
        XCTAssertEqual(MediaItemHelper.getTvSeriesStatus(from: movie), .ongoing)
    }

    func test_getTvSeriesStatus_ended_returnsEnded() {
        let movie = makeMovie(type: .tvSeries, tvSeriesStatus: .ended)
        XCTAssertEqual(MediaItemHelper.getVideoType(from: movie), .tvSeries)
        XCTAssertEqual(MediaItemHelper.getTvSeriesStatus(from: movie), .ended)
    }

    // MARK: - Helpers

    private func makeBook(status: MediaStatus = .planned, rating: Double = 0.0) -> BookItem {
        let item = BookItem(
            status: status, title: "Test", year: nil, isbn: nil, mainAuthor: nil,
            sourceName: "Test", sourceId: nil
        )
        item.rating = rating
        context.insert(item)
        return item
    }

    private func makeMovie(
        type: VideoType = .movie, tvSeriesStatus: TvSeriesStatus? = nil
    ) -> MovieItem {
        let item = MovieItem(
            rating: 0.0, title: "Test Movie",
            author: nil, sourceName: "Test", type: type,
            sourceId: nil, originalTitle: nil, tvSeriesStatus: tvSeriesStatus
        )
        context.insert(item)
        return item
    }
}
