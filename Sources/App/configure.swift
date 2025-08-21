import Vapor
import JWT
import Fluent
import FluentPostgresDriver

// Configures your application
public func configure(_ app: Application) async throws {
    // Configure logging based on environment
    if let logLevel = Environment.get("LOG_LEVEL") {
        app.logger.logLevel = Logger.Level(rawValue: logLevel) ?? .info
    }

    // --- 1. Configure Password Hasher ---
    app.passwords.use(.bcrypt)

    // --- 2. Configure JWT Signer ---
    let jwtSecret = Environment.get("JWT_SECRET") ?? "default_jwt_secret_for_development"
    app.jwt.signers.use(.hs256(key: jwtSecret))
    app.logger.info("JWT configuration initialized")

    // --- 3. Configure PostgreSQL Database ---
    let databaseURL = Environment.get("DATABASE_URL") ?? 
        "postgresql://mustaffar:***REMOVED***@app-89170558-05c3-45d7-b88d-620cb9a91929-do-user-18627753-0.d.db.ondigitalocean.com:25060/mustaffar?sslmode=require"
    
    try app.databases.use(.postgres(url: databaseURL), as: .psql)
    app.logger.info("Database configuration initialized")

    // --- 4. Configure Migrations ---
    app.migrations.add(CreateUser())
    app.migrations.add(CreateUserIndex())
    app.migrations.add(CreateCase())
    
    // Run migrations
    try await app.autoMigrate()
    app.logger.info("Database migrations completed")

    // Register your routes
    try routes(app)
}