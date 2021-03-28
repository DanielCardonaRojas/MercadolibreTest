//
//  ToastMessageView.swift
//  MercadoLibre
//
//  Created by Daniel Cardona Rojas on 27/03/21.
//

import UIKit

public class ToastMessageView: UIView {
    lazy var messageLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        addSubview(messageLabel)
        NSLayoutConstraint.activate {
            messageLabel.relativeTo(self, positioned: .inset(by: 8))
        }

        layer.cornerRadius = 12
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 1, height: 4)
        layer.shadowOpacity = 0.4
        layer.shadowColor = UIColor.black.cgColor
        backgroundColor = .white
    }
}

extension String: ToastPresentable {
    public func convertToView() -> ToastMessageView {
        let view = ToastMessageView()
        view.messageLabel.text = self
        return view
    }

}
