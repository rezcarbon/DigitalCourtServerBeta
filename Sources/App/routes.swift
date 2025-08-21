import Vapor

func routes(_ app: Application) throws {
    // Register the user controller
    try app.register(collection: UserController())
    
    // Register the auth controller
    try app.register(collection: AuthController())
    
    // Register the case controller
    try app.register(collection: CaseController())
    
    // Basic health check route
    app.get("health") { req in
        return "OK"
    }
    
    // Root route
    app.get { req -> String in
        return "Welcome to DigitalCourt Server Beta!"
    }
    
    // Favicon route to prevent 404 errors
    app.get("favicon.ico") { req -> Response in
        throw Abort(.notFound)
    }
}