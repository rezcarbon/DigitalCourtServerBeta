import Vapor
import Fluent

// Controller for handling case-related requests
struct CaseController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        // Add JWT auth middleware to protect case routes
        let cases = routes.grouped("cases")
        cases.get(use: index)
        cases.post(use: create)
        
        cases.group(":caseID") { `case` in
            `case`.get(use: show)
            `case`.put(use: update)
            `case`.delete(use: delete)
        }
    }

    // GET /cases - List all cases
    func index(req: Request) async throws -> [Case] {
        try await Case.query(on: req.db).all()
    }

    // POST /cases - Create a new case
    func create(req: Request) async throws -> Case {
        let createCaseDTO = try req.content.decode(CreateCaseDTO.self)
        let `case` = Case(
            caseNumber: createCaseDTO.caseNumber,
            title: createCaseDTO.title,
            description: createCaseDTO.description,
            caseType: createCaseDTO.caseType,
            status: createCaseDTO.status ?? "open",
            assignedJudgeId: createCaseDTO.assignedJudgeId,
            plaintiff: createCaseDTO.plaintiff,
            defendant: createCaseDTO.defendant
        )
        try await `case`.save(on: req.db)
        return `case`
    }

    // GET /cases/:caseID - Get a specific case
    func show(req: Request) async throws -> Case {
        guard let caseID = req.parameters.get("caseID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let `case` = try await Case.find(caseID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        return `case`
    }

    // PUT /cases/:caseID - Update a case
    func update(req: Request) async throws -> Case {
        guard let caseID = req.parameters.get("caseID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let `case` = try await Case.find(caseID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        let updateCaseDTO = try req.content.decode(UpdateCaseDTO.self)
        
        if let caseNumber = updateCaseDTO.caseNumber {
            `case`.caseNumber = caseNumber
        }
        
        if let title = updateCaseDTO.title {
            `case`.title = title
        }
        
        if let description = updateCaseDTO.description {
            `case`.description = description
        }
        
        if let caseType = updateCaseDTO.caseType {
            `case`.caseType = caseType
        }
        
        if let status = updateCaseDTO.status {
            `case`.status = status
        }
        
        if let assignedJudgeId = updateCaseDTO.assignedJudgeId {
            `case`.assignedJudgeId = assignedJudgeId
        }
        
        if let plaintiff = updateCaseDTO.plaintiff {
            `case`.plaintiff = plaintiff
        }
        
        if let defendant = updateCaseDTO.defendant {
            `case`.defendant = defendant
        }
        
        try await `case`.save(on: req.db)
        return `case`
    }

    // DELETE /cases/:caseID - Delete a case
    func delete(req: Request) async throws -> HTTPStatus {
        guard let caseID = req.parameters.get("caseID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let `case` = try await Case.find(caseID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await `case`.delete(on: req.db)
        return .noContent
    }
}