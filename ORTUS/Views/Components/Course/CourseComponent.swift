//
//  CourseComponent.swift
//  ORTUS
//
//  Created by Firdavs Khaydarov on 02/10/19.
//  Copyright © 2019 Firdavs. All rights reserved.
//

import UIKit
import Carbon

struct CourseComponent: IdentifiableComponent {
    var id: String
    var course: Course
    var onSelect: (() -> Void)?
    
    func renderContent() -> CourseComponentView {
        return CourseComponentView()
    }
    
    func render(in content: CourseComponentView) {
        content.onSelect = onSelect
        
        content.imageContainerView.backgroundColor = Asset.Colors.tintColor.color.withAlphaComponent(0.2)
        content.imageView.tintColor = Asset.Colors.tintColor.color
        
        content.imageView.image = Asset.Images.course.image
        content.titleLabel.text = course.name
    }
    
    func referenceSize(in bounds: CGRect) -> CGSize? {
        return CGSize(width: bounds.width, height: 60)
    }
    
    func shouldContentUpdate(with next: CourseComponent) -> Bool {
        return course.id != next.course.id
    }
}
