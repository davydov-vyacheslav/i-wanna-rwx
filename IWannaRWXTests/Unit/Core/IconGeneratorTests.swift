//
//  IconGeneratorTests.swift
//  book_film_inboxTests
//

import XCTest
@testable import IWannaRWX

final class IconGeneratorTests: XCTestCase {

    // MARK: - Categorised Icons

    override func setUp() {
         super.setUp()
         continueAfterFailure = true
     }

     private func assertIcon(for input: String, equals expected: String, file: StaticString = #file, line: UInt = #line) {
         XCTAssertEqual(
             IconGenerator.suggestIcon(for: input), expected,
             "Input: \"\(input)\"",
             file: file, line: line
         )
     }

     func test_suggestIcon_allCategorisedKeywords() {
         assertIcon(for: "Outlook Mail",    equals: "📧")
         assertIcon(for: "Steam Games",     equals: "🎮")
         assertIcon(for: "Netflix",         equals: "🎬")
         assertIcon(for: "YouTube Premium", equals: "🎬")
         assertIcon(for: "Spotify",         equals: "🎵")
         assertIcon(for: "Tidal HiFi",      equals: "🎵")
         assertIcon(for: "ChatGPT Plus",    equals: "🤖")
         assertIcon(for: "Claude Pro",      equals: "🤖")
         assertIcon(for: "GitLab CI",       equals: "💻")
         assertIcon(for: "Figma",           equals: "🎨")
         assertIcon(for: "Canva Pro",       equals: "📈")
         assertIcon(for: "Dropbox Plus",    equals: "☁️")
         assertIcon(for: "Notion",          equals: "📝")
         assertIcon(for: "Slack",           equals: "💬")
         assertIcon(for: "Discord Nitro",   equals: "💬")
     }

    // MARK: - Case Insensitivity

    func test_suggestIcon_caseInsesitivityKeyword() {
        assertIcon(for: "NETFLIX", equals: "🎬")
        assertIcon(for: "SpotIfY", equals: "🎵")
    }


    // MARK: - Fallback (Hashed Icon)

    func test_suggestIcon_unknownName_returnsFallbackIcon() {
        let icon = IconGenerator.suggestIcon(for: "SomeRandomService")
        let fallbackIcons = ["📦", "📁", "🔧", "📎", "🧩", "🗂️", "🔒", "⚙️"]
        XCTAssertTrue(fallbackIcons.contains(icon), "Unexpected fallback icon: \(icon)")
    }

    func test_suggestIcon_emptyString_returnsFallbackIcon() {
        let icon = IconGenerator.suggestIcon(for: "")
        let fallbackIcons = ["📦", "📁", "🔧", "📎", "🧩", "🗂️", "🔒", "⚙️"]
        XCTAssertTrue(fallbackIcons.contains(icon))
    }

}
