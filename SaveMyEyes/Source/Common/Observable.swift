//
//  Observable.swift
//  SaveMyEyes
//
//  Created by Max Omelchenko on 03/02/20.
//  Copyright © 2020 Max Omelchenko. All rights reserved.
//

import Combine
import Foundation

class Observable<T>: ObservableObject {
    let subject = PassthroughSubject<T, Never>()
    var value: T {
        didSet {
            subject.send(value)
        }
    }
    
    init(_ initValue: T) {
        self.value = initValue
    }
}
