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

    // Advanced settings
    var meshOpacity: Double = 0.01 // base mesh
    var dotsOpacity: Double = 0.4
    var dotDensity: Double = 96
    var dotSize: Double = 0.001
}
