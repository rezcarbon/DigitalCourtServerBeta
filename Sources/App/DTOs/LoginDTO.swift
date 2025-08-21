import Vapor

// DTO for login requests
struct LoginDTO: Content {
    let username: String
    let password: String
}

// Response for successful login
struct LoginResponse: Content {
    let token: String
    let expiresIn: Int
}