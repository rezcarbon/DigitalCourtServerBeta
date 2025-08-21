import Vapor
import Fluent

// User model that works with PostgreSQL database
final class User: Model, Content {
    // Name of the table or collection
    static let schema = "users"
    
    // Unique identifier for this User
    @ID(key: .id)
    var id: UUID?
    
    // User's username
    @Field(key: "username")
    var username: String
    
    // User's email (optional)
    @Field(key: "email")
    var email: String?
    
    // User's full name (optional)
    @Field(key: "full_name")
    var fullName: String?
    
    // Flag to indicate if user is admin
    @Field(key: "is_admin")
    var isAdmin: Bool
    
    // Timestamp when user was created
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    // Timestamp when user was last updated
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    // Creates a new, empty User instance
    init() { }
    
    // Creates a new User with all properties set
    init(
        id: UUID? = nil,
        username: String,
        email: String? = nil,
        fullName: String? = nil,
        isAdmin: Bool = false
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.fullName = fullName
        self.isAdmin = isAdmin
    }
}