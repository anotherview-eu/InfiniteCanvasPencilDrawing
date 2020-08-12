//
//  ViewController.swift
//  SimpleDrawingApp
//
//  Created by AV on 12/08/2020.
//  Copyright © 2020 AV. All rights reserved.
//

import UIKit
import PencilKit

fileprivate let maxContentEdge = CGFloat(500000)


class ViewController: UIViewController, PKCanvasViewDelegate {

	@IBOutlet var canvasView: PKCanvasView!
	var didShowTool = false


	override func viewDidLoad() {
		super.viewDidLoad()

		canvasView.delegate = self
		canvasView.contentSize = CGSize(width: maxContentEdge, height: maxContentEdge)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		canvasView.becomeFirstResponder()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		updateContentSize()

		if !didShowTool,
			let window = canvasView.window,
			let picker = PKToolPicker.shared(for: window)
		{
			picker.setVisible(true, forFirstResponder: canvasView)
			picker.addObserver(canvasView)
			didShowTool = true
		}
	}


	func updateContentSize() {

		let viewportBounds = canvasView.bounds
		let margin = UIEdgeInsets(top: -viewportBounds.height,
							left: -viewportBounds.width,
							bottom: -viewportBounds.height,
							right: -viewportBounds.width)

		// no drawing
		if canvasView.drawing.bounds.size == .zero {
			let leftInset = (canvasView.contentSize.width - viewportBounds.width)/2
			let topInset = (canvasView.contentSize.height - viewportBounds.height)/2
			canvasView.contentInset = UIEdgeInsets(top: -topInset,
													left: -leftInset,
													bottom: -topInset,
													right: -leftInset)
		} else {
			let realContentBounds = canvasView.drawing.bounds.inset(by: margin)

			// consider the useful content as the (drawing + margins) + the viewport, so that the drawing is not
			// scrolled upon updating the content insets, while the user draws something
			let finalContentBounds = realContentBounds.union(viewportBounds)

			// set the insets such a way that you can only scroll the useful content area
			canvasView.contentInset = UIEdgeInsets(top: -finalContentBounds.origin.y,
												left: -finalContentBounds.origin.x,
												bottom: -(canvasView.contentSize.height - finalContentBounds.maxY),
												right: -(canvasView.contentSize.width - finalContentBounds.maxX))
		}
		return
	}

	// MARK: - CanvasView Delegate

	func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
		updateContentSize()
	}
}

