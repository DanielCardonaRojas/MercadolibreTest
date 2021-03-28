//
//  AppDelegate.swift
//  MercadoLibre
//
//  Created by Daniel Cardona Rojas on 26/03/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    private func setTheme() {
        let navigationProxy = UINavigationBar.appearance()
        navigationProxy.backgroundColor = .mercadolibreYellow
        navigationProxy.barTintColor = .mercadolibreYellow
        navigationProxy.tintColor = .darkText
        UILabel.appearance().textColor = .defaultTextColor

    }

    private lazy var statusBar: UIView = UIView()

    func setStatusBar() {
        let window = UIApplication.shared.windows.first!
        let statusBarFrame = window.windowScene?.statusBarManager?.statusBarFrame
        statusBar.removeFromSuperview()

        if let frame = statusBarFrame {
            statusBar.translatesAutoresizingMaskIntoConstraints = false
            statusBar.backgroundColor = UIDevice.current.orientation.isLandscape ? .clear : .mercadolibreYellow
            statusBar.isHidden = UIDevice.current.orientation.isLandscape
            window.addSubview(statusBar)
            NSLayoutConstraint.activate {
                statusBar.relativeTo(window, positioned: .top() + .centerX() + .width())
                statusBar.constrainedBy(.constantHeight(frame.height))
            }

        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setTheme()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}
