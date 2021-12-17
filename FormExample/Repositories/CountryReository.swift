//
//  CountryReository.swift
//  FormExample
//
//  Created by Matin Abdollahi on 12/17/21.
//

import Foundation
import RxSwift

protocol CountryRepository {
    func getCountries() -> Single<[Country]>
}

struct MockCountryRepository: CountryRepository {
    
    func getCountries() -> Single<[Country]> {
        .just([
            .init(id: 98, name: "Iran"),
            .init(id: 1, name: "USA"),
            .init(id: 44, name: "England"),
            .init(id: 93, name: "Afghanistan"),
            .init(id: 213, name: "Algeria")
        ]).debug("REPO").delay(.seconds(2), scheduler: MainScheduler.instance)
    }
    
}
