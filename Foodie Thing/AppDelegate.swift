//
//  AppDelegate.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 11/1/20.
//

import UIKit
import Firebase
import AVFoundation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let defaults = UserDefaults.standard
        window = UIWindow(frame: UIScreen.main.bounds)
        let launchStoryboard = UIStoryboard(name: "Setup", bundle: nil)
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
        var vc: UIViewController!
        
        if defaults.object(forKey: "hasLaunched") == nil {
            defaults.set(false, forKey: "hasLaunched")
            vc = launchStoryboard.instantiateInitialViewController()!
        } else {
            if defaults.bool(forKey: "hasLaunched") == true {
                vc = loginStoryboard.instantiateInitialViewController()!
            } else {
                vc = launchStoryboard.instantiateInitialViewController()!
            }
        }
        
        if defaults.object(forKey: "SwitchState") == nil {
            defaults.set(true, forKey: "SwitchState")
        }
        
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {try audioSession.setCategory(AVAudioSession.Category.playback)}
        catch {print("Setting category to AVAudioSessionCategoryPlayback failed.")}
 
        return true
    }
    
    override init() {
        FirebaseApp.configure()
    }
    
}
