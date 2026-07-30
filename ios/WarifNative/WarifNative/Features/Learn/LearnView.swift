import SwiftUI

struct LearnView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var articles: [Article] = []
    @State private var query = ""

    private var filtered: [Article] {
        guard !query.isEmpty else { return articles }
        return articles.filter {
            $0.titleAr.contains(query) || $0.titleEn.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            List(filtered) { article in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(article.titleAr).font(.headline)
                        if article.experimental {
                            Text("تجريبي")
                                .font(.caption2)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(WarifBrand.rose.opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }
                    Text(article.summaryAr)
                        .font(.subheadline).foregroundStyle(.secondary)
                    Text("\(article.readingMinutes) دقائق قراءة · \(article.reviewer ?? "بانتظار المراجعة الطبية")")
                        .font(.caption).foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
            .searchable(text: $query, prompt: "ابحثي في الدليل")
            .navigationTitle("دليل وريف")
        }
        .task { articles = await environment.content.articles() }
    }
}

#Preview {
    LearnView()
        .environment(AppEnvironment.preview())
        .environment(\.layoutDirection, .rightToLeft)
}
