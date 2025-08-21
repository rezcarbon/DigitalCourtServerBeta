import Vapor
import Fluent

// Controller for handling user-related requests
struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.get(use: index)
        users.post(use: create)
        
        // Enable routes that require database
        users.group(":userID") { user in
            user.get(use: show)
            user.delete(use: delete)
            user.put(use: update)
        }
    }

    // GET /users - List all users
    func index(req: Request) async throws -> [User] {
        try await User.query(on: req.db).all()
    }

    // POST /users - Create a new user
    func create(req: Request) async throws -> User {
        let userDTO = try req.content.decode(CreateUserDTO.self)
        let user = User(
            username: userDTO.username,
            email: userDTO.email,
            fullName: userDTO.fullName,
            isAdmin: userDTO.isAdmin ?? false
        )
        try await user.save(on: req.db)
        return user
    }

    // GET /users/:userID - Get a specific user
    func show(req: Request) async throws -> User {
        guard let userID = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let user = try await User.find(userID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        return user
    }

    // PUT /users/:userID - Update a user
    func update(req: Request) async throws -> User {
        guard let userID = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let user = try await User.find(userID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        let userDTO = try req.content.decode(UpdateUserDTO.self)
        
        if let username = userDTO.username {
            user.username = username
        }
        
        if let email = userDTO.email {
            user.email = email
        }
        
        if let fullName = userDTO.fullName {
            user.fullName = fullName
        }
        
        if let isAdmin = userDTO.isAdmin {
            user.isAdmin = isAdmin
        }
        
        try await user.save(on: req.db)
        return user
    }

    // DELETE /users/:userID - Delete a user
    func delete(req: Request) async throws -> HTTPStatus {
        guard let userID = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let user = try await User.find(userID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await user.delete(on: req.db)
        return .noContent
    }
}