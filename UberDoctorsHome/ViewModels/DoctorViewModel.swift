import Foundation
import Combine

class DoctorViewModel: ObservableObject {
    @Published var doctors: [User] = []
    @Published var filteredDoctors: [User] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedSpecialization: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Set up search filtering
        $searchText
            .combineLatest($selectedSpecialization)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] (searchText, specialization) in
                self?.filterDoctors(searchText: searchText, specialization: specialization)
            }
            .store(in: &cancellables)
    }
    
    func fetchDoctors() {
        isLoading = true
        
        // In a real app, you would fetch doctors from Firestore
        // For this example, we'll create mock data
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            self.doctors = self.createMockDoctors()
            self.filteredDoctors = self.doctors
        }
    }
    
    private func filterDoctors(searchText: String, specialization: String?) {
        if searchText.isEmpty && specialization == nil {
            filteredDoctors = doctors
            return
        }
        
        filteredDoctors = doctors.filter { doctor in
            let matchesSearch = searchText.isEmpty || 
                doctor.fullName.lowercased().contains(searchText.lowercased())
            
            let matchesSpecialization = specialization == nil ||