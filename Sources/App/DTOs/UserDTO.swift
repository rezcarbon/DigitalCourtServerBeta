import Vapor

// Simplified DTOs that don't require database
struct UserDTO: Content {
    var id: UUID?
    var username: String
    var email: String?
    var fullName: String?
    var isAdmin: Bool
}

struct CreateUserDTO: Content {
    var username: String
    var password: String
    var email: String?
    var fullName: String?
    var isAdmin: Bool?
}

struct UpdateUserDTO: Content {
    var username: String?
    var password: String?
    var email: String?
    var fullName: String?
    var isAdmin: Bool?
}