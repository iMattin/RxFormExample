//
//  ViewModel.swift
//  FormExample
//
//  Created by Matin Abdollahi on 5/12/20.
//

import Foundation
import RxForm
import RxSwift
import RxCocoa

class ViewModel {
    
    let countryRepository: CountryRepository
    let registerFormGroup: FormGroup
    
    lazy var name: FormControl = registerFormGroup.get("personalInfo", "name") as! FormControl
    lazy var email: FormControl = registerFormGroup.get("personalInfo", "email") as! FormControl
    lazy var gender: FormControl = registerFormGroup.get("personalInfo", "gender") as! FormControl
    lazy var country: FormControl = registerFormGroup.get("addressInfo", "country") as! FormControl
    lazy var dateOfBirth: FormControl = registerFormGroup.get("addressInfo", "dateOfBirth") as! FormControl

    lazy var countries: Driver<[Country]> = countryRepository.getCountries()
        .asDriver(onErrorJustReturn: [])
    
    lazy var nameError: Driver<String?> = name.statusChanges.map { [unowned self] status in
        return status == .invalid ? "Name is required" : nil
    }
    
    lazy var emailError: Driver<String?> = email.statusChanges.map { [unowned self] status in
        if status == .invalid {
            if let _ = self.email.errors["required"] {
                return "E-mail is required"
            }
            return "E-mail address is not valid"
        }
        return nil
    }
    
    lazy var genderError: Driver<String?> = gender.statusChanges.map { [unowned self] status in
        return status == .invalid ? "Please select your gender" : nil
    }
    
    lazy var dateOfBirthError: Driver<String?> = dateOfBirth.statusChanges.map { [unowned self] status in
        return status == .invalid ? "Invalid date selected" : nil
    }
    
    init(countryRepository: CountryRepository) {
        let dateOfBirthValidator: Validator = { control in
            guard let date = control.value as? Date else { return nil }
            return date.compare(Date()) == .orderedDescending ? ["date" : true] : nil
        }
        
        self.countryRepository = countryRepository
        
        registerFormGroup = FormGroup(controls: [
            "personalInfo": FormGroup(controls: [
                "name": FormControl(validators: [Validators.required]),
                "email": FormControl(validators: [Validators.required, Validators.email]),
                "gender": FormControl(validators: [Validators.required, Validators.max(1)]),
            ]),
            "addressInfo": FormGroup(controls: [
                "country": FormControl(),
                "dateOfBirth": FormControl(Date(), validators: [dateOfBirthValidator]),
            ])
        ])
    }
}
