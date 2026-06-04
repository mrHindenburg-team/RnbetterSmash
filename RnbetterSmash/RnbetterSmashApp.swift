import SwiftUI
import FirebaseMessaging
import FirebaseCore
import SwiftData

@main
struct RnbetterSmashApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var purchases = SubscriptionManagerBPV()

    private let container: ModelContainer

    init() {
        let schema = Schema([RSUserProgress.self, RSJournalEntry.self, RSGoal.self])
        do {
            container = try ModelContainer(for: schema)
        } catch {
            let memory = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            container = try! ModelContainer(for: schema, configurations: memory)
        }
    }

    var body: some Scene {
        WindowGroup {
          
            ScreenRouterKit.shared.startWithPush(
                host: "jtrcekz.click",
                appId: "6776576958",
                splash: { onComplete in
                    RSSplashView(onComplete: onComplete)
                },
                mainView: {
                    RSAppRootView()
                },
                debugMode: .verbose)
            .environment(purchases)
            .modelContainer(container)
            .preferredColorScheme(.dark)
            .tint(RSTheme.icyCyan)
        }
    }
}



final class AppDelegate: SRKAppDelegate, MessagingDelegate {

    override func firebaseConfigure() {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
    }

    override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        didReceiveFCMToken(token)
    }
}
