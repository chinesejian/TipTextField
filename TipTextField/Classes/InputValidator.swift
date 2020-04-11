//
//  InputValidator.swift
//  TipTextField
//
//  Created by jason huang on 2020/4/11.
//

import UIKit

//Minimum 8 characters at least 1 Alphabet and 1 Number:
//
public let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"

//Minimum 8 characters at least 1 Alphabet, 1 Number and 1 Special Character:
//
//"^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,}$"
//Minimum 8 characters at least 1 Uppercase Alphabet, 1 Lowercase Alphabet and 1 Number:
//
//"^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{8,}$"
//Minimum 8 characters at least 1 Uppercase Alphabet, 1 Lowercase Alphabet, 1 Number and 1 Special Character:
//
//"^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[d$@$!%*?&#])[A-Za-z\\dd$@$!%*?&#]{8,}"
//Minimum 8 and Maximum 10 characters at least 1 Uppercase Alphabet, 1 Lowercase Alphabet, 1 Number and 1 Special Character:
//
//"^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$!%*?&#])[A-Za-z\\d$@$!%*?&#]{8,10}"


public let emailRegex = "^(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])$"

public enum InputType: Int {
    case name, email, password, number, normal
}

open class InputValidator {
    
    open var type: InputType = .normal
    open var errorMsg: String?
    open var minCount: Int?
    open var maxCount: Int?
    open var validateRegular: String?
    
	public init(type: InputType) {
        self.type = type
    }
    
    private var defaultErrorMsg: String {
        switch type {
        case .name:
            return "Name is invalid"
        case .email:
            return "Email is invalid "
        case .password:
            return "Password is invalid "
        case .number:
            return "Number is invalid "
        case .normal:
            return "Invalid"
        }
    }

    public func validInputValue(_ value: String) -> String? {
        if value.isEmpty {
            return "missing"
        } else if let regular = validateRegular {
            if value.isValidRegular(regular) {
                return nil
            } else {
                return errorMsg ?? defaultErrorMsg
            }
        } else if let min = minCount, value.count < min {
            return errorMsg ?? defaultErrorMsg
        } else if let max = maxCount, value.count > max {
            return errorMsg ?? defaultErrorMsg
        } else if type == .email, !value.isValidRegular(emailRegex) {
            return errorMsg ?? defaultErrorMsg
        }
        return nil
    }

}

extension String {
    func isValidRegular(_ regular: String) -> Bool {
        let regularExpression = regular
        let passwordValidation = NSPredicate.init(format: "SELF MATCHES %@", regularExpression)
        return passwordValidation.evaluate(with: self)
    }
}


