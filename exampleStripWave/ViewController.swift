//
//  ViewController.swift
//  exampleStripWave
//
//  Created by Sagar Das on 05/07/23.
//


import UIKit
import AVFoundation
import CoreMedia



class ViewController: UIViewController {
    
    //MARK: - For 1st view for dark mode
    @IBOutlet weak var waveFormView: StripedWaveformView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    //MARK: - For 2nd view for light mode
    
    @IBOutlet weak var waveFormView2: StripedWaveformView!
    @IBOutlet weak var bgView2: UIView!
    @IBOutlet weak var sliderView2: UIView!
    @IBOutlet weak var btnView: UIView!
    @IBOutlet weak var leadingConstraintView2: NSLayoutConstraint!
    @IBOutlet weak var slider2: UISlider!
    
    var totalAudioDuration: CGFloat = 0.0
    
    
    var audioPlayer: AVAudioPlayer?
    var timer: Timer?
    var isSeeking = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        let audioURL = Bundle.main.url(forResource: "audio2", withExtension: "mp3")

        
        let barColor = UIColor.white
        let barSpacing: CGFloat = 4.0
        let barWidth: CGFloat = 4.0
        
        generateWaveform(from: audioURL!) { [weak self] waveformValues in
            DispatchQueue.main.async {
                self?.waveFormView.barColor = barColor
                self?.waveFormView.barSpacing = barSpacing
                self?.waveFormView.barWidth = barWidth
                self?.waveFormView.waveformValues = waveformValues
                self?.waveFormView.setNeedsDisplay()
            }
        }
        slider.isUserInteractionEnabled = true
        addSliderGestures()
        backView.layer.cornerRadius = 10
        backView.clipsToBounds = true
        waveFormView.layer.cornerRadius = 10
        waveFormView.clipsToBounds = true
        sliderView.layer.cornerRadius = 10
        sliderView.clipsToBounds = true
        
        let audioURL2 = Bundle.main.url(forResource: "audio1", withExtension: "mp3")
        
        //MARK: - Generating waveform for view 2
        generateWaveform(from: audioURL2!) { [weak self] waveformValues in
            DispatchQueue.main.async {
                self?.waveFormView2.barColor = barColor
                self?.waveFormView2.barSpacing = barSpacing
                self?.waveFormView2.barWidth = barWidth
                self?.waveFormView2.waveformValues = waveformValues
                self?.waveFormView2.setNeedsDisplay()
            }
        }
        
        //MARK: - Graident color
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bgView2.bounds
        gradientLayer.colors = [UIColor(red: 0.9, green: 0.36, blue: 0, alpha: 1).cgColor, UIColor(red: 0.98, green: 0.83, blue: 0.14, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        bgView2.layer.insertSublayer(gradientLayer, at: 0)
        
        //for view
        let gradientLayer1 = CAGradientLayer()
        gradientLayer1.frame = sliderView2.bounds
        gradientLayer1.colors = [UIColor(red: 0.9, green: 0.36, blue: 0, alpha: 0.5).cgColor, UIColor(red: 0.98, green: 0.83, blue: 0.14, alpha: 0.5).cgColor]
        gradientLayer1.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer1.endPoint = CGPoint(x: 1, y: 0)
        
        sliderView2.layer.insertSublayer(gradientLayer1, at: 0)
//        sliderView2.layer.insertSublayer(gradientLayer, at: 0)
        bgView2.layer.cornerRadius = 10
        bgView2.clipsToBounds = true
        addSliderGesturesView2()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioPlayer?.stop()
    }

    @objc func updateSlider() {
        if !isSeeking {
            
            slider.value = Float(audioPlayer?.currentTime ?? 0)
            // before logic
            let sliderValue = CGFloat(slider.value)
            let scaleFactor: CGFloat = 2.83 // Adjust the scale factor as needed

            let calculatingSliderMovement = ((283 / totalAudioDuration) * sliderValue)
            leadingConstraint.constant = calculatingSliderMovement
            view.layoutIfNeeded()
        }
    }
    
    @IBAction func sliderValue(_ sender: UISlider){
        audioPlayer?.currentTime = TimeInterval(sender.value)
            
    }
    
    
    @IBAction func audioPlayBtn(_ sender: UIButton) {
        
        guard let audioPath = Bundle.main.path(forResource: "audio2", ofType: "mp3") else {
               return
           }
           
           do {
               if let player = audioPlayer {
                   if player.isPlaying {
                       player.pause() // Pause the audio player
                       timer?.invalidate() // Stop the timer
                       let playImage = UIImage(systemName: "play.fill") // System icon for play
                       slider.maximumValue = Float(audioPlayer?.duration ?? 0)
                       sender.setImage(playImage, for: .normal)
                   } else {
                       player.play() // Resume playing the audio
                       timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
                       let pauseImage = UIImage(systemName: "pause.fill") // System icon for pause
                       sender.setImage(pauseImage, for: .normal)
                   }
               } else {
                   audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath))
                   audioPlayer?.play()
                   slider.maximumValue = Float(audioPlayer?.duration ?? 0)
                   timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
                   let pauseImage = UIImage(systemName: "pause.fill") // System icon for pause
                   sender.setImage(pauseImage, for: .normal)
                   // storing total duration
                   self.totalAudioDuration = CGFloat(slider.maximumValue)
               }
           } catch {
               print("Failed to load audio file")
           }
    }
    
    
    
    func addSliderGestures() {
        let sliderTapGesture = UITapGestureRecognizer(target: self, action: #selector(sliderTapped(_:)))
        slider.addGestureRecognizer(sliderTapGesture)

        let sliderPanGesture = UIPanGestureRecognizer(target: self, action: #selector(sliderPanned(_:)))
        slider.addGestureRecognizer(sliderPanGesture)
    }
    
    private func extractAudioSamples(from fileURL: URL) -> [CGFloat]? {
        guard let audioFile = try? AVAudioFile(forReading: fileURL) else {
            print("Failed to read audio file")
            return nil
        }

        guard let audioFormat = audioFile.processingFormat as? AVAudioFormat,
              let audioPCMBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: AVAudioFrameCount(audioFile.length)) else {
            print("Failed to create audio buffer")
            return nil
        }

        do {
            try audioFile.read(into: audioPCMBuffer)

            let floatChannelData = audioPCMBuffer.floatChannelData!
            let channelData = UnsafeBufferPointer(start: floatChannelData[0], count: Int(audioPCMBuffer.frameLength))

            let samples = Array(channelData).map { CGFloat($0) }
            return samples
        } catch {
            print("Failed to read audio buffer")
            return nil
        }
    }
    
    @objc func sliderTapped(_ gesture: UITapGestureRecognizer) {
        let pointTapped = gesture.location(in: slider)
        let positionOfSlider = slider.frame.origin
        let widthOfSlider = slider.frame.size.width

        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(slider.maximumValue) / widthOfSlider)
        slider.setValue(Float(newValue), animated: true)
        audioPlayer?.currentTime = TimeInterval(slider.value)

    }

    @objc func sliderPanned(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: slider)
        
        switch gesture.state {
        case .began:
            isSeeking = true
        case .changed:
            var newValue = slider.value + Float(translation.x / 100)
            newValue = max(0, min(slider.maximumValue, newValue))
            slider.setValue(newValue, animated: true)
            audioPlayer?.currentTime = TimeInterval(slider.value)
        case .ended:
            isSeeking = false
        default:
            break
        }
        
        gesture.setTranslation(CGPoint.zero, in: slider)
    }
    
    //MARK: - Second View
    
    @IBAction func playBtnTapped(_ sender: UIButton) {
        guard let audioPath = Bundle.main.path(forResource: "audio1", ofType: "mp3") else {
               return
           }
           
           do {
               if let player = audioPlayer {
                   if player.isPlaying {
                       player.pause() // Pause the audio player
                       timer?.invalidate() // Stop the timer
                       let playImage = UIImage(systemName: "play.fill") // System icon for play
                       sender.setImage(playImage, for: .normal)
                   } else {
                       player.play() // Resume playing the audio
                       timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateSliderView2), userInfo: nil, repeats: true)
                       let pauseImage = UIImage(systemName: "pause.fill") // System icon for pause
                       sender.setImage(pauseImage, for: .normal)
                   }
               } else {
                   audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath))
                   audioPlayer?.play()
                   slider.maximumValue = Float(audioPlayer?.duration ?? 0)
                   timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateSliderView2), userInfo: nil, repeats: true)
                   let pauseImage = UIImage(systemName: "pause.fill") // System icon for pause
                   self.totalAudioDuration = CGFloat(slider.maximumValue)
                   sender.setImage(pauseImage, for: .normal)
               }
           } catch {
               print("Failed to load audio file")
           }
    }
    
    @objc func updateSliderView2() {
        if !isSeeking {
            
            slider.value = Float(audioPlayer?.currentTime ?? 0)
            
            let sliderValue = CGFloat(slider.value)
            let calculatingSliderMovement = ((283 / totalAudioDuration) * sliderValue)
            leadingConstraintView2.constant = calculatingSliderMovement
            view.layoutIfNeeded()
            
        }
    }
    
    
    @IBAction func slider2Change(_ sender: UISlider) {
        audioPlayer?.currentTime = TimeInterval(sender.value)

        
    }
    
    func addSliderGesturesView2() {
        let sliderTapGesture = UITapGestureRecognizer(target: self, action: #selector(sliderTappedView2(_:)))
        slider.addGestureRecognizer(sliderTapGesture)

        let sliderPanGesture = UIPanGestureRecognizer(target: self, action: #selector(sliderPannedView2(_:)))
        slider.addGestureRecognizer(sliderPanGesture)
    }
    
    @objc func sliderTappedView2(_ gesture: UITapGestureRecognizer) {
        let pointTapped = gesture.location(in: slider)
        let positionOfSlider = slider.frame.origin
        let widthOfSlider = slider.frame.size.width

        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(slider.maximumValue) / widthOfSlider)
        slider.setValue(Float(newValue), animated: true)
        audioPlayer?.currentTime = TimeInterval(slider.value)
 
    }

    @objc func sliderPannedView2(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: slider)
        
        switch gesture.state {
        case .began:
            isSeeking = true
        case .changed:
            var newValue = slider.value + Float(translation.x / 100)
            newValue = max(0, min(slider.maximumValue, newValue))
            slider.setValue(newValue, animated: true)
            audioPlayer?.currentTime = TimeInterval(slider.value)
        case .ended:
            isSeeking = false
        default:
            break
        }
        
        gesture.setTranslation(CGPoint.zero, in: slider)
    }
    
    
    
    
    //MARK: -Generating wave
    private func generateWaveform(from audioURL: URL, completion: @escaping ([CGFloat]) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                let asset = AVURLAsset(url: audioURL)
                let audioTrack = asset.tracks(withMediaType: .audio).first
                
                let reader = try AVAssetReader(asset: asset)
                let outputSettings: [String: Any] = [
                    AVFormatIDKey: kAudioFormatLinearPCM,
                    AVLinearPCMIsFloatKey: true,
                    AVLinearPCMBitDepthKey: 32,
                    AVLinearPCMIsBigEndianKey: false,
                    AVLinearPCMIsNonInterleaved: false
                ]
                let trackOutput = AVAssetReaderTrackOutput(track: audioTrack!, outputSettings: outputSettings)
                reader.add(trackOutput)
                reader.startReading()
                
                var waveformValues: [CGFloat] = []
                while let sampleBuffer = trackOutput.copyNextSampleBuffer() {
                    guard let buffer = CMSampleBufferGetDataBuffer(sampleBuffer) else { continue }
                    let length = CMBlockBufferGetDataLength(buffer)
                    let sampleBytes = UnsafeMutablePointer<Int16>.allocate(capacity: length)
                    CMBlockBufferCopyDataBytes(buffer, atOffset: 0, dataLength: length, destination: UnsafeMutableRawPointer(sampleBytes))
                    
                    let sampleCount = length / MemoryLayout<Int16>.size
                    var totalAmplitude: CGFloat = 0.0
                    for i in 0..<sampleCount {
                        let amplitude = CGFloat(sampleBytes[i]) / CGFloat(Int16.max)
                        totalAmplitude += abs(amplitude)
                    }
                    let averageAmplitude = totalAmplitude / CGFloat(sampleCount)
                    waveformValues.append(averageAmplitude)
                    
                    CMSampleBufferInvalidate(sampleBuffer)
                }
                
                completion(waveformValues)
            } catch {
                print("Failed to generate waveform: \(error)")
            }
        }
    }
}

//MARK: - StripedWaveformView
class StripedWaveformView: UIView {
    
    var barColor: UIColor = .blue
    var barSpacing: CGFloat = 0.0
    var barWidth: CGFloat = 0.0
    var waveformValues: [CGFloat] = []
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        var xPosition: CGFloat = 0.0
        let centerY = rect.height / 2
        
        for value in waveformValues {
            let barHeight = (value * rect.height)/1.5
            let barRect = CGRect(x: xPosition, y: centerY - barHeight / 2, width: barWidth, height: barHeight)
            context.setFillColor(barColor.cgColor)
            context.fill(barRect)
            
            xPosition += barWidth + barSpacing
        }
    }
}
