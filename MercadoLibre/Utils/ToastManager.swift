//
//  ToastManager.swift
//  MercadoLibre
//
//  Created by Daniel Cardona Rojas on 27/03/21.
//

import UIKit

public protocol ToastPresentable {
    associatedtype ToastView: UIView
    func convertToView() -> ToastView
    var duration: TimeInterval { get }
    var position: ToastPosition { get }
}

// Default implementations
extension ToastPresentable {
    public var duration: TimeInterval {
        3.0
    }

    public var position: ToastPosition {
        .fromBottom(padding: 20)
    }
}

/// Indicates positioning of toast relative to the presenting window
public struct ToastPosition {
    public enum Edge {
        case top, bottom
    }

    let horizontalPadding: CGFloat

    let edge: Edge
    var height: CGFloat = 80
    var edgeOffset: CGFloat = 30

    func startingY(windowHeight: CGFloat) -> CGFloat {
        edge == .bottom ? windowHeight + height : -height
    }

    func targetY(forPresentation: Bool, windowHeight: CGFloat) -> CGFloat {
        switch (edge, forPresentation) {
        case (.top, true):
            return edgeOffset
        case (.top, false):
            return -(edgeOffset + height)
        case (.bottom, true):
            return windowHeight - (edgeOffset + height)
        case (.bottom, false):
            return windowHeight
        }
    }

    private init(reference: Edge, horizontalPadding: CGFloat, height: CGFloat?) {
        self.horizontalPadding = horizontalPadding
        edge = reference

        if let customHeight = height {
            self.height = customHeight
        }
    }

    static func fromTop(padding: CGFloat = 20, height: CGFloat? = nil) -> ToastPosition {
        .init(reference: .top, horizontalPadding: padding, height: height)
    }

    static func fromBottom(padding: CGFloat = 20, height: CGFloat? = nil) -> ToastPosition {
        .init(reference: .bottom, horizontalPadding: padding, height: height)
    }

}

public class ToastManager {
    let window: UIWindow
    public static let sharedInstance = ToastManager(window: nil)

    /// Is used to track if the view is dismissed manually
    private var views = [UIView: ToastPosition]()

    private init(window: UIWindow? = nil) {
        self.window = window ?? UIApplication.shared.windows.first!
    }

    @objc func didTap(_ sender: UITapGestureRecognizer) {
        guard let attachedView = sender.view, let position = views[attachedView]  else {
            return
        }

        let targetY = position.targetY(forPresentation: false, windowHeight: window.bounds.height)

        dismissView(attachedView, targetYPosition: targetY)
    }

    // MARK: Public api
    public func queue<T: ToastPresentable>(toast: T) {
        let view = toast.convertToView()

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))

        view.addGestureRecognizer(gestureRecognizer)
        views[view] = toast.position

        self.animateView(view,
                         duration: toast.duration,
                         position: toast.position,
                         completion: {
        })

    }

    // MARK: - Helpers

    /// Remove view from superview and queue
    private func removeView(_ view: UIView) {
        view.removeFromSuperview()
        self.views.removeValue(forKey: view)
    }

    private func dismissView(_ view: UIView, targetYPosition: CGFloat) {
        if self.views.keys.contains(view) {
            UIView.animate(withDuration: 0.5, animations: {
                view.frame.origin.y = targetYPosition
            }, completion: { _ in
                self.removeView(view)
            })
        }
    }

    private func animateView(_ view: UIView,
                             duration: TimeInterval,
                             position: ToastPosition,
                             completion: @escaping (() -> Void)) {
        window.addSubview(view)
        window.bringSubviewToFront(view)

        view.isUserInteractionEnabled = true

        view.frame = CGRect(x: position.horizontalPadding,
                            y: position.startingY(windowHeight: window.bounds.height - window.safeAreaInsets.top),
                            width: window.bounds.width - position.horizontalPadding * 2,
                            height: position.height)

        UIView.animate(withDuration: 0.2, animations: {
            view.frame.origin.y = position.targetY(forPresentation: true,
                                                   windowHeight: self.window.bounds.height)
        }, completion: { done in
            if done {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: {

                    let targetY = position.targetY(forPresentation: false,
                                                   windowHeight: self.window.bounds.height)

                    self.dismissView(view, targetYPosition: targetY)
                })
            }
        })
    }

}
