import Foundation

// Notification for sendRequest failure and success
extension Notification.Name {
    static let sendRequestFailed = Notification.Name("sendRequestFailed")
    static let sendRequestCompleted = Notification.Name("sendRequestCompleted")
}
