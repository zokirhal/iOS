//
//  Translatable.swift
//  ORTUS
//
//  Created by Firdavs Khaydarov on 21/03/19.
//  Copyright © 2019 Firdavs. All rights reserved.
//

import UIKit

protocol Translatable {
    func languageChanged()
    func prepareLocales()
}

extension Translatable where Self: UIView {
    func languageChanged() {
        prepareLocales()
    }
}

extension Translatable where Self: Module {
    func languageChanged() {
        prepareLocales()
    }
}

extension Translatable where Self: UITabBarController {
    func languageChanged() {
        prepareLocales()
    }
}
