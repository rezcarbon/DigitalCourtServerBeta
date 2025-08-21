import Vapor

// DTO for creating a case
struct CreateCaseDTO: Content {
    let caseNumber: String
    let title: String
    let description: String?
    let caseType: String
    let status: String?
    let assignedJudgeId: UUID?
    let plaintiff: String
    let defendant: String
}

// DTO for updating a case
struct UpdateCaseDTO: Content {
    let caseNumber: String?
    let title: String?
    let description: String?
    let caseType: String?
    let status: String?
    let assignedJudgeId: UUID?
    let plaintiff: String?
    let defendant: String?
}

// DTO for case response
struct CaseDTO: Content {
    let id: UUID?
    let caseNumber: String
    let title: String
    let description: String?
    let caseType: String
    let status: String
    let assignedJudgeId: UUID?
    let plaintiff: String
    let defendant: String
    let createdAt: Date?
    let updatedAt: Date?
}