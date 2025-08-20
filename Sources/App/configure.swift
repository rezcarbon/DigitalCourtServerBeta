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
    // App Platform provides the DATABASE_URL automatically.
    if let postgresURL = Environment.get("DATABASE_URL") {
        app.logger.info("Configuring PostgreSQL with provided DATABASE_URL")
        var tlsConfig = TLSConfiguration.makeClientConfiguration()
        tlsConfig.certificateVerification = .none // Required for DO Managed DB
        let postgresConfig = try SQLPostgresDriver.Configuration(url: postgresURL, tls: tlsConfig)
        
        // Configure connection pool for better performance
        var poolConfig = SQLPostgresDriver.ConnectionPoolOptions()
        poolConfig.maximumConnections = 20
        poolConfig.minimumConnections = 2
        poolConfig.keepAliveDuration = .seconds(30)
        
        app.databases.use(.postgres(
            configuration: postgresConfig,
            connectionPoolOptions: poolConfig
        ), as: .psql)
    } else {
        // Fallback for local development if DATABASE_URL is not set
        app.logger.warning("DATABASE_URL not set. Using default local configuration.")
        
        // Configure connection pool for local development
        var poolConfig = SQLPostgresDriver.ConnectionPoolOptions()
        poolConfig.maximumConnections = 10
        poolConfig.minimumConnections = 1
        poolConfig.keepAliveDuration = .seconds(60)
        
        try app.databases.use(.postgres(
            hostname: "localhost",
            port: 5432,
            username: "vapor_username",
            password: "vapor_password",
            database: "digitalcourt",
            connectionPoolOptions: poolConfig
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