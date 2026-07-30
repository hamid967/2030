import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("يومي", systemImage: "sparkles") }
            CalendarView()
                .tabItem { Label("التقويم", systemImage: "calendar") }
            CheckInView()
                .tabItem { Label("تسجيل", systemImage: "square.and.pencil") }
            LearnView()
                .tabItem { Label("دليل وريف", systemImage: "book") }
            CommunityView()
                .tabItem { Label("المجتمع", systemImage: "person.3") }
        }
        .tint(WarifBrand.berry)
    }
}

#Preview {
    MainTabView()
        .environment(AppEnvironment.preview())
        .environment(\.layoutDirection, .rightToLeft)
}
