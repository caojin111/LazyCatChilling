//
//  LazyChillingLiveActivity.swift
//  LazyChilling
//
//  Created by Allen on 2025/4/14.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct LazyChillingAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct LazyChillingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LazyChillingAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension LazyChillingAttributes {
    fileprivate static var preview: LazyChillingAttributes {
        LazyChillingAttributes(name: "World")
    }
}

extension LazyChillingAttributes.ContentState {
    fileprivate static var smiley: LazyChillingAttributes.ContentState {
        LazyChillingAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: LazyChillingAttributes.ContentState {
         LazyChillingAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: LazyChillingAttributes.preview) {
   LazyChillingLiveActivity()
} contentStates: {
    LazyChillingAttributes.ContentState.smiley
    LazyChillingAttributes.ContentState.starEyes
}
