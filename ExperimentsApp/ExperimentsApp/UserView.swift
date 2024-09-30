import SwiftUI

struct UserView: View {
    let user: User
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            VStack(alignment: .leading) {
                Text("ID")
                Text("Name")
                Text("Email")
                Text("Company")
            }
            .bold()
            .padding()
            .background(Color.mint)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            VStack(alignment: .leading) {
                Text("\(user.id)")
                Text("\(user.name)")
                Text("\(user.email)")
                Text("\(user.company.name)")
            }
        }
    }
}

#Preview {
    UserView(
        user: User(
            id: 1111,
            name: "test",
            email: "test",
            company: Company(name: "brr")
        )
    )
}
