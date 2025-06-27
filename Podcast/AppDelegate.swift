//
//  AppDelegate.swift
//  Podcast
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

	static var documentsURL: URL = {
		// get the documents folder
		guard let url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
			return URL(fileURLWithPath: NSTemporaryDirectory())
		}
		return url
	}()

	static var uniqueID: String = {
		// get the uuid
		if let uuid = UserDefaults.standard.string(forKey: "Unique ID") {
			return uuid
		}
		// create a new uuid
		let uuid = UUID().uuidString
		UserDefaults.standard.set(uuid, forKey: "Unique ID")
		return uuid
	}()

	// public
	var window: UIWindow?
    var navigationController: UINavigationController?
    var coordinator: MainCoordinator?

    // CarPlay
    var playableContentManager: MPPlayableContentManager?
    
	// MARK: -

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        setupTuneURLTrigger()
        setupAppearance()
        
        setupRadio()
                        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootVC = storyboard.instantiateInitialViewController()

        let nav = UINavigationController(rootViewController: rootVC ?? UIViewController())
        nav.isNavigationBarHidden = true
        navigationController = nav

        coordinator = MainCoordinator(navigationController: nav)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }
        
	func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
		API.shared.clearCache()
	}
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
        UIApplication.shared.endReceivingRemoteControlEvents()
        
    }
    
	// MARK: - Private

	private func setupAppearance() {
		// setup the navigation bar appearance
		UINavigationBar.appearance().prefersLargeTitles = true
		// setup the tab bar appearance
		let tabBarAppearance = UITabBarAppearance()
		tabBarAppearance.configureWithTransparentBackground()
		tabBarAppearance.backgroundColor = .clear
		tabBarAppearance.backgroundEffect = nil
		UITabBar.appearance().standardAppearance = tabBarAppearance
		if #available(iOS 15.0, *) {
			UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
		}
	}

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
