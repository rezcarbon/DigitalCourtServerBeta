import Vapor
import Fluent
import FluentMongoDriver
import JWT

// Configures your application
public func configure(_ app: Application) async throws {
    // Serves files from `Public/` directory
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // --- 1. Configure MongoDB Connection ---
    try app.databases.use(
        .mongo(
            connectionString: "mongodb+srv://doadmin:v9nh46B30bV1i2f8@db-mongodb-nyc2-mustaffar-4f008914.mongo.ondigitalocean.com/DigitalCourt?replicaSet=db-mongodb-nyc2-mustaffar&tls=true&authSource=admin"
        ),
        as: .mongo
    )

    // --- 2. Configure Password Hasher ---
    // Sets the default password hashing algorithm to bcrypt. This is the crucial
    // step that was missing and causing the downstream errors.
    app.passwords.use(.bcrypt)

    // --- 3. Configure JWT Signer ---
    // Sets up the key that will be used to sign and verify JSON Web Tokens.
    let jwtSecret = "vaderprime@19061975"
    app.jwt.signers.use(.hs256(key: jwtSecret))


    // Register your routes
    try routes(app)
}