import Foundation
import Combine

final class UsersViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var hasError = false
    @Published var error: UserError?
    @Published private(set) var isRefreshing = false
    private var cancellables = Set<AnyCancellable>() //set - ensuring there's only one of each publisher
    
    func fetchUsers() {
        let usersUrlString = "https://jsonplaceholder.typicode.com/users"
        
        if let url = URL(string: usersUrlString) {
            isRefreshing = true
            
            URLSession
                .shared
                .dataTaskPublisher(for: url)
                .receive(on: DispatchQueue.main) // Q: Why main thread?
                // .map(\.data) // use keypath to access "data" property from response
                // .decode(type: [User].self, decoder: JSONDecoder()) // decode into User using JSONDecoder
                .tryMap { result in // can throw errors
                    guard let response = result.response as? HTTPURLResponse,
                          response.statusCode >= 200,
                          response.statusCode <= 300 else {
                        throw UserError.invalidStatusCode
                    }

                    let decoder = JSONDecoder()
                    guard let users = try? decoder.decode([User].self, from: result.data) else {
                        throw UserError.failedToDecode // triggers case .failure below
                    }
                    return users
                }
                .sink { [weak self] result in // listen to when published has finished/cancelled
                    
                    defer { self?.isRefreshing = false } // defer - last thing to be executed int his scope, usually used to ensure ending actions (e.g. closing a file)
                    
                    switch result {
                    case .failure(let error):
                        self?.hasError = true
                        self?.error = UserError.custom(error: error)
                    default: break
                    }
                } receiveValue: { [weak self] users in
                    self?.users = users // set to source of truth
                }
                .store(in: &cancellables) // ensures result of sink is kept alive & not disposed of
        }
    }
}

extension UsersViewModel {
    enum UserError: LocalizedError {
        case custom(error: Error)
        case invalidStatusCode
        case failedToDecode
        
        var errorDescription: String? {
            switch self {
            case .failedToDecode:
                return "Failed to decode response"
            case .custom(let error):
                return error.localizedDescription
            case .invalidStatusCode:
                return "Request falls within an invalid range"
            }
        }
    }
}
