//
//  AppDelegate.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 11/1/20.
//

import UIKit
import Firebase
import AVFoundation
import GoogleSignIn


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self

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
    
    func changeRootViewController(_ vc: UIViewController, animated: Bool = false) {
        guard let window = self.window else {
            return
        }
        // change the root view controller to your specific view controller
        window.rootViewController = vc
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
    -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            return
        }

        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if error != nil {
                return
            }
            db.collection("users").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    log.debug("Error getting documents: \(err as NSObject)")
                } else {
                    let docRef = db.collection("users").document(Auth.auth().currentUser!.uid)
                    docRef.getDocument { (document, _) in

                        if let userObj = document.flatMap({
                            $0.data().flatMap({ (data) in
                                return User(dictionary: data)
                            })
                        }) {
                            myUser = userObj
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let mainVC = (storyboard.instantiateViewController(withIdentifier: "tab"))
                            self.changeRootViewController(mainVC)
                        } else {
                            let storyboard = UIStoryboard(name: "Login", bundle: nil)
                            let mainVC = (storyboard.instantiateViewController(withIdentifier: "username"))
                            let navController = UINavigationController(rootViewController: mainVC)
                            navController.modalPresentationStyle = .fullScreen
                            navController.isNavigationBarHidden = true
                            self.changeRootViewController(navController)
                        }

                    }
                }
            }
        }
    }
    
}
