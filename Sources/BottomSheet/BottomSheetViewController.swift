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

open class BottomSheetViewController: UIViewController, BottomSheetViewDelegate, BottomSheetViewDataSource {
    
    // MARK: - Subviews
    
    public let bottomSheetView = BottomSheetView()

    
    // MARK: - Delegation
    
    open weak var delegate: BottomSheetViewControllerDelegate? = nil
    
    
    // MARK: - BottomSheetView
    
    // MARK: DataSource
    
    open func viewToDisplayAsBottomSheetView() -> UIView {
        .init()
    }
    
    // MARK: Delegate
    
    open func bottomSheetViewDidSelect(view: BottomSheetView) {
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
    
    open func config() {
        modalTransitionStyle = .coverVertical
        modalPresentationStyle = .overCurrentContext
        bottomSheetView.minimumHeight = 200
        bottomSheetView.dataSource = self
        bottomSheetView.delegate = self
        bottomSheetView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomSheetView)
        NSLayoutConstraint.activate([
            bottomSheetView.topAnchor.constraint(equalTo: view.topAnchor),
            bottomSheetView.leftAnchor.constraint(equalTo: view.leftAnchor),
            bottomSheetView.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomSheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        config()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        config()
    }
}
