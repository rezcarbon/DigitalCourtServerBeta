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
        app.logger.info("Configuring PostgreSQL with provided DATABASE_URL")
        
        do {
            // Parse the DATABASE_URL to extract connection parameters
            var config = try SQLPostgresConfiguration(url: postgresURL)
            
            // Check if SSL is required (common pattern in DATABASE_URL)
            if postgresURL.contains("sslmode=require") || postgresURL.contains("ssl=true") {
                // Configure TLS with the provided CA certificate if available
                if let caCertPath = Environment.get("DB_CA_CERT_PATH") {
                    app.logger.info("Configuring TLS with custom CA certificate from: \(caCertPath)")
                    var tlsConfig = TLSConfiguration.makeClientConfiguration()
                    tlsConfig.certificateVerification = .fullVerification
                    tlsConfig.trustRoots = .file(caCertPath)
                    config.tls = .require(tlsConfig)
                } else {
                    // Use default certificate verification (trust system certificates)
                    app.logger.info("Configuring TLS with system default certificates")
                    var tlsConfig = TLSConfiguration.makeClientConfiguration()
                    tlsConfig.certificateVerification = .fullVerification
                    config.tls = .require(tlsConfig)
                }
            }
            
            app.databases.use(.postgres(
                configuration: config
            ), as: .psql)
        } catch {
            app.logger.error("Failed to parse DATABASE_URL: \(error)")
            throw Abort(.internalServerError, reason: "Invalid DATABASE_URL configuration: \(error)")
        }
    } else {
        // Fallback for local development if DATABASE_URL is not set
        app.logger.warning("DATABASE_URL not set. Using default local configuration.")
        
        let config = SQLPostgresConfiguration(
            hostname: "localhost",
            port: 5432,
            username: "vapor_username",
            password: "vapor_password",
            database: "digitalcourt",
            tls: .disable
        )
        
        app.databases.use(.postgres(
            configuration: config
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