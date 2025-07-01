import Foundation
import Combine
import CoreLocation

class AppointmentViewModel: ObservableObject {
    @Published var pendingAppointments: [Appointment] = []
    @Published var upcomingAppointments: [Appointment] = []
    @Published var pastAppointments: [Appointment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedDoctor: User?
    @Published var selectedDate = Date()
    @Published var selectedTime = Date()
    @Published var symptoms = ""
    @Published var estimatedDuration = 30
    
    func loadAppointments(forUserId userId: String, userType: UserType) {
        isLoading = true
        
        // In a real app, you would fetch appointments from Firestore
        // For this example, we'll create mock data
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            
            // Create mock appointments
            let mockAppointments = self.createMockAppointments(forUserId: userId, userType: userType)
            
            // Filter appointments by status
            self.pendingAppointments = mockAppointments.filter { $0.status == .requested }
            self.upcomingAppointments = mockAppointments.filter { 
                $0.status == .accepted && $0.scheduledTime > Date() 
            }
            self.pastAppointments = mockAppointments.filter {
                $0.status == .completed || $0.scheduledTime < Date()
            }
        }
    }
    
    func bookAppointment(patientId: String, doctorId: String, completion: @escaping (Bool) -> Void) {
        guard let doctor = selectedDoctor else {
            errorMessage = "No doctor selected"
            completion(false)
            return
        }
        
        isLoading = true
        
        // Combine date and time
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: selectedTime)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        
        guard let scheduledTime = Calendar.current.date(from: dateComponents) else {
            errorMessage = "Invalid date or time"
            isLoading = false
            completion(false)
            return
        }
        
        // In a real app, you would save this to Firestore
        let newAppointment = Appointment(
            patientId: patientId,
            doctorId: doctorId,
            scheduledTime: scheduledTime,
            estimatedDuration: estimatedDuration,
            status: .requested,
            symptoms: symptoms,
            location: Appointment.GeoPoint(latitude: 37.7749, longitude: -122.4194),
            address: "123 Main St, San Francisco, CA",
            fee: doctor.hourlyRate ?? 100.0,
            createdAt: Date(),
            updatedAt: Date(),
            paymentCompleted: false
        )
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            self.pendingAppointments.append(newAppointment)
            completion(true)
        }
    }
    
    func updateAppointmentStatus(appointmentId: String, status: AppointmentStatus, completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        // In a real app, you would update this in Firestore
        // For this example, we'll update our local arrays
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
            
            // Find and update appointment in appropriate array
            if let index = self.pendingAppointments.firstIndex(where: { $0.id == appointmentId }) {
                var appointment = self.pendingAppointments[index]
                appointment.status = status
                appointment.updatedAt = Date()
                
                self.pendingAppointments.remove(at: index)
                
                if status == .accepted {
                    self.upcomingAppointments.append(appointment)
                } else if status == .completed || status == .cancelled {
                    self.pastAppointments.append(appointment)
                }
                
                completion(true)
            } else if let index = self.upcomingAppointments.firstIndex(where: { $0.id == appointmentId }) {
                var appointment = self.upcomingAppointments[index]
                appointment.status = status
                appointment.updatedAt = Date()
                
                self.upcomingAppointments.remove(at: index)
                
                if status == .completed || status == .cancelled {
                    self.pastAppointments.append(appointment)
                }
                
                completion(true)
            } else {
                self.errorMessage = "Appointment not found"
                completion(false)
            }
        }
    }
    
    private func createMockAppointments(forUserId userId: String, userType: UserType) -> [Appointment] {
        let now = Date()
        let calendar = Calendar.current
        
        // Create dates for different appointments
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
        let nextWeek = calendar.date(byAdding: .day, value: 7, to: now)!
        
        let appointments = [
            Appointment(
                id: "appt1",
                patientId: userType == .patient ? userId : "patient1",
                doctorId: userType == .doctor ? userId : "doctor1",
                scheduledTime: yesterday,
                estimatedDuration: 30,
                status: .completed,
                symptoms: "Fever and headache",
                notes: "Patient responded well to treatment",
                location: Appointment.GeoPoint(latitude: 37.7749, longitude: -122.4194),
                address: "123 Main St, San Francisco, CA",
                fee: 120.0,
                createdAt: calendar.date(byAdding: .day, value: -3, to: now)!,
                updatedAt: yesterday,
                paymentCompleted: true
            ),
            Appointment(
                id: "appt2",
                patientId: userType == .patient ? userId : "patient2",
                doctorId: userType == .doctor ? userId : "doctor2",
                scheduledTime: tomorrow,
                estimatedDuration: 45,
                status: .accepted,
                symptoms: "Back pain",
                location: Appointment.GeoPoint(latitude: 37.7833, longitude: -122.4167),
                address: "456 Market St, San Francisco, CA",
                fee: 150.0,
                createdAt: calendar.date(byAdding: .day, value: -2, to: now)!,
                updatedAt: now,
                paymentCompleted: false
            ),
            Appointment(
                id: "appt3",
                patientId: userType == .patient ? userId : "patient3",
                doctorId: userType == .doctor ? userId : "doctor3",
                scheduledTime: nextWeek,
                estimatedDuration: 60,
                status: .requested,
                symptoms: "Annual checkup",
                location: Appointment.GeoPoint(latitude: 37.7699, longitude: -122.4269),
                address: "789 Valencia St, San Francisco, CA",
                fee: 200.0,
                createdAt: now,
                updatedAt: now,
                paymentCompleted: false
            )
        ]
        
        return appointments
    }
}