import SwiftUI

struct AnimatedWaveformView: View {
    let audioLevels: [Float]
    let isRecording: Bool
    let isPlaying: Bool
    let isPaused: Bool
    let playbackProgress: Double // 0.0 to 1.0
    
    init(audioLevels: [Float], isRecording: Bool, isPlaying: Bool = false, isPaused: Bool = false, playbackProgress: Double = 0.0) {
        self.audioLevels = audioLevels
        self.isRecording = isRecording
        self.isPlaying = isPlaying
        self.isPaused = isPaused
        self.playbackProgress = playbackProgress
    }
    
    private var configuration = WaveformConfiguration(
        barWidth: 1.0,      // Very thin lines
        barSpacing: 2.0,    // Small spacing between lines
        barColor: Color.recordingVisualizer,
        backgroundColor: Color.clear,
        maxHeight: 40.0,    // Shorter height for subtlety
        minHeight: 2.0      // Minimum bar height
    )
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                drawWaveform(context: context, size: size)
            }
        }
        .frame(height: configuration.maxHeight)
    }
    
    private func drawWaveform(context: GraphicsContext, size: CGSize) {
        let barWidth = configuration.barWidth
        let barSpacing = configuration.barSpacing
        let totalBarWidth = barWidth + barSpacing
        let availableWidth = size.width
        let maxBars = Int(availableWidth / totalBarWidth)
        
        if !isRecording && !isPlaying && !isPaused {
            // Draw flat minimal line when idle
            drawFlatLine(context: context, size: size, barsCount: maxBars)
            return
        }
        
        if isPlaying || isPaused {
            // Draw complete waveform with playback progress for both playing and paused states
            drawPlaybackWaveform(context: context, size: size, maxBars: maxBars)
            return
        }
        
        // Recording mode - build from left to right
        let samplesToShow = min(audioLevels.count, maxBars)
        let recentSamples = audioLevels.suffix(samplesToShow)
        let emptyBars = maxBars - samplesToShow
        
        // Draw empty bars first (left side)
        for i in 0..<emptyBars {
            let xPosition = CGFloat(i) * totalBarWidth
            drawBar(context: context, x: xPosition, height: configuration.minHeight, size: size, color: configuration.barColor)
        }
        
        // Draw actual audio data bars (right side)
        for (index, level) in recentSamples.enumerated() {
            let xPosition = CGFloat(emptyBars + index) * totalBarWidth
            let processedLevel = processAudioLevel(level)
            let barHeight = CGFloat(processedLevel) * configuration.maxHeight
            let finalHeight = max(barHeight, configuration.minHeight)
            
            drawBar(context: context, x: xPosition, height: finalHeight, size: size, color: configuration.barColor)
        }
    }
    
    private func drawPlaybackWaveform(context: GraphicsContext, size: CGSize, maxBars: Int) {
        let barWidth = configuration.barWidth
        let barSpacing = configuration.barSpacing
        let totalBarWidth = barWidth + barSpacing
        
        // Scale waveform data to fit available bars
        let scaledData = scaleWaveformData(audioLevels, to: maxBars)
        let progressBarIndex = Int(Double(scaledData.count) * playbackProgress)
        
        for (index, level) in scaledData.enumerated() {
            let xPosition = CGFloat(index) * totalBarWidth
            if xPosition + barWidth <= size.width {
                let processedLevel = processAudioLevel(level)
                let barHeight = CGFloat(processedLevel) * configuration.maxHeight
                let finalHeight = max(barHeight, configuration.minHeight)
                
                // Different color for played vs unplayed portions
                let color = index <= progressBarIndex ?
                    Color.pastelPurple :
                    configuration.barColor
                
                drawBar(context: context, x: xPosition, height: finalHeight, size: size, color: color)
            }
        }
    }
    
    private func scaleWaveformData(_ data: [Float], to targetCount: Int) -> [Float] {
        guard data.count > targetCount else { return data }
        
        let blockSize = data.count / targetCount
        var scaledData: [Float] = []
        
        for i in 0..<targetCount {
            let startIndex = i * blockSize
            let endIndex = min(startIndex + blockSize, data.count)
            let block = Array(data[startIndex..<endIndex])
            
            // Use RMS for better representation
            let rms = sqrt(block.map { $0 * $0 }.reduce(0, +) / Float(block.count))
            scaledData.append(rms)
        }
        
        return scaledData
    }
    
    private func drawBar(context: GraphicsContext, x: CGFloat, height: CGFloat, size: CGSize, color: Color) {
        let barRect = CGRect(
            x: x,
            y: (size.height - height) / 2,
            width: configuration.barWidth,
            height: height
        )
        
        context.fill(
            Path(barRect),
            with: .color(color)
        )
    }
    
    private func drawFlatLine(context: GraphicsContext, size: CGSize, barsCount: Int) {
        let barWidth = configuration.barWidth
        let barSpacing = configuration.barSpacing
        let totalBarWidth = barWidth + barSpacing
        
        // Draw many small flat bars across the width
        for i in 0..<barsCount {
            let xPosition = CGFloat(i) * totalBarWidth
            if xPosition + barWidth <= size.width {
                drawBar(context: context, x: xPosition, height: configuration.minHeight, size: size, color: configuration.barColor)
            }
        }
    }
    
    // Process audio level to create clean, responsive waveform
    private func processAudioLevel(_ level: Float) -> Float {
        // Simple processing - just ensure minimum visibility and smooth scaling
        let processedLevel = max(0.05, level) // Minimum height for visibility
        
        // Scale the level to make it more visually appealing
        // Use a power curve to make quiet sounds more visible
        let scaledLevel = pow(processedLevel, 0.6)
        
        return min(1.0, scaledLevel)
    }
}

struct WaveformConfiguration {
    let barWidth: CGFloat
    let barSpacing: CGFloat
    let barColor: Color
    let backgroundColor: Color
    let maxHeight: CGFloat
    let minHeight: CGFloat
}
