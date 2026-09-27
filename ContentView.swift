
import SwiftUI
import UIKit

@main
struct ZENOBLACKApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}

struct ContentView: View {
    @State private var key = ""
    @State private var activated = false
    @State private var showInfo = false

    private var deviceName: String {
        UIDevice.current.localizedModel
    }

    private var iosVersion: String {
        UIDevice.current.systemVersion
    }

    private var hwid: String {
        let service = "com.zenoblack.device"
        let account = "installation-id"
        if let data = Keychain.read(service: service, account: account),
           let value = String(data: data, encoding: .utf8) {
            return value
        }
        let value = UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(12)
        Keychain.save(Data(value.utf8), service: service, account: account)
        return String(value)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(red: 0.01, green: 0.06, blue: 0.11), Color.black],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("ZENOBLACK")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                            Text("VIP LICENSE SYSTEM")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.cyan)
                        }
                        Spacer()
                        Image(systemName: "shield.lefthalf.filled")
                            .font(.title2)
                            .foregroundStyle(.cyan)
                    }

                    statusCard

                    VStack(spacing: 12) {
                        TextField("Nhập License Key", text: $key)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                            .padding()
                            .background(.white.opacity(0.07))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.cyan.opacity(0.35)))

                        Button {
                            activated = !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        } label: {
                            Label(activated ? "ĐÃ KÍCH HOẠT" : "KÍCH HOẠT LICENSE",
                                  systemImage: activated ? "checkmark.circle.fill" : "key.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .font(.headline)
                        }
                        .buttonStyle(NeonButtonStyle())
                    }

                    gameButton(title: "FREE FIRE", subtitle: "MỞ GAME", icon: "gamecontroller.fill", scheme: "freefire://")
                    gameButton(title: "FREE FIRE MAX", subtitle: "MỞ GAME", icon: "flame.fill", scheme: "freefiremax://")

                    deviceCard

                    Button {
                        showInfo = true
                    } label: {
                        Label("Cài đặt & Thông tin", systemImage: "gearshape.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(GlassButtonStyle())
                }
                .padding(18)
            }
        }
        .sheet(isPresented: $showInfo) {
            SettingsView(hwid: hwid, device: deviceName, ios: iosVersion)
                .preferredColorScheme(.dark)
        }
    }

    private var statusCard: some View {
        HStack {
            Circle()
                .fill(activated ? Color.green : Color.orange)
                .frame(width: 10, height: 10)
                .shadow(color: activated ? .green : .orange, radius: 8)
            VStack(alignment: .leading) {
                Text(activated ? "LICENSE ACTIVE" : "CHƯA KÍCH HOẠT")
                    .font(.headline)
                Text(activated ? "Thiết bị đã được xác thực" : "Nhập key để kích hoạt")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "lock.shield.fill")
                .foregroundStyle(.cyan)
        }
        .padding()
        .background(.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(.cyan.opacity(0.22)))
    }

    private var deviceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("THÔNG TIN THIẾT BỊ")
                .font(.caption.weight(.bold))
                .foregroundStyle(.cyan)
            infoRow("Thiết bị", deviceName)
            infoRow("iOS", iosVersion)
            infoRow("HWID", hwid)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func infoRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.subheadline.weight(.semibold))
        }
    }

    private func gameButton(title: String, subtitle: String, icon: String, scheme: String) -> some View {
        Button {
            if let url = URL(string: scheme) {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon).font(.title2)
                VStack(alignment: .leading) {
                    Text(title).font(.headline)
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "arrow.up.right")
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(GlassButtonStyle())
    }
}

struct NeonButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.black)
            .background(
                LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(.white.opacity(configuration.isPressed ? 0.12 : 0.07))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.cyan.opacity(0.25)))
    }
}

struct SettingsView: View {
    let hwid: String
    let device: String
    let ios: String
    var body: some View {
        NavigationStack {
            List {
                Section("ZENOBLACK") {
                    LabeledContent("Thiết bị", value: device)
                    LabeledContent("iOS", value: ios)
                    LabeledContent("HWID", value: hwid)
                }
                Section("Thông tin") {
                    Text("Phiên bản mẫu: 1.0")
                    Text("License/HWID được lưu riêng cho từng cài đặt.")
                }
            }
            .navigationTitle("Cài đặt")
        }
    }
}

enum Keychain {
    static func save(_ data: Data, service: String, account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    static func read(service: String, account: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess else { return nil }
        return result as? Data
    }
}
