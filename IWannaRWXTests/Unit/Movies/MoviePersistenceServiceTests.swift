//
//  MoviePersistenceServiceTests.swift
//  book_film_inboxTests
//

import XCTest
import SwiftData
@testable import IWannaRWX

@MainActor
final class MoviePersistenceServiceTests: XCTestCase {

    private var container: ModelContainer!
    private var sut: MoviePersistenceService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let schema = Schema([MovieItem.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
        sut = MoviePersistenceService(context: container.mainContext)
    }

    override func tearDown() {
        sut = nil
        container = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeMovie(
        title: String = "Test Movie",
        sourceName: String = "TMDb",
        sourceId: String? = "12345",
        type: VideoType = .movie,
        status: MediaStatus = .planned,
        isFavorite: Bool = false,
        rating: Double = 0.0,
        tvSeriesStatus: TvSeriesStatus? = nil
    ) -> MovieItem {
        let item = MovieItem(
            isFavorite: isFavorite,
            rating: rating,
            status: status,
            title: title,
            author: nil,
            sourceName: sourceName,
            type: type,
            sourceId: sourceId,
            originalTitle: title,
            tvSeriesStatus: tvSeriesStatus
        )
        return item
    }

    private func fetchAll() throws -> [MovieItem] {
        try container.mainContext.fetch(FetchDescriptor<MovieItem>())
    }

    func test_add() throws {
        sut.add(makeMovie(title: "Inception"))

        let movies = try fetchAll()
        XCTAssertEqual(movies.count, 1)
        XCTAssertEqual(movies.first?.title, "Inception")

        sut.add(makeMovie(title: "B", sourceId: "2"))
        sut.add(makeMovie(title: "C", sourceId: "3"))
        XCTAssertEqual(try fetchAll().count, 3)
    }

    func test_delete_onlyRemovesTarget() throws {
        let keep = makeMovie(title: "Keep", sourceId: "1")
        let remove = makeMovie(title: "Remove", sourceId: "2")
        sut.add(keep)
        sut.add(remove)

        sut.delete(remove)

        let remaining = try fetchAll()
        XCTAssertEqual(remaining.count, 1)
        XCTAssertEqual(remaining.first?.title, "Keep")
    }

    func test_toggleFavorite() throws {
        let movie = makeMovie(isFavorite: false)
        sut.add(movie)
        sut.toggleFavorite(movie)
        XCTAssertTrue(try fetchAll().first!.isFavorite)

        sut.toggleFavorite(movie)
        XCTAssertFalse(try fetchAll().first!.isFavorite)
    }

    func test_changeStatus() throws {
        let movie = makeMovie(status: .planned)
        sut.add(movie)
        sut.changeStatus(movie, to: .done)
        XCTAssertEqual(MediaItemHelper.getStatus(from: try fetchAll().first!), .done)
        
        sut.changeStatus(movie, to: .planned)
        XCTAssertEqual(MediaItemHelper.getStatus(from: try fetchAll().first!), .planned)
    }

    func test_isInLibrary() throws {
        let movieItem = makeMovie(sourceName: TMDbService.serviceName, sourceId: "27205")
        sut.add(movieItem)
        sut.add(makeMovie(sourceName: TMDbService.serviceName, sourceId: "12345"))

        XCTAssertTrue(sut.isInLibrary(sourceId: movieItem.sourceId, sourceName: TMDbService.serviceName))
        XCTAssertTrue(sut.isInLibrary(sourceId: "12345", sourceName: TMDbService.serviceName))
        XCTAssertFalse(sut.isInLibrary(sourceId: "99999", sourceName: TMDbService.serviceName))
        XCTAssertFalse(sut.isInLibrary(sourceId: "27205", sourceName: DraftBookService.serviceName))
        
        sut.delete(movieItem)
        XCTAssertFalse(sut.isInLibrary(sourceId: movieItem.sourceId, sourceName: TMDbService.serviceName))
        XCTAssertTrue(sut.isInLibrary(sourceId: "12345", sourceName: TMDbService.serviceName))
    }

    func test_fullLifecycle_addToggleFavoriteChangeStatusDelete() throws {
        let movie = makeMovie(title: "Lifecycle Movie", sourceId: "777")
        sut.add(movie)
        XCTAssertEqual(try fetchAll().count, 1)

        sut.toggleFavorite(movie)
        sut.changeStatus(movie, to: .done)

        let saved = try fetchAll().first!
        XCTAssertTrue(saved.isFavorite)
        XCTAssertEqual(MediaItemHelper.getStatus(from: saved), .done)

        sut.delete(movie)
        XCTAssertEqual(try fetchAll().count, 0)
    }
}
