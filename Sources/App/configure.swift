import Vapor
import Fluent
import FluentPostgresDriver
import JWT

// Configures your application
public func configure(_ app: Application) async throws {
    // Configure logging based on environment
    if let logLevel = Environment.get("LOG_LEVEL") {
        app.logger.logLevel = Logger.Level(rawValue: logLevel) ?? .info
    }

    // --- 1. Configure PostgreSQL Connection from Environment ---
    // DigitalOcean provides the DATABASE_URL automatically.
    // FluentPostgresDriver can parse this URL to configure the connection.
    if let postgresURL = Environment.get("DATABASE_URL") {
        app.logger.info("Configuring PostgreSQL with provided DATABASE_URL")
        try app.databases.use(.postgres(url: postgresURL), as: .psql)
    } else {
        // Fallback for local development if DATABASE_URL is not set
        app.logger.warning("DATABASE_URL not set. Using default local configuration.")
        try app.databases.use(.postgres(
            hostname: "localhost",
            username: "vapor_username",
            password: "vapor_password",
            database: "vapor_database"
        ), as: .psql)
    }

    // --- 2. Run Migrations ---
    // This creates the 'users' table in your database on startup.
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