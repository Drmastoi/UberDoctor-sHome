import Foundation
import FirebaseFirestoreSwift
import CoreLocation

enum AppointmentStatus: String, Codable {
    case requested
    case accepted
    case inProgress
    case completed
    case cancelled
}

struct Appointment: Identifiable, Codable {
    @DocumentID var id: String?
    var patientId: String
    var doctorId: String
    var scheduledTime: Date
    var estimatedDuration: Int // in minutes
    var status: AppointmentStatus
    var symptoms: String
    var notes: String?
    var location: GeoPoint
    var address: String
    var fee: Double
    var createdAt: Date
    var updatedAt: Date
    var paymentCompleted: Bool
    
    struct GeoPoint: Codable {
        var latitude: Double
        var longitude: Double
    }
}