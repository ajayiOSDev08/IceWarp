//
//  UIViewController-Extension.swift
//  IceWarp
//
//  Created by Ajay on 05/12/24.
//


import UIKit

extension UIViewController {
    // MARK: - AppDelegate, SceneDelegate and window
    // Access AppDelegate for iOS 12
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    // Access SceneDelegate for iOS 13+
    var sceneDelegate: SceneDelegate? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let delegate = windowScene.delegate as? SceneDelegate else { return nil }
        return delegate
    }
    
    // Access the window for iOS 12 (AppDelegate) and iOS 13+ (SceneDelegate)
    var window: UIWindow? {
        if #available(iOS 13, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let delegate = windowScene.delegate as? SceneDelegate else { return nil }
            return delegate.window
        }
        
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        return delegate.window
    }
    
    // MARK: - Loader view and methods
    private static var loaderView: UIView?
    
    func showLoader() {
        let loaderView = UIView(frame: self.view.bounds)
        loaderView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = loaderView.center
        activityIndicator.startAnimating()
        
        loaderView.addSubview(activityIndicator)
        self.view.addSubview(loaderView)
        
        Self.loaderView = loaderView
    }
    
    func hideLoader() {
        Self.loaderView?.removeFromSuperview()
        Self.loaderView = nil
    }
    
    // MARK: - Navigation Methods, Identifiers and Storyboard
    private static let channelIdentifier = "ChannelVC"
    private static let loginIdentifier = "LoginVC"
    private static let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    // Navigates to the Channel List View Controller
    func navigateToChannelListVC() {
        guard let channelListVC = Self.storyboard.instantiateViewController(withIdentifier: Self.channelIdentifier) as? ChannelViewController else {
            print("Error: Unable to instantiate ChannelViewController")
            return
        }
        navigationController?.pushViewController(channelListVC, animated: true)
    }
    
    // Sets the Login View Controller as the Root View Controller
    func setRootViewController() {
        guard let loginVC = Self.storyboard.instantiateViewController(withIdentifier: Self.loginIdentifier) as? LoginViewController else {
            print("Error: Unable to instantiate LoginViewController")
            return
        }
        let navController = UINavigationController(rootViewController: loginVC)
        
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
    }
}
