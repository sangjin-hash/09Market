import UIKit

final class AppRouter {
    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let vc = ViewController()
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }
}
