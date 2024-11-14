import Foundation

// Wrapper struct for error message, conforming to Identifiable
struct ErrorMessage: Identifiable {
    let id = UUID()
    let message: String
}
