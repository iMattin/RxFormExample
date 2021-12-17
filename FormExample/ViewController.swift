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

    
    @IBOutlet weak var pesonalInfoToggleButton: UIButton!
    @IBOutlet weak var addressInfoToggleButton: UIButton!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var countryPickerView: UIPickerView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var dateErrorLabel: UILabel!
    
    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var genderErrorLabel: UILabel!
    
    
    
    private let viewModel: ViewModel = ViewModel(countryRepository: MockCountryRepository())
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performTwoWayBinding()

        viewModel.countries.map { $0.map { $0.name } }.drive(countryPickerView.rx.itemTitles) { _, item in
            return item
        }.disposed(by: bag)

        viewModel.countries.drive(onNext: { [weak self] _ in
            self?.viewModel.country.setValue((0,0))
        }).disposed(by: bag)
        
        viewModel.registerFormGroup.statusChanges
            .debug("registerFormGroup")
            .map { status -> String in
            switch status {
            case .disabled: return "Disabled"
            case .invalid: return "Invalid"
            case .valid: return "Valid"
            case .pending: return "Pending"
            }
        }.drive(submitButton.rx.title()).disposed(by: bag)
        
        viewModel.registerFormGroup.get("personalInfo").statusChanges
            .debug("personalInfo")
            .startWith(viewModel.registerFormGroup.get("personalInfo").status)
            .map { $0 == .disabled
                ? "Enable personal info section"
                : "Disable personal info section"}.drive(pesonalInfoToggleButton.rx.title()).disposed(by: bag)
        
        viewModel.registerFormGroup.get("addressInfo").statusChanges
            .startWith(viewModel.registerFormGroup.get("addressInfo").status)
            .map { $0 == .disabled
                ? "Enable address info section"
                : "Disable address info section"}.drive(addressInfoToggleButton.rx.title()).disposed(by: bag)
        
        viewModel.registerFormGroup.statusChanges
            .startWith(viewModel.registerFormGroup.status)
            .map { $0 == .disabled ? "Enable form" : "Disable form"}.drive(toggleButton.rx.title()).disposed(by: bag)
        
        toggleButton.rx.tap.subscribe(onNext: { [unowned self] _ in
            self.viewModel.registerFormGroup.status == .disabled
            ? self.viewModel.registerFormGroup.enable()
            : self.viewModel.registerFormGroup.disable()
        }).disposed(by: bag)
        
        pesonalInfoToggleButton.rx.tap.subscribe(onNext: { [unowned self] _ in
            self.viewModel.registerFormGroup.get("personalInfo").status == .disabled
            ? self.viewModel.registerFormGroup.get("personalInfo").enable()
            : self.viewModel.registerFormGroup.get("personalInfo").disable()
        }).disposed(by: bag)
        
        addressInfoToggleButton.rx.tap.subscribe(onNext: { [unowned self] _ in
            self.viewModel.registerFormGroup.get("addressInfo").status == .disabled
            ? self.viewModel.registerFormGroup.get("addressInfo").enable()
            : self.viewModel.registerFormGroup.get("addressInfo").disable()
        }).disposed(by: bag)
        
        viewModel.nameError.drive(nameErrorLabel.rx.text).disposed(by: bag)
        viewModel.emailError.drive(emailErrorLabel.rx.text).disposed(by: bag)
        viewModel.genderError.drive(genderErrorLabel.rx.text).disposed(by: bag)
        viewModel.dateOfBirthError.drive(dateErrorLabel.rx.text).disposed(by: bag)

        submitButton.rx.tap.subscribe(onNext: { [unowned self] _ in
            let message = (self.viewModel.registerFormGroup.value as! [String : Any?] ).description
            let alert = UIAlertController(title: "Form value", message: message, preferredStyle: .alert)
            alert.addAction(.init(title: "Close", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }).disposed(by: bag)
    }
    
    
    private func performTwoWayBinding() {

        viewModel.name.setControlValueAccessor(nameTextField)
        viewModel.email.setControlValueAccessor(emailTextField)
        viewModel.dateOfBirth.setControlValueAccessor(datePicker)
        viewModel.gender.setControlValueAccessor(genderSegmentedControl)
        viewModel.country.setControlValueAccessor(countryPickerView)

        nameTextField.bind(bag: bag)
        emailTextField.bind(bag: bag)
        genderSegmentedControl.bind(bag: bag)
        datePicker.bind(bag: bag)
        countryPickerView.bind(bag: bag)
        
        submitButton.isEnabled = viewModel.registerFormGroup.valid
        
        viewModel.name.statusChanges.drive().disposed(by: bag)
        viewModel.registerFormGroup.statusChanges.map { $0 == .valid }
            .drive(submitButton.rx.isEnabled).disposed(by: bag)

    }
    
  
}

