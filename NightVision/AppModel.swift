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
    var dotsOpacity: Double = 0.20
    var dotDensity: Double = 61
    var dotSize: Double = 0.005

    var meshOpacity: Double = 0.05 // base mesh
}
