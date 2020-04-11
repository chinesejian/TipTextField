//
//  TipTextField.swift
//  TipTextField
//
//  Created by jason huang on 2020/4/11.
//

import UIKit

extension UIColor {
    convenience init?(red: Int, green: Int, blue: Int, transparency: CGFloat = 1) {
        guard red >= 0 && red <= 255 else { return nil }
        guard green >= 0 && green <= 255 else { return nil }
        guard blue >= 0 && blue <= 255 else { return nil }

        var trans = transparency
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: trans)
    }
	
    convenience init?(hex: Int, transparency: CGFloat = 1) {
        var trans = transparency
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }

        let red = (hex >> 16) & 0xff
        let green = (hex >> 8) & 0xff
        let blue = hex & 0xff
        self.init(red: red, green: green, blue: blue, transparency: trans)
    }
}

open class TipTextField: UITextField {
	private let backgroundLayer = CALayer()
	open var errorLabel: UILabel!
	
	open var validator: InputValidator?
	
	// MARK: Colors
	override open var textColor: UIColor? {
		didSet {
			self.updateControl(false)
		}
	}
	
	open var placeholderColor: UIColor = UIColor(hex: 0xffffff, transparency: 0.3)! {
		didSet {
			self.updatePlaceholder()
		}
	}
	
	open var placeholderFont: UIFont? {
		didSet {
			self.updatePlaceholder()
		}
	}
	
	open var selectedBorderColor: UIColor = UIColor.blue {
		didSet {
			self.updateBorderColor()
			self.tintColor = selectedBorderColor
		}
	}
	
	open var errorColor: UIColor = UIColor.red {
		didSet {
			self.updateColors()
		}
	}
	
	open var inputBackgroundColor: UIColor = UIColor(hex: 0x303030)! {
		didSet {
			backgroundLayer.backgroundColor = inputBackgroundColor.cgColor
		}
	}
	
	open var leftMargin: CGFloat = 10 {
		didSet {
			self.setNeedsLayout()
		}
	}
	
	open var rightViewWidth: CGFloat = 30 {
		didSet {
			self.setNeedsLayout()
		}
	}
	
	// MARK: - Initializers
	override public init(frame: CGRect) {
		super.init(frame: frame)
		self.setup()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.setup()
	}
	
	fileprivate final func setup() {
		self.borderStyle = .none
		self.createErrorLabel()
		self.updateBorderColor()
		self.updateColors()
		self.updateTextAligment()
		self.addTarget(self, action: #selector(editingDidChanged), for: .editingChanged)
		
		self.backgroundColor = .clear
		backgroundLayer.backgroundColor = inputBackgroundColor.cgColor
		backgroundLayer.cornerRadius = 4
		backgroundLayer.borderWidth = 1
		backgroundLayer.borderColor = inputBackgroundColor.cgColor
		self.layer.insertSublayer(backgroundLayer, at: 0)
		
		self.tintColor = selectedBorderColor
	}
	
	@objc open func editingDidChanged() {
		updateControl(true)
	}
	
	// MARK: Properties
	override open var isSecureTextEntry: Bool {
		set {
			super.isSecureTextEntry = newValue
			self.fixCaretPosition()
		}
		get {
			return super.isSecureTextEntry
		}
	}
	
	open var error: String? {
		didSet {
			self.updateControl(true)
		}
	}
	
	open var editingOrSelected: Bool {
		get {
			return super.isEditing || self.isSelected
		}
	}
	
	open var hasError: Bool {
		get {
			return self.error != nil && self.error != ""
		}
	}
	
	override open var text: String? {
		didSet {
			self.updateControl(false)
		}
	}
	
	override open var placeholder: String? {
		didSet {
			self.setNeedsDisplay()
			self.updatePlaceholder()
		}
	}
	
	open override var isSelected: Bool {
		didSet {
			self.updateControl(true)
		}
	}
	
	fileprivate func createErrorLabel() {
		let label = UILabel()
		label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		label.font = UIFont.systemFont(ofSize: 13)
		label.alpha = 1.0
		label.numberOfLines = 0
		label.textColor = self.errorColor
		label.accessibilityIdentifier = "error-label"
		self.addSubview(label)
		self.errorLabel = label
	}
	
	// MARK: Responder handling
	@discardableResult
	override open func becomeFirstResponder() -> Bool {
		let result = super.becomeFirstResponder()
		self.error = nil
		self.updateControl(true)
		return result
	}
	
	@discardableResult
	override open func resignFirstResponder() -> Bool {
		let result =  super.resignFirstResponder()
		self.updateControl(true)
		return result
	}
	
	// MARK: - View updates
	fileprivate func updateControl(_ animated:Bool = false) {
		self.invalidateIntrinsicContentSize()
		self.updateColors()
		self.updateErrorLabel(animated)
	}
	
	fileprivate func updatePlaceholder() {
		if let placeholder = self.placeholder, let font = self.placeholderFont ?? self.font {
			let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: placeholderColor, .font: font]
			self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
		}
	}
	
	// MARK: - Color updates
	open func updateColors() {
		self.updateBorderColor()
	}
	
	fileprivate func updateBorderColor() {
		if self.hasError {
			self.backgroundLayer.borderColor = self.errorColor.cgColor
		} else {
			self.backgroundLayer.borderColor = self.editingOrSelected ? self.selectedBorderColor.cgColor : self.borderColor?.cgColor
		}
	}
	
	// MARK: - error handling
	fileprivate func updateErrorLabel(_ animated:Bool = false) {
		self.errorLabel.text = error
		self.invalidateIntrinsicContentSize()
	}
	
	// MARK: - UITextField element positioning overrides
	override open func borderRect(forBounds bounds: CGRect) -> CGRect {
		let errorHeight = self.errorHeight()
		let rect = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height - errorHeight)
		return rect
	}
	
	override open func textRect(forBounds bounds: CGRect) -> CGRect {
		let errorHeight = self.errorHeight()
		let rightWidth: CGFloat = ((self.clearButtonMode != .never || self.rightViewMode != .never) ? rightViewWidth : 0)
		let rect = CGRect(x: leftMargin, y: 0, width: bounds.size.width - leftMargin - rightWidth, height: bounds.size.height - errorHeight)
		return rect
	}
	
	override open func editingRect(forBounds bounds: CGRect) -> CGRect {
		return textRect(forBounds: bounds)
	}
	
	override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
		return textRect(forBounds: bounds)
	}
	
	override open func rightViewRect(forBounds bounds: CGRect) -> CGRect {
		var rect = textRect(forBounds: bounds)
		rect.size.width = rightViewWidth
		rect.origin.x = bounds.size.width - rect.size.width
		return rect
	}
	
	override open func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
		return rightViewRect(forBounds: bounds)
	}
	
	// MARK: - Custom view positioning overrides
	open func errorLabelRectForBounds(_ bounds: CGRect) -> CGRect {
		guard let error = error, !error.isEmpty else { return CGRect.zero }
		let font: UIFont = errorLabel.font ?? UIFont.systemFont(ofSize: 17.0)
		
		let textAttributes = [NSAttributedString.Key.font: font]
		let s = CGSize(width: bounds.size.width, height: 2000)
		let boundingRect = error.boundingRect(with: s, options: .usesLineFragmentOrigin, attributes: textAttributes, context: nil)
		return CGRect(x: 0, y: bounds.size.height - boundingRect.size.height, width: boundingRect.size.width, height: boundingRect.size.height)
	}
	
	// Calcualte the height of the textfield.
	open func textHeight() -> CGFloat {
		return max(44, (self.font?.lineHeight ?? 15.0) + 7.0)
	}
	
	open func errorHeight() -> CGFloat {
		return self.errorLabelRectForBounds(self.bounds).size.height
	}
	
	// MARK: - Layout
	override open func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		self.isSelected = true
		self.updateControl(false)
		self.invalidateIntrinsicContentSize()
	}
	
	override open func layoutSubviews() {
		super.layoutSubviews()
		self.invalidateIntrinsicContentSize()
		self.errorLabel.frame = self.errorLabelRectForBounds(self.bounds)
		self.backgroundLayer.frame = self.borderRect(forBounds: self.bounds)
		rightView?.frame = rightViewRect(forBounds: bounds)
	}
	
	override open var intrinsicContentSize: CGSize {
		let height = self.textHeight() + self.errorHeight()
		return CGSize(width: self.bounds.size.width, height: height)
	}
	
	// MARK: Left to right support
	var isLeftToRightLanguage = UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
		didSet {
			self.updateTextAligment()
		}
	}
	
	fileprivate func updateTextAligment() {
		if (self.isLeftToRightLanguage) {
			self.textAlignment = .left
		} else {
			self.textAlignment = .right
		}
	}
	
	open override var description: String {
		return "[TipTextField(\(String(describing: placeholder))) text:\(String(describing: text))]"
	}
}

extension TipTextField {
	@discardableResult
	open func validInputAndShowErrorIfNeed() -> Bool {
		if let validator = self.validator {
			let msg = validator.validInputValue(self.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? "")
			self.error = msg
			return msg == nil
		}
		return true
	}
	
	open func isValid() -> Bool {
		if let validator = self.validator {
			let msg = validator.validInputValue(self.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? "")
			return msg == nil
		}
		return true
	}

	open func addConditions(minCount: Int? = nil, maxCount: Int? = nil, validateRegular: String? = nil, errorMsg: String? = nil, type: InputType = .normal) {
		let v = InputValidator(type: type)
		v.validateRegular = validateRegular
		v.errorMsg = errorMsg
		v.minCount = minCount
		v.maxCount = maxCount
		self.validator = v
	}
}

fileprivate extension UITextField {
	func fixCaretPosition() {
		// http://stackoverflow.com/questions/14220187/uitextfield-has-trailing-whitespace-after-securetextentry-toggle
		let beginning = self.beginningOfDocument
		let end = self.endOfDocument
		self.selectedTextRange = self.textRange(from: beginning, to: end)
		self.selectedTextRange = self.textRange(from: end, to: end)
	}
}

fileprivate extension UIView {
	
	var borderColor: UIColor? {
		get {
			guard let color = layer.borderColor else { return nil }
			return UIColor(cgColor: color)
		}
		set {
			guard let color = newValue else {
				layer.borderColor = nil
				return
			}
			// Fix React-Native conflict issue
			guard String(describing: type(of: color)) != "__NSCFType" else { return }
			layer.borderColor = color.cgColor
		}
	}
	
	var borderWidth: CGFloat {
		get {
			return layer.borderWidth
		}
		set {
			layer.borderWidth = newValue
		}
	}
	
	var cornerRadius: CGFloat {
		get {
			return layer.cornerRadius
		}
		set {
			layer.masksToBounds = true
			layer.cornerRadius = abs(CGFloat(Int(newValue * 100)) / 100)
		}
	}
	
	var height: CGFloat {
		get {
			return frame.size.height
		}
		set {
			frame.size.height = newValue
		}
	}
}
