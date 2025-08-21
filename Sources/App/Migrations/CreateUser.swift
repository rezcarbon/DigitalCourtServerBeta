import Fluent

// Migration to create the users table
struct CreateUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("users")
            .id()
            .field("username", .string, .required)
            .field("email", .string)
            .field("full_name", .string)
            .field("is_admin", .bool, .required, .custom("DEFAULT false"))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "username")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("users").delete()
    }
}