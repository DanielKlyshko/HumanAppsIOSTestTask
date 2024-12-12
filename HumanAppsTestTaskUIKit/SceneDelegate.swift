import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: scene)
        
        let tabBarController = UITabBarController()
        
        let firstViewController = ImageEditorVC()
        firstViewController.tabBarItem = UITabBarItem(title: "Crop Photo", image: UIImage(systemName: "crop"), tag: 0)
        
        let secondViewController = SettingsVC()
        secondViewController.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), tag: 1)
        
        tabBarController.viewControllers = [firstViewController, secondViewController]
        
        window.rootViewController = tabBarController
        
        self.window = window
        window.makeKeyAndVisible()
    }
}

