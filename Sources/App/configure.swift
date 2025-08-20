import Vapor
import Fluent
import FluentPostgresDriver
import JWT
import NIOTLS

// Configures your application
public func configure(_ app: Application) async throws {
    // Configure logging based on environment
    if let logLevel = Environment.get("LOG_LEVEL") {
        app.logger.logLevel = Logger.Level(rawValue: logLevel) ?? .info
    }

    // --- 1. Configure PostgreSQL Connection from Environment ---
    // App Platform provides the DATABASE_URL automatically.
    if let postgresURL = Environment.get("DATABASE_URL") {
        app.logger.info("Configuring PostgreSQL with provided DATABASE_URL: \(postgresURL)")
        
        do {
            // Try to parse the URL to check if it's valid
            guard let url = URL(string: postgresURL) else {
                app.logger.error("Invalid DATABASE_URL format")
                throw Abort(.internalServerError, reason: "Invalid DATABASE_URL format")
            }
            
            app.logger.info("Parsed URL - Host: \(url.host ?? "nil"), Port: \(url.port ?? 0), Path: \(url.path)")
            
            // Configure the database using the URL directly
            app.databases.use(
                try .postgres(url: postgresURL, sqlLogLevel: .info),
                as: .psql
            )
        } catch {
            app.logger.error("Failed to parse DATABASE_URL: \(error)")
            throw Abort(.internalServerError, reason: "Invalid DATABASE_URL configuration: \(error)")
        }
    } else {
        // Fallback for local development if DATABASE_URL is not set
        app.logger.warning("DATABASE_URL not set. Using default local configuration.")
        
        app.databases.use(.postgres(
            hostname: "localhost",
            port: 5432,
            username: "vapor_username",
            password: "vapor_password",
            database: "digitalcourt"
        ), as: .psql)
    }

    // --- 2. Run Migrations ---
    app.migrations.add(CreateUser())
    app.migrations.add(CreateUserIndex())
    try await app.autoMigrate()
    
    // --- 3. Configure Password Hasher ---
    app.passwords.use(.bcrypt)

    // --- 4. Configure JWT Signer ---
    guard let jwtSecret = Environment.get("JWT_SECRET") else {
        app.logger.critical("JWT_SECRET environment variable not set.")
        throw Abort(.internalServerError, reason: "JWT configuration missing")
    }
    
    app.jwt.signers.use(.hs256(key: jwtSecret))
    app.logger.info("JWT configuration initialized")

    // Register your routes
    try routes(app)
}