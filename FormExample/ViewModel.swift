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
    
    lazy var firstName: FormControl = registerFormGroup.get("personalInfo", "firstName") as! FormControl
    lazy var lastName: FormControl = registerFormGroup.get("personalInfo", "lastName") as! FormControl
    lazy var gender: FormControl = registerFormGroup.get("personalInfo", "gender") as! FormControl
    lazy var dateOfBirth: FormControl = registerFormGroup.get("personalInfo", "dateOfBirth") as! FormControl
    lazy var email: FormControl = registerFormGroup.get("addressInfo", "email") as! FormControl
    lazy var country: FormControl = registerFormGroup.get("addressInfo", "country") as! FormControl
    lazy var address: FormControl = registerFormGroup.get("addressInfo", "address") as! FormControl

    lazy var countries: Driver<[Country]> = countryRepository.getCountries()
        .asDriver(onErrorJustReturn: [])
    
    init(countryRepository: CountryRepository) {
        let dateOfBirthValidator: Validator = { control in
            guard let date = control.value as? Date else { return nil }
            return date.compare(Date()) == .orderedDescending ? ["date" : true] : nil
        }
        
        self.countryRepository = countryRepository
        
        registerFormGroup = FormGroup(controls: [
            "personalInfo": FormGroup(controls: [
                "firstName": FormControl(validators: [Validators.minLength(5), Validators.maxLength(10)]),
                "lastName": FormControl(validators: [Validators.email, Validators.required]),
                "gender": FormControl(1, validators: [Validators.required, Validators.max(1)]),
                "dateOfBirth": FormControl(nil, validators: [dateOfBirthValidator]),
            ]),
            "addressInfo": FormGroup(controls: [
                "email": FormControl(),
                "country": FormControl((1, 0)),
                "address": FormControl()
            ])
        ])
    }
}
