import Fluent

// Migration to create the cases table
struct CreateCase: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("cases")
            .id()
            .field("case_number", .string, .required)
            .field("title", .string, .required)
            .field("description", .string)
            .field("case_type", .string, .required)
            .field("status", .string, .required, .custom("DEFAULT 'open'"))
            .field("assigned_judge_id", .uuid)
            .field("plaintiff", .string, .required)
            .field("defendant", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "case_number")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("cases").delete()
    }
}