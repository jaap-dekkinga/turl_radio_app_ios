//
//  AppDelegate.swift
//  radio_app
//
//  Created on 10/14/21.
//  Copyright © 2021-2022 TuneURL Inc. All rights reserved.
//

import UIKit
import AVFoundation
import TuneURL
import MediaPlayer

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	// static
	static var shared: AppDelegate = {
		UIApplication.shared.delegate as! AppDelegate
	}()

	// public
	var window: UIWindow?
    var coordinator: MainCoordinator?

    // CarPlay
    var playableContentManager: MPPlayableContentManager?
    
	// MARK: -

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        setupTuneURLTrigger()
        
        setupRadio()
                        
        coordinator = MainCoordinator(navigationController: UINavigationController())
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = coordinator?.navigationController
        window?.makeKeyAndVisible()
        
        coordinator?.start()
        
        return true
    }
        
	func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
	}
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
        UIApplication.shared.endReceivingRemoteControlEvents()
        
    }
    
	// MARK: - Private

	private func setupTuneURLTrigger() {
		guard let url = Bundle.main.url(forResource: "Trigger-Sound", withExtension: "wav") else {
			return
		}

		Detector.setTrigger(url)
	}
    
    private func setupRadio() {
        // FRadioPlayer config
        FRadioPlayer.shared.isAutoPlay = true
        FRadioPlayer.shared.enableArtwork = true
        FRadioPlayer.shared.artworkAPI = iTunesAPI(artworkSize: 600)
        
        // AudioSession & RemotePlay
        activateAudioSession()
        setupRemoteCommandCenter()
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        // Make status bar white
        UINavigationBar.appearance().barStyle = .black
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().prefersLargeTitles = true
                
        // `CarPlay` is defined only in SwiftRadio-CarPlay target:
        // Build Settings > Swift Compiler - Custom Flags
        #if CarPlay
        setupCarPlay()
        #endif
        
    }
    
    // MARK: - Remote Controls
    
    private func setupRemoteCommandCenter() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { event in
            FRadioPlayer.shared.play()
            return .success
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { event in
            FRadioPlayer.shared.pause()
            return .success
        }
        
        // Add handler for Toggle Command
        commandCenter.togglePlayPauseCommand.addTarget { event in
            FRadioPlayer.shared.togglePlaying()
            return .success
        }
        
        // Add handler for Next Command
        commandCenter.nextTrackCommand.addTarget { event in
            StationsManager.shared.setNext()
            return .success
        }
        
        // Add handler for Previous Command
        commandCenter.previousTrackCommand.addTarget { event in
            StationsManager.shared.setPrevious()
            return .success
        }
    }
    
    // MARK: - Activate Audio Session
    
    private func activateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
            if Config.debugLog {
                print("audioSession could not be activated: \(error.localizedDescription)")
            }
        }
    }
}
