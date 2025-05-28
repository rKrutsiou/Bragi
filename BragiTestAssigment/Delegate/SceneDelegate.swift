//
//  SceneDelegate.swift
//  BragiTestAssigment
//
//  Created by Raman Krutsiou on 27/05/2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let tabBarController = createTabBarController()
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        self.window = window
    }

    // MARK: - Private methods

    private func createTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            createMediaNavController(for: .movies, tag: 0),
            createMediaNavController(for: .tvShows, tag: 1)
        ]
        configureTabBarAppearance(for: tabBarController)
        return tabBarController
    }

    private func createMediaNavController(for mediaType: MediaType, tag: Int) -> UINavigationController {
        let viewModel = MediaListViewModel(
            networkService: NetworkService(),
            mediaType: mediaType
        )
        let vc = MediaListViewController(viewModel: viewModel)
        vc.title = mediaType.title
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.tabBarItem = UITabBarItem(
            title: mediaType.title,
            image: mediaType.tabBarImage,
            tag: tag
        )
        return navigationController
    }

    private func configureTabBarAppearance(for tabBarController: UITabBarController) {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()

        if #available(iOS 15.0, *) {
            tabBarController.tabBar.scrollEdgeAppearance = appearance
            tabBarController.tabBar.standardAppearance = appearance
        } else {
            tabBarController.tabBar.standardAppearance = appearance
        }
    }
}
