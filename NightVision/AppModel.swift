//
//  AppModel.swift
//  NightVision
//
//  Created by David Ernst on 6/13/26.
//

import SwiftUI

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
    var arkitError: String? = nil

    // Advanced settings
    var dotDensity: Double = 7.0
    var dotSize: Double = 1.0
    var dotsOpacity: Double = 0.2
    var meshOpacity: Double = 0.01 // base mesh
}
