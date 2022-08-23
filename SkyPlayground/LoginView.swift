import SwiftUI

enum FocusedField {
    case email
    case password
}

// - MARK: Modifiers

extension View {
    func conditionalModifier<M1, M2>(_ condition: Bool, _ truthyModifier: M1, falsyModifier: M2) -> some View where M1: ViewModifier, M2: ViewModifier {
        Group {
            if condition {
                self.modifier(truthyModifier)
            } else {
                self.modifier(falsyModifier)
            }
        }
    }
}

struct CTAButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.body)
            .padding([.top, .bottom], 8)
            .padding([.leading, .trailing], 12)
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .background(.yellow)
            .cornerRadius(8)
    }
}

struct LoginTextInputModifier<T>: ViewModifier where T: Hashable {
    private let isEnabled: Bool
    private var focused: FocusState<T>.Binding
    private let focusedState: T
    
    init(isEnabled: Bool, focused: FocusState<T>.Binding, focusedState: T) {
        self.isEnabled = isEnabled
        self.focused = focused
        self.focusedState = focusedState
    }
    
    func body(content: Content) -> some View {
        content
            .disabled(!isEnabled)
            .font(.body)
            .focused(focused, equals: focusedState)
            .padding(EdgeInsets(top: 12, leading: 7, bottom: 12, trailing: 7))
            .border(.gray, width: 1)
            .cornerRadius(8)
    }
}

struct LoginView: View {
    
    @FocusState
    private var focused: FocusedField?
    @State
    private var email: String = ""
    @State
    private var canTypePassword = false
    @State
    private var password: String = ""
    
    var body: some View {
        
        ZStack {
            
            Color.black.ignoresSafeArea()
            Image("peacock-login")
            
            Group {
                VStack(alignment: .center, spacing: 24) {
                    VStack(alignment: .leading, spacing: 4) {
                        if canTypePassword {
                            Text("e-mail")
                                .font(.caption)
                        }
                        TextField("E-mail", text: $email)
                            .modifier(LoginTextInputModifier(isEnabled: canTypePassword,
                                                             focused: $focused,
                                                             focusedState: .email))
                    }
                    if canTypePassword {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("password")
                                .font(.caption)
                            TextField("password", text: $password)
                                .modifier(LoginTextInputModifier(isEnabled: true,
                                                                 focused: $focused,
                                                                 focusedState: .password))
                        }
                    }
                    
                    Button(action: onLoginPressed) {
                        Text(verbatim: "Login")
                            .modifier(CTAButtonModifier())
                    }
                }
                .padding([.leading, .trailing], 32)
                .padding([.top, .bottom], 24)
                .background(.white)
            }
            .background(ignoresSafeAreaEdges: [.leading, .trailing])
            .cornerRadius(8)
            .padding([.leading, .trailing], 24)
        }
        .onTapGesture(perform: removeFocus)
    }
    
    private func onLoginPressed() { }
    
    private func onCancelPressed() { }
    
    private func removeFocus() { self.focused = nil }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
        //            .environmentObject(KeyboardVisibilityObserver())
    }
}
