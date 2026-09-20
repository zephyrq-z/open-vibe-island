import Foundation
import Testing
@testable import OpenIslandApp
import OpenIslandCore

@MainActor
struct AppModelEvosciSetupTests {
    private func makeEvosciSession(
        id: String,
        origin: SessionOrigin = .live,
        isSessionEnded: Bool = false
    ) -> AgentSession {
        var session = AgentSession(
            id: id,
            title: "Evosci · Test",
            tool: .evosci,
            origin: origin,
            phase: .running,
            summary: "Running",
            updatedAt: Date(timeIntervalSince1970: 2_000)
        )
        session.isSessionEnded = isSessionEnded
        return session
    }

    @Test
    func activeEvosciSessionIsDetectedForSetup() {
        let model = AppModel()
        model.state = SessionState(sessions: [makeEvosciSession(id: "evosci-live")])

        #expect(model.hasActiveEvosciSession)
    }

    @Test
    func endedEvosciSessionIsNotShownAsDetected() {
        let model = AppModel()
        model.state = SessionState(sessions: [
            makeEvosciSession(id: "evosci-ended", isSessionEnded: true)
        ])

        #expect(!model.hasActiveEvosciSession)
    }

    @Test
    func demoEvosciSessionIsNotShownAsDetected() {
        let model = AppModel()
        model.state = SessionState(sessions: [
            makeEvosciSession(id: "evosci-demo", origin: .demo)
        ])

        #expect(!model.hasActiveEvosciSession)
    }
}
