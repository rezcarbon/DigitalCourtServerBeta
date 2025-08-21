import Vapor
import Fluent

// Model representing a court case
final class Case: Model, Content, @unchecked Sendable {
    // Name of the table or collection
    static let schema = "cases"
    
    // Unique identifier for this Case
    @ID(key: .id)
    var id: UUID?
    
    // Case number
    @Field(key: "case_number")
    var caseNumber: String
    
    // Case title
    @Field(key: "title")
    var title: String
    
    // Case description
    @Field(key: "description")
    var description: String?
    
    // Case type (e.g., civil, criminal, family)
    @Field(key: "case_type")
    var caseType: String
    
    // Case status (e.g., open, closed, in progress)
    @Field(key: "status")
    var status: String
    
    // Assigned judge ID
    @Field(key: "assigned_judge_id")
    var assignedJudgeId: UUID?
    
    // Plaintiff name
    @Field(key: "plaintiff")
    var plaintiff: String
    
    // Defendant name
    @Field(key: "defendant")
    var defendant: String
    
    // Timestamp when case was created
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    // Timestamp when case was last updated
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    // Creates a new, empty Case instance
    init() { }
    
    // Creates a new Case with all properties set
    init(
        id: UUID? = nil,
        caseNumber: String,
        title: String,
        description: String? = nil,
        caseType: String,
        status: String = "open",
        assignedJudgeId: UUID? = nil,
        plaintiff: String,
        defendant: String
    ) {
        self.id = id
        self.caseNumber = caseNumber
        self.title = title
        self.description = description
        self.caseType = caseType
        self.status = status
        self.assignedJudgeId = assignedJudgeId
        self.plaintiff = plaintiff
        self.defendant = defendant
    }
}
