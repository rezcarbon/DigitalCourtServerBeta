import Fluent

// Migration to create indexes on the users table
struct CreateUserIndex: AsyncMigration {
    func prepare(on database: Database) async throws {
        // Create index on email field for faster lookups
        try await database.schema("users")
            .unique(on: "email")
            .update()
    }

    func revert(on database: Database) async throws {
        // Remove the index
        try await database.schema("users")
            .deleteUnique(on: "email")
            .update()
    }
}