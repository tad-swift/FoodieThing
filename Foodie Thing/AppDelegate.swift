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
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let launchStoryboard = UIStoryboard(name: "Setup", bundle: nil)
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
        var vc: UIViewController!
        
        if pref.object(forKey: "hasLaunched") == nil {
            pref.set(false, forKey: "hasLaunched")
            vc = launchStoryboard.instantiateInitialViewController()!
        } else {
            if pref.bool(forKey: "hasLaunched") == true {
                vc = loginStoryboard.instantiateInitialViewController()!
            } else {
                vc = launchStoryboard.instantiateInitialViewController()!
            }
        }
        
        if pref.object(forKey: "SwitchState") == nil {
            pref.set(true, forKey: "SwitchState")
        }
        
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        let audioSession = AVAudioSession.sharedInstance()
        
        do {try audioSession.setCategory(AVAudioSession.Category.playback)}
        catch {log.debug("Setting category to AVAudioSessionCategoryPlayback failed.")}
 
        return true
    }
    
    override init() {
        FirebaseApp.configure()
    }
    
}
