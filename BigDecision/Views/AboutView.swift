import SwiftUI

// This file is a bridge to maintain compatibility while transitioning to AboutDetailView
// It simply re-exports the AboutDetailView to avoid compilation errors

typealias AboutView = AboutDetailView
// Note: FeatureRow is already defined in WelcomeView.swift, so we don't create a typealias for it
