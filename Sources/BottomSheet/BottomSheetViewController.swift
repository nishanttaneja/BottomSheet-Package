//
//  BottomSheetViewController.swift
//  BottomSheetViewController
//
//  Created by Nishant Taneja on 20/07/22.
//

import UIKit

public protocol BottomSheetViewControllerDelegate: NSObjectProtocol {
    func bottomSheetViewControllerWillAppear(withDuration animationDuration: CGFloat)
    func bottomSheetViewControllerWillDisappear(withDuration animationDuration: CGFloat)
}

public class BottomSheetViewController: UIViewController, BottomSheetViewDelegate, BottomSheetViewDataSource {
    
    // MARK: - Subviews
    
    private let bottomSheetView: BottomSheetView

    
    // MARK: - Delegation
    
    weak var delegate: BottomSheetViewControllerDelegate? = nil
    
    
    // MARK: - BottomSheetView
    
    // MARK: DataSource
    
    public func viewToDisplayAsBottomSheetView() -> UIView {
        .init()
    }
    
    // MARK: Delegate
    
    public func bottomSheetViewDidSelect(view: BottomSheetView) {
        dismiss(animated: true)
    }
    
    
    // MARK: - Lifecycle
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.bottomSheetViewControllerWillAppear(withDuration: bottomSheetView.animationDuration)
        bottomSheetView.presentBottomSheet()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.bottomSheetViewControllerWillDisappear(withDuration: bottomSheetView.animationDuration)
        bottomSheetView.dismissBottomSheet()
    }
    
    
    // MARK: - Configuration
    
    private func config() {
        bottomSheetView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomSheetView)
        NSLayoutConstraint.activate([
            bottomSheetView.topAnchor.constraint(equalTo: view.topAnchor),
            bottomSheetView.leftAnchor.constraint(equalTo: view.leftAnchor),
            bottomSheetView.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomSheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    public init() {
        bottomSheetView = BottomSheetView()
        super.init(nibName: nil, bundle: nil)
        bottomSheetView.minimumHeight = 200
        bottomSheetView.delegate = self
        bottomSheetView.dataSource = self
        config()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
