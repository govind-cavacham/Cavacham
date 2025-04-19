//
//  BlurView.swift
//  Cavacham
//
//  Created by Govind Pathak on 18/04/25.
//

import SwiftUI

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}//
//  BlurView.swift
//  Cavacham
//
//  Created by Govind Pathak on 18/04/25.
//

