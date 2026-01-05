//
//  ViewController.swift
//  ARC_Examples
//
//  Created by Menkov Dmitriy on 03.01.2026.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        runDemos()
    }

    // MARK: - Main Demo Runner

    func runDemos() {
        Video01_MinimalDemo.runForVideo()
    }
}
