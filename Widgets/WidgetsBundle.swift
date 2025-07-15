//
//  WidgetsBundle.swift
//  Widgets
//
//  Created by 黃浚銘 on 2025/7/15.
//

import WidgetKit
import SwiftUI

@main
struct WidgetsBundle: WidgetBundle {
    var body: some Widget {
        Widgets()
        WidgetsControl()
        WidgetsLiveActivity()
    }
}
