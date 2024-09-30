import Combine
import SwiftUI

class SubscriberViewModel: ObservableObject {
    
    @Published var count: Int = 0
    var cancellables = Set<AnyCancellable>() // for mult cancellables
    
    @Published var textFieldText: String = ""
    @Published var textIsValid: Bool = false
    
    @Published var showButton: Bool = false
    
    init() {
        setupTimer()
        addTextFieldSubscriber()
    }
    
    func addTextFieldSubscriber() {
        $textFieldText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main) // waits 0.5 before running rest of the code - commonly used with text fields/search
        .map { text -> Bool in
            text.count > 3
        }
        //.assign(to: \.textIsValid, on: self)
        .sink(receiveValue: { [weak self] isValid in
            // using .sink over .assign is preferred bc of weak self
            self?.textIsValid = isValid
        })
        .store(in: &cancellables)
    }
    
    func setupTimer() {
        Timer // acts like a publisher
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                count += 1
                
                if count >= 10 { // cancel timer at 10
                    for item in cancellables {
                        item.cancel()
                    }
                }
                
            }
            .store(in: &cancellables) // store publisher in cancellables
    }
}

struct SubscriberView: View {
    @StateObject var vm = SubscriberViewModel()
    
    var body: some View {
        VStack {
            Text("\(vm.count)")
                .font(.largeTitle)
            
            Text(vm.textIsValid.description)
            
            TextField("Type something here...", text: $vm.textFieldText)
                .padding()
                .frame(height: 55)
                .background(.cyan)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay(alignment: .trailing) {
                    ZStack {
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                            .opacity(vm.textFieldText.count < 1 
                                     ?  0.0 
                                     : vm.textIsValid ? 0.0 : 1.0)
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                            .opacity(!vm.textIsValid ? 0.0 : 1.0)
                    }
                    .font(.title)
                    .bold()
                    .padding(.trailing)
                }
            Button(action: {
                //showButton
            }, label: {
                Text("Button".uppercased())
            })
        }
        .padding()
    }
}

#Preview {
    SubscriberView()
}
