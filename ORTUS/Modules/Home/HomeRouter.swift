//
//  HomeRouter.swift
//  ORTUS
//
//  Created by Firdavs Khaydarov on 04/02/20.
//  Copyright (c) 2020 Firdavs. All rights reserved.
//

final class HomeRouter: Router<HomeViewController>, SettingsRoute, NewsRoute, GradesRoute, SemesterRoute {
    typealias Routes = SettingsRoute & NewsRoute & GradesRoute & SemesterRoute & Closable
    
    var transition: Transition {
        return PushTransition()
    }
}
