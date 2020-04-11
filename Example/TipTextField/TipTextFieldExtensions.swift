//
//  TipTextFieldExtensions.swift
//  TipTextField_Example
//
//  Created by jason huang on 2020/4/11.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import TipTextField

extension TipTextField {
	func replaceClearButtonWithImage(_ image: UIImage, viewMode: UITextField.ViewMode = .whileEditing) {
		self.rightViewMode = viewMode
		let button = UIButton()
		button.setImage(image, for: .normal)
		button.addTarget(self, action: #selector(didClickClear), for: .touchUpInside)
		self.rightView = button
	}
	
	func addVisibleButton() {
		self.isSecureTextEntry = true
		self.rightViewMode = .always
		let button = UIButton()
		button.setImage(UIImage(named: "btn_eye_close"), for: .selected)
		button.setImage(UIImage(named: "btn_eye_open"), for: .normal)
		button.addTarget(self, action: #selector(didClickVisiblility), for: .touchUpInside)
		self.rightView = button
	}
	
	@objc
	func didClickVisiblility(_ button: UIButton) {
		button.isSelected = !button.isSelected
		self.isSecureTextEntry = !button.isSelected
	}
	
	@objc
	func didClickClear() {
		text = ""
		attributedText = NSAttributedString(string: "")
	}
}
