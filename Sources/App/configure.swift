import Vapor
import Fluent
import FluentMongoDriver
import JWT

// Configures your application
public func configure(_ app: Application) async throws {
    // Configure logging based on environment
    if let logLevel = Environment.get("LOG_LEVEL") {
        app.logger.logLevel = Logger.Level(rawValue: logLevel) ?? .info
    }

    // --- 1. Configure MongoDB Connection from Environment ---
    // Using MONGODB_URL for MongoDB connection
    if let mongoURL = Environment.get("MONGODB_URL") {
        app.logger.info("Configuring MongoDB with provided MONGODB_URL")
        try app.databases.use(.mongo(connectionString: mongoURL), as: .mongo)
    } else {
        // Fallback for local development if MONGODB_URL is not set
        app.logger.warning("MONGODB_URL not set. Using default local configuration.")
        try app.databases.use(.mongo(connectionString: "mongodb://localhost:27017/digitalcourt"), as: .mongo)
    }

    // --- 2. Run Migrations ---
    // This creates the 'users' collection in your database on startup.
    app.migrations.add(CreateUser())
    try await app.autoMigrate()
    
    // --- 3. Configure Password Hasher ---
    app.passwords.use(.bcrypt)

    // --- 4. Configure JWT Signer ---
    guard let jwtSecret = Environment.get("JWT_SECRET") else {
        app.logger.critical("JWT_SECRET environment variable not set.")
        throw Abort(.internalServerError, reason: "JWT configuration missing")
    }
    
    // Use the JWT secret for signing tokens
    app.jwt.signers.use(.hs256(key: jwtSecret))
    app.logger.info("JWT configuration initialized")

    // Register your routes
    try routes(app)
}