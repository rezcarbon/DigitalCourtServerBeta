import Vapor
import Fluent
import FluentMongoDriver
import JWT

// Configures your application
public func configure(_ app: Application) async throws {
    // Serves files from `Public/` directory
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // --- 1. Configure MongoDB Connection from Environment ---
    // Get the database connection string from the DATABASE_URL environment variable.
    guard let mongoURL = Environment.get("DATABASE_URL") else {
        // If the variable is not set, we cannot proceed.
        // This is a fatal error for a production environment.
        fatalError("DATABASE_URL environment variable not set.")
    }

    // Use the connection string to configure the database.
    try app.databases.use(.mongo(connectionString: mongoURL), as: .mongo)

    // --- 2. Configure Password Hasher ---
    app.passwords.use(.bcrypt)

    // --- 3. Configure JWT Signer ---
    // It's also good practice to get the JWT secret from the environment.
    guard let jwtSecret = Environment.get("JWT_SECRET") else {
        fatalError("JWT_SECRET environment variable not set.")
    }
    app.jwt.signers.use(.hs256(key: jwtSecret))


    // Register your routes
    try routes(app)
}