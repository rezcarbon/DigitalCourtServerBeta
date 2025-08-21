import Vapor
@preconcurrency import JWT

// This extension makes our User model compatible with Vapor's authentication frameworks.
extension User: Authenticatable {}

// This struct defines the payload of our JSON Web Token.
struct UserJWTPayload: Content, Authenticatable, JWTPayload {
    // Subject claim (usually the user's ID)
    var sub: SubjectClaim
    
    // Expiration claim (the timestamp when the token expires)
    var exp: ExpirationClaim
    
    // Custom data: the username
    var username: String

    // Standard JWT payload verification function
    func verify(using signer: JWTKit.JWTSigner) throws {
        // Verifies that the token has not expired
        try self.exp.verifyNotExpired()
    }
}