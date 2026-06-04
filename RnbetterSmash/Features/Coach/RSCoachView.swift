import SwiftUI

/// The AI combat-coach chat. Never blocked for free users: after the free AI
/// cap, it keeps answering with simplified on-device educational responses.
struct RSCoachView: View {
    @Binding var showPaywall: Bool

    @Environment(RSProgressManager.self) private var manager
    @Environment(SubscriptionManagerBPV.self) private var purchases

    @State private var vm = RSCoachViewModel()
    @State private var speech = RSSpeechRecognizer()
    @State private var showDisclaimer = false
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            header
            usageBanner
            messageList
            inputBar
        }
        .padding(.top, 8)
        // Clear the custom floating tab bar so it never covers the input bar.
        .padding(.bottom, 96)
        .overlay {
            if showDisclaimer {
                RSCoachDisclaimerView {
                    manager.markCoachDisclaimerSeen()
                    withAnimation { showDisclaimer = false }
                }
                .transition(.opacity)
                .zIndex(5)
            }
        }
        .onAppear {
            vm.configure(purchases: purchases, progress: manager)
            if !manager.progress.hasSeenCoachDisclaimer {
                showDisclaimer = true
            }
        }
        .onChange(of: speech.transcript) { _, new in
            if !new.isEmpty { vm.draft = new }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(RSTheme.energy).frame(width: 40, height: 40)
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 19, weight: .bold)).foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text("AI Combat Coach").font(.rsHeadline(17)).foregroundStyle(RSTheme.textPrimary)
                Text(vm.aiBackedAvailable ? "On-device intelligence active" : "On-device educational engine")
                    .font(.rsCaption(11)).foregroundStyle(RSTheme.textSecondary)
            }
            Spacer()
            Button {
                vm.clear()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.rsHeadline(16)).foregroundStyle(RSTheme.textSecondary)
            }
            .accessibilityLabel("Clear conversation")
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 8)
    }

    // MARK: - Usage banner

    @ViewBuilder private var usageBanner: some View {
        if let remaining = vm.remainingFreeResponses {
            HStack(spacing: 10) {
                Image(systemName: "bolt.fill").foregroundStyle(RSTheme.warning)
                Text(vm.hasReachedFreeLimit
                     ? "Daily free AI limit reached — resets tomorrow"
                     : "\(remaining) free AI responses left today")
                    .font(.rsCaption(12)).foregroundStyle(RSTheme.textSecondary)
                Spacer()
                Button("Unlock") { showPaywall = true }
                    .font(.rsCaption(12)).foregroundStyle(RSTheme.glowCyan)
            }
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(RSTheme.glassFill, in: Capsule())
            .padding(.horizontal, 18)
            .padding(.bottom, 6)
        }
    }

    // MARK: - Messages

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(vm.messages) { message in
                        RSCoachBubble(message: message)
                            .id(message.id)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                // Tapping the conversation area dismisses the keyboard.
                .frame(maxWidth: .infinity, minHeight: 0)
                .contentShape(Rectangle())
                .onTapGesture { inputFocused = false }
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: vm.messages.count) {
                if let last = vm.messages.last {
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
        }
    }

    // MARK: - Input

    private var inputBar: some View {
        HStack(spacing: 10) {
            Button {
                Task { await toggleVoice() }
            } label: {
                Image(systemName: speech.isListening ? "mic.fill" : "mic")
                    .font(.rsHeadline(18))
                    .foregroundStyle(speech.isListening ? RSTheme.danger : RSTheme.glowCyan)
                    .frame(width: 44, height: 44)
                    .background(RSTheme.glassFill, in: Circle())
            }
            .accessibilityLabel(speech.isListening ? "Stop voice input" : "Start voice input")

            TextField("Ask your coach…", text: $vm.draft, axis: .vertical)
                .font(.rsBody(15))
                .foregroundStyle(RSTheme.textPrimary)
                .lineLimit(1...4)
                .padding(.horizontal, 14).padding(.vertical, 11)
                .background(RSTheme.glassFill, in: Capsule())
                .overlay(Capsule().strokeBorder(RSTheme.glassStroke, lineWidth: 1))
                .focused($inputFocused)
                .submitLabel(.send)
                .onSubmit(send)

            Button(action: send) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(vm.canSend ? AnyShapeStyle(RSTheme.energy) : AnyShapeStyle(RSTheme.glassStroke), in: Circle())
            }
            .disabled(!vm.canSend)
            .accessibilityLabel("Send question")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .environment(\.colorScheme, .dark)
    }

    private func send() {
        if speech.isListening { speech.stop() }
        inputFocused = false
        vm.send()
        manager.recordCoachMessage()
    }

    private func toggleVoice() async {
        await speech.toggle()
    }
}
