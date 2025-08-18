import Vapor
import Fluent
import FluentMongoDriver
import JWT
import CORS

// Configures your application
public func configure(_ app: Application) async throws {
    // Configure logging based on environment
    if let logLevel = Environment.get("LOG_LEVEL") {
        app.logger.logLevel = Logger.Level(rawValue: logLevel) ?? .info
    }

    // Configure CORS
    let corsConfiguration: CORSMiddleware.Configuration
    if let allowedOrigins = Environment.get("ALLOWED_ORIGINS") {
        let origins = allowedOrigins.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
        corsConfiguration = CORSMiddleware.Configuration(
            allowedOrigin: .custom(origins),
            allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
            allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
        )
    } else {
        // Default CORS configuration for development
        corsConfiguration = CORSMiddleware.Configuration(
            allowedOrigin: .all,
            allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
            allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
        )
    }
    
    let cors = CORSMiddleware(configuration: corsConfiguration)
    app.middleware.use(cors, at: .beginning)

    // Serves files from `Public/` directory
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // --- 1. Configure MongoDB Connection from Environment ---
    // Get the database connection string from the DATABASE_URL environment variable.
    guard let mongoURL = Environment.get("DATABASE_URL") else {
        // If the variable is not set, we cannot proceed.
        // This is a fatal error for a production environment.
        app.logger.critical("DATABASE_URL environment variable not set.")
        throw Abort(.internalServerError, reason: "Database configuration missing")
    }

    // Use the connection string to configure the database.
    try app.databases.use(.mongo(connectionString: mongoURL), as: .mongo)

    // --- 2. Configure Password Hasher ---
    app.passwords.use(.bcrypt)

    // --- 3. Configure JWT Signer ---
    // It's also good practice to get the JWT secret from the environment.
    guard let jwtSecret = Environment.get("JWT_SECRET") else {
        app.logger.critical("JWT_SECRET environment variable not set.")
        throw Abort(.internalServerError, reason: "JWT configuration missing")
    }
    
    // Use the JWT secret for signing tokens
    app.jwt.signers.use(.hs256(key: jwtSecret))

    // Register your routes
    try routes(app)
}