//
//  LoadingViewController.swift
//  MercadoLibre
//
//  Created by Daniel Cardona Rojas on 28/03/21.
//

import UIKit
import Lottie

class LoadingViewController: UIViewController {

    lazy var animatedView: AnimationView = {
        let av = AnimationView(name: "loading")
        av.translatesAutoresizingMaskIntoConstraints = false
        av.loopMode = .loop
        av.animationSpeed = 2
        return av
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(animatedView)
        view.backgroundColor = .white

        NSLayoutConstraint.activate {
            animatedView.relativeTo(view, positioned: .centered)
            animatedView.constrainedBy(.aspectRatio(1) + .constantWidth(150))
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animatedView.play()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        animatedView.stop()
    }

}
