//
//  LazyChillingBundle.swift
//  LazyChilling
//
//  Created by Allen on 2025/4/14.
//

import WidgetKit
import SwiftUI

@main
struct LazyChillingBundle: WidgetBundle {
    var body: some Widget {
        LazyChilling()
        LazyChillingControl()
        LazyChillingLiveActivity()
    }
}
