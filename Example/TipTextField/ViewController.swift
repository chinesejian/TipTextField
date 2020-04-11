//
//  ViewController.swift
//  TipTextField
//
//  Created by chinesejian on 04/11/2020.
//  Copyright (c) 2020 chinesejian. All rights reserved.
//

import UIKit
import TipTextField

class ViewController: UIViewController {
	@IBOutlet var firstNameTextField: TipTextField!
	@IBOutlet var lastNameTextField: TipTextField!
	@IBOutlet var emailTextField: TipTextField!
	@IBOutlet var numberTextField: TipTextField!
	@IBOutlet var passwordTextField: TipTextField!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		firstNameTextField.placeholder = "First Name"
		firstNameTextField.returnKeyType = .next
		firstNameTextField.delegate = self
		firstNameTextField.textColor = .white
		firstNameTextField.addConditions(minCount: 1, type: .name)
		
		lastNameTextField.placeholder = "Last Name"
		lastNameTextField.returnKeyType = .next
		lastNameTextField.delegate = self
		lastNameTextField.textColor = .white
		lastNameTextField.addConditions(minCount: 1, type: .name)

		emailTextField.placeholder = "Email"
		emailTextField.returnKeyType = .next
		emailTextField.delegate = self
		emailTextField.textColor = .white
		emailTextField.keyboardType = .emailAddress
		emailTextField.addConditions(type: .email)

		numberTextField.placeholder = "Phone Number"
		numberTextField.returnKeyType = .next
		numberTextField.delegate = self
		numberTextField.textColor = .white
		numberTextField.keyboardType = .numberPad
		numberTextField.addConditions(minCount: 10, maxCount: 10, type: .number)
		numberTextField.selectedBorderColor = UIColor.yellow

		passwordTextField.placeholder = "Password (at least 8 characters)"
		passwordTextField.returnKeyType = .done
		passwordTextField.delegate = self
		passwordTextField.textColor = .white
		passwordTextField.addConditions(minCount: 8, validateRegular: passwordRegex, errorMsg: "Password (at least 8 characters)", type: .password)
		passwordTextField.addVisibleButton()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		let tfs = [firstNameTextField, lastNameTextField, emailTextField, numberTextField, passwordTextField]
		if let index = tfs.index(of: textField as? TipTextField), index + 1 < tfs.count {
			tfs[index + 1]?.becomeFirstResponder()
        }else{
            self.view.endEditing(true)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let tf = textField as? TipTextField {
            tf.validInputAndShowErrorIfNeed()
        }
    }
}

