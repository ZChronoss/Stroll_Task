import Foundation
import Combine

class User: Identifiable, ObservableObject, Hashable, Codable {
    let id: Int
    let name: String
    let age: Int
    let question: String

    @Published var answered: Bool

    init(id: Int, name: String, age: Int, question: String, answered: Bool = false) {
        self.id = id
        self.name = name
        self.age = age
        self.question = question
        self.answered = answered
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case id, name, age, question, answered
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        age = try container.decode(Int.self, forKey: .age)
        question = try container.decode(String.self, forKey: .question)
        answered = try container.decode(Bool.self, forKey: .answered)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(age, forKey: .age)
        try container.encode(question, forKey: .question)
        try container.encode(answered, forKey: .answered)
    }

    // MARK: - Hashable

    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
