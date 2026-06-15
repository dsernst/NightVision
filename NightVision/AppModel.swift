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
    var dotsOpacity: Double = 0.6
    var dotDensity: Double = 20
    var dotSize: Double = 0.008

    var meshOpacity: Double = 0.05 // base mesh
}
