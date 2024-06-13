//
//  ViewController.swift
//  GMonitor
//
//  Created by Theefamily on 4/7/24.
//  Copyright © 2024 Theefamily. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation

class ViewController: UIViewController {
    let motionManager = CMMotionManager()
    var player: AVAudioPlayer?
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var sensitivitySlider: UISlider!
    @IBOutlet weak var sliderValueLabel: UILabel!
    @IBOutlet weak var soundTestButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var accelerometerValueLabel: UILabel! // Add accelerometer value label

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Setup motion manager
        motionManager.accelerometerUpdateInterval = 0.1 // Update interval in seconds
        
        // Set up slider range
        sensitivitySlider.minimumValue = 0.0
        sensitivitySlider.maximumValue = 5.0
        sensitivitySlider.value = 2.0 // Initial value
        
        // Set initial slider value label
        sliderValueLabel.text = String(format: "%.1f", sensitivitySlider.value)
        
        // Connect slider's value changed event manually
        sensitivitySlider.addTarget(self, action: #selector(sensitivitySliderValueChanged(_:)), for: .valueChanged)
        
        // Connect sound test button action
        soundTestButton.addTarget(self, action: #selector(soundTestButtonTapped(_:)), for: .touchUpInside)
        
        // Prevent button from flashing
        soundTestButton.showsTouchWhenHighlighted = false
        
        // Start accelerometer updates
        startAccelerometerUpdates()
    }

    @IBAction func startButtonTapped(_ sender: UIButton) {
        spinner.startAnimating() // Start the spinner
        startAccelerometerUpdates()
    }

    @IBAction func stopButtonTapped(_ sender: UIButton) {
        spinner.stopAnimating() // Stop the spinner
        motionManager.stopAccelerometerUpdates()
    }

    @IBAction func sensitivitySliderValueChanged(_ sender: UISlider) {
        // Update the label with the new slider value
        sliderValueLabel.text = String(format: "%.1f", sender.value)
    }

    @IBAction func soundTestButtonTapped(_ sender: UIButton) {
        guard let soundURL = Bundle.main.url(forResource: "honk", withExtension: "mp3") else {
            print("Sound file not found")
            return
        }

        do {
            // Check if player is already playing
            if let player = player, player.isPlaying {
                player.stop()
            }
            
            // Play the sound
            player = try AVAudioPlayer(contentsOf: soundURL)
            player?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }

    func startAccelerometerUpdates() {
        guard motionManager.isAccelerometerAvailable else {
            print("Accelerometer is not available")
            return
        }
        
        motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (data, error) in
            if let acceleration = data?.acceleration, let sliderValue = self.sensitivitySlider?.value {
                let gForce = sqrt(pow(acceleration.x, 2) + pow(acceleration.y, 2) + pow(acceleration.z, 2))
                
                // Update accelerometer value label
                self.accelerometerValueLabel.text = String(format: "Accelerometer Value: %.2f g", gForce)

                if Float(gForce) >= sliderValue {
                    self.playHonkSound()
                }
            } else {
                print("Slider value is nil")
            }
        }
    }

    func playHonkSound() {
        guard let soundURL = Bundle.main.url(forResource: "honk", withExtension: "mp3") else {
            print("Sound file not found")
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: soundURL)
            player?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
}
