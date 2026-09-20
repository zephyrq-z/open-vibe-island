import Foundation
import Testing
@testable import OpenIslandApp

@MainActor
@Suite(.serialized)
struct ROGNotchLightingTests {
    private static let enabledKey = "appearance.notch.rogLighting.enabled"
    private static let modeKey = "appearance.notch.rogLighting.mode"

    private func clearStoredPreferences() {
        UserDefaults.standard.removeObject(forKey: Self.enabledKey)
        UserDefaults.standard.removeObject(forKey: Self.modeKey)
    }

    @Test
    func defaultsToBreathingDisabledLighting() {
        clearStoredPreferences()
        defer { clearStoredPreferences() }

        let model = AppModel()

        #expect(model.rogNotchLightingEnabled == false)
        #expect(model.rogNotchLightingMode == .breathing)
        #expect(ROGNotchLightingMode.allCases.count == 4)
    }

    @Test
    func loadsPersistedLightingPreferences() {
        clearStoredPreferences()
        UserDefaults.standard.set(true, forKey: Self.enabledKey)
        UserDefaults.standard.set(ROGNotchLightingMode.spectrumFlow.rawValue, forKey: Self.modeKey)
        defer { clearStoredPreferences() }

        let model = AppModel()

        #expect(model.rogNotchLightingEnabled == true)
        #expect(model.rogNotchLightingMode == .spectrumFlow)
    }

    @Test
    func invalidModeFallsBackToBreathing() {
        clearStoredPreferences()
        UserDefaults.standard.set(true, forKey: Self.enabledKey)
        UserDefaults.standard.set("rgb-carousel", forKey: Self.modeKey)
        defer { clearStoredPreferences() }

        let model = AppModel()

        #expect(model.rogNotchLightingEnabled == true)
        #expect(model.rogNotchLightingMode == .breathing)
    }

    @Test
    func updatesPersistLightingPreferences() {
        clearStoredPreferences()
        defer { clearStoredPreferences() }

        let model = AppModel()
        model.rogNotchLightingEnabled = true
        model.rogNotchLightingMode = .pulse

        #expect(UserDefaults.standard.bool(forKey: Self.enabledKey))
        #expect(UserDefaults.standard.string(forKey: Self.modeKey) == ROGNotchLightingMode.pulse.rawValue)
    }
}
