//
//  SettingsExportComponent.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 30.04.2026.
//

import SwiftUI
import SwiftData

struct SettingsExportComponent: View {
    @Query private var movies: [MovieItem]
    @Query private var books: [BookItem]
    @Query private var reminders: [ReminderItem]

    var body: some View {
        ShareLink(item: exportFileURL(), preview: SharePreview(".label.settings.export")) {
            Label(".label.settings.export", systemImage: "square.and.arrow.up")
        }
    }

    private func exportFileURL() -> URL {
        let payload: [String: [[String: Any]]] = [
            "movies": movies.map {[
                "title":    $0.title,
                "status":   MediaItemHelper.getStatus(from: $0).rawValue,
                "favorite": $0.isFavorite,
                "source": (try? SettingsSourceStore.shared.getSource(
                    $0.sourceName,
                    for: $0,
                    as: ExternalMovieItem.self)?.instance.getSourceUrl(item: $0).absoluteString) ?? ""
            ] as [String: Any]},
            "books": books.map {[
                "title":    $0.title,
                "author":   $0.mainAuthor ?? "",
                "status":   MediaItemHelper.getStatus(from: $0).rawValue,
                "favorite": $0.isFavorite,
                "source":  (try? SettingsSourceStore.shared.getSource(
                    $0.sourceName,
                    for: $0,
                    as: ExternalBookItem.self)?.instance.getSourceUrl(item: $0).absoluteString) ?? ""
            ] as [String: Any]},
            "reminders": reminders.map {[
                "name": $0.name,
                "description": $0.itemDescription,
                "type": $0.typeRaw,
                "cost": $0.cost,
                "licenseKey": $0.licenseKey ?? "",
                "renewal": $0.renewalTypeRaw,
                "expiryDate": $0.expiryDate.map { ISO8601DateFormatter().string(from: $0) } ?? "",
                "notes": $0.notes
            ] as [String: Any]}
        ]
        let data = (try? JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)) ?? Data()
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("library_export.json")
        try? data.write(to: url)
        return url
    }
}
