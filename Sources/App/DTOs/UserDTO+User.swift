import Vapor

// Extension to convert between User model and DTOs
extension UserDTO {
    init(from user: User) {
        self.id = user.id
        self.username = user.username
        self.email = user.email
        self.fullName = user.fullName
        self.isAdmin = user.isAdmin
    }
}

extension CreateUserDTO {
    func toUser() -> User {
        return User(
            username: self.username,
            email: self.email,
            fullName: self.fullName,
            isAdmin: self.isAdmin ?? false
        )
    }
}