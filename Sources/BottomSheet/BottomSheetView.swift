//
//  BottomSheetView.swift
//  BottomSheetView
//
//  Created by Nishant Taneja on 20/07/22.
//

import UIKit

public protocol BottomSheetViewDataSource: NSObjectProtocol {
    func viewToDisplayAsBottomSheetView() -> UIView
}

public protocol BottomSheetViewDelegate: NSObjectProtocol {
    func bottomSheetViewDidSelect(view: BottomSheetView)
}

public class BottomSheetView: UIView {
    
    // MARK: - Constants
    
    private let maximumHeight: CGFloat = UIScreen.main.bounds.height - 64
    private let titleLabelHeight: CGFloat = 44
    private let padding: CGFloat = 16
    private let itemSpacing: CGFloat = 8
    public let animationDuration: CGFloat = 0.4
    private let contentBarHeight: CGFloat = 32
    
    
    // MARK: - Subviews
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let barView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 60).isActive = true
        view.heightAnchor.constraint(equalToConstant: 8).isActive = true
        return view
    }()
    private lazy var contentBarView: UIView = {
        let stack = UIStackView(arrangedSubviews: [.init(), barView, .init()])
        stack.distribution = .equalCentering
        let stackView = UIStackView(arrangedSubviews: [.init(), stack, .init()])
        stackView.distribution = .equalCentering
        stackView.axis = .vertical
        stackView.isUserInteractionEnabled = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = itemSpacing
        return stack
    }()
    
    
    // MARK: - Properties
    
    public var minimumHeight: CGFloat = 300 {
        willSet {
            currentHeight = newValue
            contentViewHeightConstraint.constant = newValue
            contentViewBottomConstraint.constant = newValue
        }
    }
    private var currentHeight: CGFloat = 300
    private var dismissibleHeight: CGFloat {
        min(minimumHeight*0.4, 200)
    }

    // Gestures
    private var panGestureRecognizer: UIPanGestureRecognizer! = nil
    private var tapGestureRecognizer: UITapGestureRecognizer! = nil
    
    
    // MARK: - Delegations
    
    public weak var dataSource: BottomSheetViewDataSource? = nil {
        didSet {
            guard let newView = dataSource?.viewToDisplayAsBottomSheetView() else { return }
            contentStackView.addArrangedSubview(newView)
        }
    }
    public weak var delegate: BottomSheetViewDelegate? = nil
    
    
    // MARK: - Constraints
    
    // ContentView
    private var contentViewHeightConstraint: NSLayoutConstraint! = nil
    private var contentViewBottomConstraint: NSLayoutConstraint! = nil

    
    // MARK: - Presentation
    
    public func presentBottomSheet() {
        contentViewBottomConstraint?.constant = 0
        UIView.animate(withDuration: animationDuration) {
            self.layoutIfNeeded()
        }
    }
    
    public func dismissBottomSheet() {
        contentViewBottomConstraint?.constant = minimumHeight
        UIView.animate(withDuration: animationDuration) {
            self.layoutIfNeeded()
        }
    }
    
    private func configGestures() {
        panGestureRecognizer = .init(target: self, action: #selector(handleViewPanGesture(recognizer:)))
        panGestureRecognizer.delaysTouchesBegan = false
        panGestureRecognizer.delaysTouchesEnded = false
        addGestureRecognizer(panGestureRecognizer)
        tapGestureRecognizer = .init(target: self, action: #selector(handleViewTapGesture(recognizer:)))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func handleViewPanGesture(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self)
        let isDraggingDown = translation.y > 0
        let newHeight = currentHeight - translation.y

        switch recognizer.state {
        case .changed:
            if newHeight < maximumHeight {
                contentViewHeightConstraint?.constant = newHeight
                layoutIfNeeded()
            }
        case .ended:
            if newHeight < dismissibleHeight {
                dismissBottomSheet()
                delegate?.bottomSheetViewDidSelect(view: self)
            } else if newHeight < minimumHeight {
                updateHeightWithAnimation(to: minimumHeight)
            } else if newHeight < maximumHeight, isDraggingDown {
                updateHeightWithAnimation(to: minimumHeight)
            } else if newHeight > minimumHeight, !isDraggingDown {
                updateHeightWithAnimation(to: maximumHeight)
            }
        default: break
        }
    }
    
    private func updateHeightWithAnimation(to newHeight: CGFloat) {
        contentViewHeightConstraint?.constant = newHeight
        UIView.animate(withDuration: animationDuration) {
            self.layoutIfNeeded()
        } completion: { _ in
            self.currentHeight = newHeight
        }
    }
    
    @objc private func handleViewTapGesture(recognizer: UITapGestureRecognizer) {
        delegate?.bottomSheetViewDidSelect(view: self)
    }
    
    
    // MARK: - Configuration
    
    private func config() {
        backgroundColor = .clear
        contentView.addSubview(contentBarView)
        contentView.addSubview(contentStackView)
        addSubview(contentView)
        configConstraints()
        configGestures()
    }
    
    private func configConstraints() {
        contentViewHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: minimumHeight)
        contentViewBottomConstraint = contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: minimumHeight)
        NSLayoutConstraint.activate([
            // ContentView
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
            contentViewBottomConstraint,
            contentViewHeightConstraint,
            // ContentBarView
            contentBarView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentBarView.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor),
            contentBarView.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor),
            contentBarView.heightAnchor.constraint(equalToConstant: contentBarHeight),
            // Content Stack
            contentStackView.topAnchor.constraint(equalTo: contentBarView.bottomAnchor, constant: .zero),
            contentStackView.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor, constant: padding),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -padding),
            contentStackView.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor, constant: -padding)
        ])
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
