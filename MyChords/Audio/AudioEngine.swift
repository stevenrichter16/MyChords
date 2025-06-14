import AVFoundation
import Observation

@Observable
final class AudioEngine {
    private let audioEngine = AVAudioEngine()
    private var playerNodes: [AVAudioPlayerNode] = []
    private let mixer: AVAudioMixerNode
    
    var isPlaying = false
    
    init() {
        self.mixer = audioEngine.mainMixerNode
        setupEngine()
    }
    
    private func setupEngine() {
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2)!
        
        for _ in 0..<4 {
            let playerNode = AVAudioPlayerNode()
            audioEngine.attach(playerNode)
            audioEngine.connect(playerNode, to: mixer, format: format)
            playerNodes.append(playerNode)
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    func playChord(_ chord: Chord, duration: TimeInterval = 3.0) {
        stopCurrentPlayback()
        isPlaying = true
        
        var completedBuffers = 0
        let totalBuffers = min(chord.notes.count, playerNodes.count)
        
        // First, schedule all buffers
        for (index, note) in chord.notes.enumerated() where index < playerNodes.count {
            let buffer = createToneBuffer(frequency: note.frequency, duration: duration)
            playerNodes[index].scheduleBuffer(buffer) {
                DispatchQueue.main.async {
                    completedBuffers += 1
                    if completedBuffers >= totalBuffers {
                        self.isPlaying = false
                    }
                }
            }
        }
        
        // Then, start all players at the same time
        for (index, _) in chord.notes.enumerated() where index < playerNodes.count {
            playerNodes[index].play()
        }
    }
    
    func stopCurrentPlayback() {
        playerNodes.forEach { $0.stop() }
        isPlaying = false
    }
    
    
    private func createToneBuffer(frequency: Double, duration: TimeInterval) -> AVAudioPCMBuffer {
        let sampleRate = 44100.0
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        
        // Reduce amplitude to prevent clipping when multiple notes play
        let amplitude: Float = 0.2
        let twoPi = 2 * Float.pi
        
        // Longer fade times for smoother transitions
        let fadeInTime = 0.05  // 50ms fade in
        let fadeOutTime = 0.1  // 100ms fade out
        let fadeInFrames = Int(sampleRate * fadeInTime)
        let fadeOutFrames = Int(sampleRate * fadeOutTime)
        
        for channel in 0..<2 {
            let data = buffer.floatChannelData![channel]
            
            for frame in 0..<Int(frameCount) {
                let phase = Float(frame) * twoPi * Float(frequency) / Float(sampleRate)
                
                // Create a warmer tone by adding a subtle second harmonic
                let fundamental = sin(phase)
                let secondHarmonic = sin(phase * 2) * 0.15
                
                var sample = amplitude * (fundamental + secondHarmonic)
                
                // Apply envelope
                if frame < fadeInFrames {
                    // Smooth fade in
                    let factor = Float(frame) / Float(fadeInFrames)
                    sample *= factor * factor  // Quadratic fade for smoother attack
                } else if frame > Int(frameCount) - fadeOutFrames {
                    // Smooth fade out
                    let remainingFrames = Int(frameCount) - frame
                    let factor = Float(remainingFrames) / Float(fadeOutFrames)
                    sample *= factor * factor  // Quadratic fade for smoother release
                }
                
                data[frame] = sample
            }
        }
        
        return buffer
    }
}
