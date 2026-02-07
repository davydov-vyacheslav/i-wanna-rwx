//
//  OLModel.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 07.02.2026.
//

struct OLSearchResponse: Codable {
    let numFound: Int
    let start: Int
    let docs: [OLSearchDoc]
    
    enum CodingKeys: String, CodingKey {
        case numFound = "numFound"
        case start
        case docs
    }
}

struct OLSearchDoc: Codable {
    let key: String
    let title: String
    let authorName: [String]?
    let firstPublishYear: Int?
    let coverI: Int?
    let ratingsAverage: Double?
    let isbn: [String]?
    
    enum CodingKeys: String, CodingKey {
        case key
        case title
        case authorName = "author_name"
        case firstPublishYear = "first_publish_year"
        case coverI = "cover_i"
        case ratingsAverage = "ratings_average"
        case isbn
    }
}

struct OLWorkDetail: Codable {
    let description: OLDescription?
    let title: String?
    let covers: [Int]?
    let firstPublishDate: String?
    
    enum CodingKeys: String, CodingKey {
        case description
        case title
        case covers
        case firstPublishDate = "first_publish_date"
    }
}

struct OLDescription: Codable {
    let value: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            self.value = stringValue
        } else if let dictValue = try? container.decode([String: String].self) {
            self.value = dictValue["value"]
        } else {
            self.value = nil
        }
    }
}
