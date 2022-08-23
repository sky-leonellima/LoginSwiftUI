import SwiftUI

// - MARK: Modifiers

struct CTAButtonModifier: ViewModifier {
    
    @Environment(\.isEnabled)
    private var isEnabled: Bool
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 14, weight: .medium))
            .padding([.top, .bottom], 16)
            .padding([.leading, .trailing], 12)
            .frame(maxWidth: .infinity)
            .foregroundColor(isEnabled ? .black : Color("disabled-text"))
            .background(isEnabled ? Color("yellow") : Color("gray"))
            .cornerRadius(4)
    }
}

enum FocusedField {
    case email
    case password
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
            .font(.system(size: 14, weight: .bold))
            .focused(focused, equals: focusedState)
            .padding(EdgeInsets(top: 12, leading: 7, bottom: 12, trailing: 7))
            .modifier(BorderedView(cornerRadius: 4, width: isEnabled ? 1 : 0))
//            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}

struct BorderedView: ViewModifier {
    private let cornerRadius: CGFloat
    private let width: CGFloat
    private let color: Color
    
    init(cornerRadius: CGFloat, width: CGFloat, color: Color = .gray) {
        self.cornerRadius = cornerRadius
        self.width = width
        self.color = color
    }
    func body(content: Content) -> some View {
        content.overlay(RoundedRectangle(cornerRadius: cornerRadius,
                                         style: .continuous)
            .stroke(color, lineWidth: width))
    }
}

// - MARK: Views

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
            VStack(alignment: .leading, spacing: 48) {
                Text("First, enter your email")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                Group {
                    VStack(alignment: .center, spacing: 24) {
                        VStack(alignment: .leading, spacing: 4) {
                            if canTypePassword {
                                Text("Email")
                                    .font(.caption)
                            }
                            TextField("Email", text: $email)
                                .modifier(LoginTextInputModifier(isEnabled: !canTypePassword,
                                                                 focused: $focused,
                                                                 focusedState: .email))
                        }
                        if canTypePassword {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Password")
                                    .font(.caption)
                                SecureField("Password", text: $password)
                                    .textContentType(.password)
                                    .modifier(LoginTextInputModifier(isEnabled: true,
                                                                     focused: $focused,
                                                                     focusedState: .password))
                            }
                        }
                        
                        Button(action: onLoginPressed) {
                            Text(verbatim: "Continue")
                                .modifier(CTAButtonModifier())
                        }.disabled(!hasValidEmail(email: email))
                    }
                    .padding([.leading, .trailing], 32)
                    .padding([.top, .bottom], 24)
                    .background(.white)
                }
                .background(ignoresSafeAreaEdges: [.leading, .trailing])
                .cornerRadius(8)
            }
            .padding([.leading, .trailing], 24)
        }
        .onTapGesture(perform: removeFocus)
    }
    
    private func onLoginPressed() {
        canTypePassword = true
    }
    
    private func onCancelPressed() { }
    
    private func removeFocus() { self.focused = nil }
    
    private func hasValidEmail(email: String) -> Bool {
        let emailPattern = #"^\S+@\S+\.\S+$"#
        let result = email.range(
            of: emailPattern,
            options: .regularExpression
        )
        return (result != nil)
    }
}


// - MARK: Preview

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .previewInterfaceOrientation(.portrait)
        //            .environmentObject(KeyboardVisibilityObserver())
    }
}
