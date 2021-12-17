//
//  ViewController.swift
//  FormExample
//
//  Created by Matin Abdollahi on 5/12/20.
//  Copyright © 2020 TESTAPP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxForm

class ViewController: UIViewController {

    lazy var firstNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "First Name"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    lazy var lastNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Last Name"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    lazy var birthdayDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        return datePicker
    }()
    
    lazy var genderSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.insertSegment(withTitle: "Male", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "Female", at: 1, animated: false)
        segmentedControl.insertSegment(withTitle: "Unknown", at: 2, animated: false)
        return segmentedControl
    }()
    
    lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "E-Mail"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        return textField
    }()
    
    lazy var addressTextView: UITextView = {
        let textView = UITextView()
        return textView
    }()
    
    lazy var countryPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        return pickerView
    }()
    
    lazy var submitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Submit", for: .normal)
        button.setTitle("Not Valid", for: .disabled)
        button.setTitleColor(.green, for: .normal)
        button.setTitleColor(.red, for: .disabled)
        return button
    }()
    
    private let viewModel: ViewModel = ViewModel(countryRepository: MockCountryRepository())
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        performTwoWayBinding()
        
        viewModel.countries.map { $0.map { $0.name } }.drive(countryPickerView.rx.itemTitles) { _, item in
            return item
        }.disposed(by: bag)

        viewModel.countries.drive(onNext: { [weak self] _ in
            self?.viewModel.country.updateValueAndValidity()
        }).disposed(by: bag)
    }
    
    private func performTwoWayBinding() {

        viewModel.firstName.setControlValueAccessor(firstNameTextField)
        viewModel.lastName.setControlValueAccessor(lastNameTextField)
        firstNameTextField.bind(bag: bag)
        lastNameTextField.bind(bag: bag)
        genderSegmentedControl.bind(bag: bag)
        birthdayDatePicker.bind(bag: bag)
        countryPickerView.bind(bag: bag)
        
        viewModel.dateOfBirth.setControlValueAccessor(birthdayDatePicker)
        
        viewModel.gender.setControlValueAccessor(genderSegmentedControl)
        
        viewModel.country.setControlValueAccessor(countryPickerView)
        
        submitButton.isEnabled = viewModel.registerFormGroup.valid
        
        viewModel.firstName.statusChanges.drive().disposed(by: bag)
        viewModel.registerFormGroup.statusChanges.map { $0 == .valid }
            .drive(submitButton.rx.isEnabled).disposed(by: bag)

    }
    
    private func setupView() {
        
        let personalInfoContainerView = UIView()
        personalInfoContainerView.backgroundColor = .gray.withAlphaComponent(0.08)
        personalInfoContainerView.layer.cornerRadius = 24
        
        let personalInfoStackView = UIStackView(arrangedSubviews: [
            firstNameTextField,
            lastNameTextField,
            genderSegmentedControl,
            birthdayDatePicker
        ])
        personalInfoStackView.axis = .vertical
        personalInfoStackView.alignment = .fill
        personalInfoStackView.distribution = .fillEqually
        personalInfoStackView.spacing = 12

        personalInfoContainerView.addSubview(personalInfoStackView)
        personalInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        personalInfoStackView.leadingAnchor.constraint(equalTo: personalInfoContainerView.leadingAnchor, constant: 24).isActive = true
        personalInfoStackView.topAnchor.constraint(equalTo: personalInfoContainerView.topAnchor, constant: 24).isActive = true
        personalInfoStackView.trailingAnchor.constraint(equalTo: personalInfoContainerView.trailingAnchor, constant: -24).isActive = true
        personalInfoStackView.bottomAnchor.constraint(equalTo: personalInfoContainerView.bottomAnchor, constant: -24).isActive = true

        view.addSubview(personalInfoContainerView)
        personalInfoContainerView.translatesAutoresizingMaskIntoConstraints = false
        personalInfoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24).isActive = true
        personalInfoContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        personalInfoContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24).isActive = true

        
        let addressInfoContainerView = UIView()
        addressInfoContainerView.backgroundColor = .gray.withAlphaComponent(0.08)
        addressInfoContainerView.layer.cornerRadius = 24
        
        let addressInfoStackView = UIStackView(arrangedSubviews: [
            countryPickerView,
            addressTextView
        ])
        addressInfoStackView.axis = .vertical
        addressInfoStackView.alignment = .fill
        addressInfoStackView.distribution = .fillEqually
        addressInfoStackView.spacing = 12
        
        addressInfoContainerView.addSubview(addressInfoStackView)
        addressInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        addressInfoStackView.leadingAnchor.constraint(equalTo: addressInfoContainerView.leadingAnchor, constant: 24).isActive = true
        addressInfoStackView.topAnchor.constraint(equalTo: addressInfoContainerView.topAnchor, constant: 24).isActive = true
        addressInfoStackView.trailingAnchor.constraint(equalTo: addressInfoContainerView.trailingAnchor, constant: -24).isActive = true
        addressInfoStackView.bottomAnchor.constraint(equalTo: addressInfoContainerView.bottomAnchor, constant: -24).isActive = true

        view.addSubview(addressInfoContainerView)
        addressInfoContainerView.translatesAutoresizingMaskIntoConstraints = false
        addressInfoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24).isActive = true
        addressInfoContainerView.topAnchor.constraint(equalTo: personalInfoContainerView.bottomAnchor, constant: 20).isActive = true
        addressInfoContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24).isActive = true
        addressInfoContainerView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(submitButton)
        submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24).isActive = true
        submitButton.topAnchor.constraint(equalTo: addressInfoContainerView.bottomAnchor, constant: 20).isActive = true
        submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24).isActive = true
        submitButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

}

