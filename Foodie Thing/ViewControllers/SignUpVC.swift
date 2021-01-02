//
//  SignUpViewController.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 5/18/20.
//  Copyright © 2020 Tadreik Campbell. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import AuthenticationServices
import CryptoKit
import GoogleSignIn


final class SignUpViewController: UIViewController {
    
    @IBOutlet weak var signupLabel: UILabel!
    @IBOutlet weak var policyLabel: ActiveLabel!
    @IBOutlet weak var signinBtn: ASAuthorizationAppleIDButton!
    @IBOutlet weak var googleBtn: UIButton!

    fileprivate var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signinBtn.addTarget(self, action: #selector(startSignInWithAppleFlow), for: .touchUpInside)
        let privacyPolicy = ActiveType.custom(pattern: "\\sPrivacy\\sPolicy\\b")
        policyLabel.enabledTypes = [privacyPolicy]
        policyLabel.text = "By signing up, you agree to our Privacy Policy."
        policyLabel.customColor[privacyPolicy] = UIColor.cyan
        policyLabel.customSelectedColor[privacyPolicy] = UIColor.systemGray5
        policyLabel.handleCustomTap(for: privacyPolicy) { element in
            self.openUrl(link: "https://tadreik.com/ftprivacy")
        }
        signinBtn.layer.masksToBounds = true
        signinBtn.layer.cornerRadius = 8
        googleBtn.layer.cornerRadius = 8
        googleBtn.imageView?.contentMode = .scaleAspectFit
        GIDSignIn.sharedInstance()?.presentingViewController = self
        googleBtn.isHidden = true
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }

    @IBAction func googleBtnTapped(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }

}

extension SignUpViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    @objc func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                log.debug("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                log.debug("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if error != nil {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    log.debug("\(error! as NSObject)")
                    self.newAlert(title: "Sign in failed", body: "\(error!)")
                    return
                } else {
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
                                    (UIApplication.shared.delegate as? AppDelegate)?.changeRootViewController(mainVC)
                                } else {
                                    myUser.docID = authResult?.user.uid
                                    let storyboard = UIStoryboard(name: "Login", bundle: nil)
                                    let mainVC = (storyboard.instantiateViewController(withIdentifier: "username"))
                                    let navController = UINavigationController(rootViewController: mainVC)
                                    navController.modalPresentationStyle = .fullScreen
                                    navController.isNavigationBarHidden = true
                                    (UIApplication.shared.delegate as? AppDelegate)?.changeRootViewController(navController)
                                }
                            }
                        }
                    }
                }
                
                
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        newAlert(title: "Sign in failed", body: "\(error)")
        log.debug("Sign in with Apple errored: \(error as NSObject)")
    }
}
