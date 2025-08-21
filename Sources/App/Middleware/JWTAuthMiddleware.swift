import Vapor
import JWT

// Middleware to verify JWT tokens
struct JWTAuthMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        // Extract token from Authorization header
        guard let bearerToken = request.headers.bearerAuthorization else {
            throw Abort(.unauthorized, reason: "Missing Authorization header")
        }
        
        // Verify token
        let payload = try request.jwt.verify(bearerToken.token, as: UserJWTPayload.self)
        
        // Store user info in request for later use
        request.storage[UserInfoKey.self] = UserInfo(id: UUID(uuidString: payload.sub.value), username: payload.username)
        
        // Continue with request
        return try await next.respond(to: request)
    }
}

// Key for storing user info in request
struct UserInfoKey: StorageKey {
    typealias Value = UserInfo
}

// User info structure
struct UserInfo: Content {
    let id: UUID?
    let username: String
}