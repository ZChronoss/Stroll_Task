import Foundation

struct User: Identifiable, Codable {
    var id: Int
    var name: String
    var age: Int
    var question: String
    
    init(id: Int, name: String, age: Int, question: String) {
        self.id = id
        self.name = name
        self.age = age
        self.question = question
    }
}

extension User: Hashable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}
