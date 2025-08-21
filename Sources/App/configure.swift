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
    let hostname = Environment.get("DATABASE_HOST") ?? "app-89170558-05c3-45d7-b88d-620cb9a91929-do-user-18627753-0.d.db.ondigitalocean.com"
    let port = Environment.get("DATABASE_PORT").flatMap(Int.init) ?? 25060
    let username = Environment.get("DATABASE_USERNAME") ?? "mustaffar"
    let password = Environment.get("DATABASE_PASSWORD") ?? "***REMOVED***"
    let database = Environment.get("DATABASE_NAME") ?? "mustaffar"
    
    // Create SQL PostgreSQL configuration
    let postgresConfig = SQLPostgresConfiguration(
        hostname: hostname,
        port: port,
        username: username,
        password: password,
        database: database,
        tls: .disable
    )
    
    app.databases.use(.postgres(
        configuration: postgresConfig
    ), as: .psql)
    
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