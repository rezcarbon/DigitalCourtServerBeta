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
    // Check if DATABASE_URL is provided (which may include SSL configuration)
    if let databaseURL = Environment.get("DATABASE_URL") {
        // Use the provided DATABASE_URL as-is
        try app.databases.use(.postgres(url: databaseURL), as: .psql)
    } else {
        // Create database configuration from individual environment variables
        let databaseHost = Environment.get("DATABASE_HOST") ?? "localhost"
        let databasePort = Environment.get("DATABASE_PORT").flatMap(Int.init) ?? 5432
        let databaseUsername = Environment.get("DATABASE_USERNAME") ?? "mustaffar"
        let databasePassword = Environment.get("DATABASE_PASSWORD") ?? ""
        let databaseName = Environment.get("DATABASE_NAME") ?? "mustaffar"
        
        // Determine SSL mode
        let sslMode = Environment.get("DATABASE_SSLMODE") ?? "prefer"
        
        if sslMode == "require" || sslMode == "verify-ca" || sslMode == "verify-full" {
            // Configure with SSL
            var tlsConfig = TLSConfiguration.makeClientConfiguration()
            tlsConfig.certificateVerification = .fullVerification
            
            // If we have a CA certificate path, use it
            if let caCertPath = Environment.get("DATABASE_CA_CERT_PATH") {
                tlsConfig.trustRoots = .file(caCertPath)
            }
            
            let postgresConfig = SQLPostgresConfiguration(
                hostname: databaseHost,
                port: databasePort,
                username: databaseUsername,
                password: databasePassword,
                database: databaseName,
                tls: .require(tlsConfig)
            )
            
            try app.databases.use(.postgres(configuration: postgresConfig), as: .psql)
        } else {
            // Configure without SSL for local development
            let postgresConfig = SQLPostgresConfiguration(
                hostname: databaseHost,
                port: databasePort,
                username: databaseUsername,
                password: databasePassword,
                database: databaseName,
                tls: .disable
            )
            
            try app.databases.use(.postgres(configuration: postgresConfig), as: .psql)
        }
    }
    
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
