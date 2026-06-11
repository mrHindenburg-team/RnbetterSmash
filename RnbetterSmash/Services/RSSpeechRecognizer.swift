import Foundation
import Speech
import AVFoundation
import Observation

/// Fully offline speech-to-text for talking to the AI coach.
///
/// Forces on-device recognition (`requiresOnDeviceRecognition = true`) so no
/// audio ever leaves the device. Degrades gracefully when permission is denied,
/// on-device recognition is unsupported, or input is empty/noisy.
@Observable
@MainActor
final class RSSpeechRecognizer {

    private enum RSSpeechError: Error {
        case noAudioInput
    }

    enum State: Equatable {
        case idle
        case listening
        case unavailable(String)
        case denied
    }

    private(set) var state: State = .idle
    private(set) var transcript: String = ""
    var isListening: Bool { state == .listening }

    @ObservationIgnored private let recognizer = SFSpeechRecognizer()
    @ObservationIgnored private var request: SFSpeechAudioBufferRecognitionRequest?
    @ObservationIgnored private var task: SFSpeechRecognitionTask?
    @ObservationIgnored private let audioEngine = AVAudioEngine()

    /// Whether the device can do offline recognition at all.
    var isSupported: Bool {
        recognizer?.supportsOnDeviceRecognition ?? false
    }

    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    /// Microphone access is a separate permission from speech recognition;
    /// starting the engine without it crashes with an invalid input format.
    private func requestMicAuthorization() async -> Bool {
        await AVAudioApplication.requestRecordPermission()
    }

    func toggle() async {
        if isListening { stop() } else { await start() }
    }

    func start() async {
        guard !isListening else { return }
        transcript = ""

        guard let recognizer, recognizer.isAvailable else {
            state = .unavailable("Speech recognition isn't available right now.")
            return
        }
        guard recognizer.supportsOnDeviceRecognition else {
            state = .unavailable("On-device dictation isn't supported on this device.")
            return
        }
        guard await requestAuthorization() else {
            state = .denied
            return
        }
        guard await requestMicAuthorization() else {
            state = .denied
            return
        }

        do {
            try configureSession()
            try beginRecognition(with: recognizer)
            state = .listening
        } catch {
            state = .unavailable("Couldn't start the microphone.")
            cleanUp()
        }
    }

    func stop() {
        cleanUp()
        state = .idle
    }

    // MARK: - Private

    private func configureSession() throws {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try session.setActive(true, options: .notifyOthersOnDeactivation)
        #endif
    }

    private func beginRecognition(with recognizer: SFSpeechRecognizer) throws {
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.requiresOnDeviceRecognition = true   // hard offline requirement
        self.request = request

        let input = audioEngine.inputNode
        let format = input.outputFormat(forBus: 0)
        // installTap raises an uncatchable NSException on a zero-rate format
        // (no mic access, or no input route on this hardware).
        guard format.sampleRate > 0, format.channelCount > 0 else {
            throw RSSpeechError.noAudioInput
        }
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak request] buffer, _ in
            request?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        task = recognizer.recognitionTask(with: request) { [weak self] result, error in
            // Recognition callbacks arrive off the main actor; hop back.
            Task { @MainActor [weak self] in
                guard let self else { return }
                if let result {
                    self.transcript = result.bestTranscription.formattedString
                    if result.isFinal { self.stop() }
                }
                if error != nil {
                    // Noisy environment / no speech detected: keep whatever we got.
                    self.stop()
                }
            }
        }
    }

    private func cleanUp() {
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        // Always remove the tap (safe no-op when none is installed): if
        // engine start failed after installTap, a leftover tap would make
        // the next installTap raise an uncatchable NSException.
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        request = nil
        task = nil
        #if os(iOS)
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        #endif
    }
}
