import Foundation
import Firebase
import Combine

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var userType: UserType = .patient
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        userSession = Auth.auth().currentUser
        fetchUser()
    }
    
    func signIn(withEmail email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            self.userSession = result?.user
            self.fetchUser()
        }
    }
    
    func signUp(withEmail email: String, password: String, fullName: String, phoneNumber: String, userType: UserType) {
        isLoading = true
        errorMessage = nil
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            guard let user = result?.user else { return }
            self.userSession = user
            
            let newUser = User(
                id: user.uid,
                fullName: fullName,
                email: email,
                phoneNumber: phoneNumber,
                userType: userType
            )
            
            // In a real app, you would save this user to Firestore
            self.currentUser = newUser
            self.userType = userType
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func fetchUser() {
        guard let uid = userSession?.uid else { return }
        
        // In a real app, you would fetch the user from Firestore
        // For this example, we'll create a mock user
        let mockUser = User(
            id: uid,
            fullName: "John Doe",
            email: "john@example.com",
            phoneNumber: "123-456-7890",
            userType: .patient,
            address: "123 Main St"
        )
        
        self.currentUser = mockUser
        self.userType = mockUser.userType
    }
}