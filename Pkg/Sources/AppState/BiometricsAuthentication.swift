
import LocalAuthentication

public final class BiometricAuthentication {
    public enum BiometricType {
        case faceID
        case touchID
        case none
    }
    
    public static var isAvailable: Bool {
        return biometricType != .none
    }
    
    public static var biometricType: BiometricType {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            if #available(iOS 11.0, *) {
                switch context.biometryType {
                case .faceID:
                    return .faceID
                case .touchID:
                    return .touchID
                default:
                    return .none
                }
            } else {
                return .touchID
            }
        } else {
            return .none
        }
    }
    
    public static func authenticate(completion: @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            completion(false, error)
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate to access the app") { success, error in
            completion(success, error)
        }
    }
    
    public func authenticate() async throws -> Bool {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw error ?? NSError(domain: "AuthenticationErrorDomain", code: -1, userInfo: nil)
        }
        
        do {
            return try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate to access the app")
        } catch {
            throw error
        }
    }

}
