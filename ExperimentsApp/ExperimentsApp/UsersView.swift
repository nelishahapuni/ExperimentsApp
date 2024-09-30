import SwiftUI

struct UsersView: View {
    
    @StateObject private var vm = UsersViewModel()
    
    var body: some View {
        ZStack {
            if vm.isRefreshing {
                ProgressView()
            } else {
                List {
                    ForEach(vm.users, id: \.id) { user in
                        UserView(user: user)
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .navigationTitle("Users")
            }
        }
        .onAppear(perform: vm.fetchUsers)
        .alert(isPresented: $vm.hasError, error: vm.error) {
            Button(action: vm.fetchUsers) {
                Text("Retry")
            }
        }
    }
}

#Preview {
    UsersView()
}
