import Foundation
import FirebaseFirestoreSwift

enum UserType: String, Codable {
    case patient
    case doctor
}

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var fullName: String
    var email: String
    var phoneNumber: String
    var userType: UserType
    var profileImageUrl: String?
    var address: String?
    var dateOfBirth: Date?
    
    // Doctor specific fields
    var specialization: String?
    var licenseNumber: String?
    var yearsOfExperience: Int?
    var hourlyRate: Double?
    var bio: String?
    var rating: Double?
    var isAvailable: Bool?
}