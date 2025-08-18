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

    app.logger.info("Attempting to connect to MongoDB")
    
    // Check if connection string contains SSL parameters
    var finalMongoURL = mongoURL
    if !mongoURL.contains("ssl=") && !mongoURL.contains("tls=") {
        // Add SSL parameter if not present
        if mongoURL.contains("?") {
            finalMongoURL += "&ssl=true"
        } else {
            finalMongoURL += "?ssl=true"
        }
        app.logger.info("Added SSL parameter to connection string")
    }
    
    // Log connection information (mask sensitive data)
    if let urlComponents = URLComponents(string: mongoURL) {
        var maskedURL = mongoURL
        if let password = urlComponents.password {
            maskedURL = mongoURL.replacingOccurrences(of: ":\(password)@", with: ":***@")
        }
        app.logger.info("MongoDB connection string: \(maskedURL)")
    }

    // Use the connection string to configure the database.
    do {
        try app.databases.use(.mongo(connectionString: finalMongoURL), as: .mongo)
        app.logger.info("Successfully configured MongoDB connection")
    } catch {
        app.logger.critical("Failed to configure MongoDB connection: \(error)")
        app.logger.critical("Error details: \(error.localizedDescription)")
        throw Abort(.internalServerError, reason: "Database configuration failed: \(error.localizedDescription)")
    }

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
    app.logger.info("JWT configuration initialized")

    // Register your routes
    try routes(app)
}