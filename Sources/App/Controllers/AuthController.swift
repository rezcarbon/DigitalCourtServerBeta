import Vapor
import JWT
import Fluent

// Controller for authentication-related requests
struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        auth.post("register", use: register)
        auth.post("login", use: login)
    }

    // POST /auth/register - Register a new user
    func register(req: Request) async throws -> User {
        let createUserDTO = try req.content.decode(CreateUserDTO.self)
        
        // Check if user already exists
        let existingUser = try await User.query(on: req.db)
            .filter(\.$username == createUserDTO.username)
            .first()
        
        if existingUser != nil {
            throw Abort(.conflict, reason: "Username already exists")
        }
        
        // Create new user
        let user = User(
            username: createUserDTO.username,
            email: createUserDTO.email,
            fullName: createUserDTO.fullName,
            isAdmin: createUserDTO.isAdmin ?? false
        )
        
        try await user.save(on: req.db)
        return user
    }

    // POST /auth/login - Login user and return JWT token
    func login(req: Request) async throws -> LoginResponse {
        let loginDTO = try req.content.decode(LoginDTO.self)
        
        // Find user by username
        guard let user = try await User.query(on: req.db)
            .filter(\.$username == loginDTO.username)
            .first() else {
            throw Abort(.unauthorized, reason: "Invalid credentials")
        }
        
        // Create JWT payload
        let payload = UserJWTPayload(
            sub: SubjectClaim(value: user.id?.uuidString ?? ""),
            exp: ExpirationClaim(value: Date().addingTimeInterval(3600)), // 1 hour
            username: user.username
        )
        
        // Generate token
        let token = try req.jwt.sign(payload)
        
        return LoginResponse(token: token, expiresIn: 3600)
    }
}