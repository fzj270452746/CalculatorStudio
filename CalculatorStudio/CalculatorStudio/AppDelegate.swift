
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let patina = AppPatina()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        patina.brew()
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

private struct AppPatina {

    func brew() {
        let navInk = UINavigationBarAppearance()
        navInk.configureWithTransparentBackground()
        navInk.backgroundColor = .clear
        navInk.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        navInk.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]

        UINavigationBar.appearance().standardAppearance = navInk
        UINavigationBar.appearance().scrollEdgeAppearance = navInk
        UINavigationBar.appearance().tintColor = .white
    }
}
