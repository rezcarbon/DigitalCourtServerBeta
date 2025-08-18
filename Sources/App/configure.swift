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

    app.logger.info("Attempting to connect to MongoDB with URL: \(mongoURL.prefix(20))...") // Log prefix only for security

    // Use the connection string to configure the database.
    do {
        try app.databases.use(.mongo(connectionString: mongoURL), as: .mongo)
        app.logger.info("Successfully connected to MongoDB")
        
        // Test the connection
        try await testDatabaseConnection(app)
    } catch {
        app.logger.critical("Failed to connect to MongoDB: \(error)")
        throw Abort(.internalServerError, reason: "Database connection failed: \(error.localizedDescription)")
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

// Test database connection
private func testDatabaseConnection(_ app: Application) async throws {
    app.logger.info("Testing database connection...")
    do {
        // Try to perform a simple query to test the connection
        let result = try await app.db.mongo.raw.runCommand([
            "ping": 1
        ], as: [String: Any].self)
        app.logger.info("Database connection test successful: \(result)")
    } catch {
        app.logger.error("Database connection test failed: \(error)")
        throw error
    }
}