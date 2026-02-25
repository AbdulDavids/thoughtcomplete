import SwiftUI
import FoundationModels

struct SettingsView: View {
    @Environment(AppState.self) private var appState

    private var appleIntelligenceAvailability: SystemLanguageModel.Availability {
        SystemLanguageModel.default.availability
    }

    var body: some View {
        @Bindable var appState = appState
        Form {
            Section("Autocomplete") {
                Toggle("Enable ghost-text suggestions", isOn: $appState.autocompleteEnabled)

                Picker("Provider", selection: $appState.selectedProvider) {
                    ForEach(CompletionProvider.allCases) { provider in
                        Text(provider.rawValue).tag(provider)
                    }
                }
                .disabled(!appState.autocompleteEnabled)

                if appState.selectedProvider == .foundationModels && appState.autocompleteEnabled {
                    availabilityNote
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 380)
        .padding()
    }

    @ViewBuilder
    private var availabilityNote: some View {
        switch appleIntelligenceAvailability {
        case .available:
            Label("Apple Intelligence is ready", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.callout)
        case .unavailable(.deviceNotEligible):
            Label("This Mac doesn't support Apple Intelligence", systemImage: "xmark.circle.fill")
                .foregroundStyle(.red)
                .font(.callout)
        case .unavailable(.appleIntelligenceNotEnabled):
            Label("Enable Apple Intelligence in System Settings → Apple Intelligence & Siri", systemImage: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
                .font(.callout)
        case .unavailable(.modelNotReady):
            Label("Apple Intelligence model is downloading…", systemImage: "arrow.down.circle")
                .foregroundStyle(.secondary)
                .font(.callout)
        default:
            Label("Apple Intelligence unavailable", systemImage: "xmark.circle")
                .foregroundStyle(.secondary)
                .font(.callout)
        }
    }
}
