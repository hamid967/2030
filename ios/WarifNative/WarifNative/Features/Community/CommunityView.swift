import SwiftUI

struct CommunityView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var spaces: [CommunitySpace] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Image("CommunityHero")
                        .resizable().scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: WarifBrand.cardCornerRadius))
                        .accessibilityLabel("مجتمع نسائي سعودي داعم")
                    WarifCard {
                        Text("تجارب العضوات لا تُعتبر تشخيصاً أو وصفة علاجية.")
                            .font(.footnote).foregroundStyle(WarifBrand.berryStrong)
                    }
                    ForEach(spaces) { space in
                        NavigationLink {
                            CommunitySpaceView(space: space)
                        } label: {
                            WarifCard {
                                Text(space.nameAr).font(.headline)
                                    .foregroundStyle(WarifBrand.textPlum)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("المجتمع")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task { spaces = await environment.community.spaces() }
    }
}

struct CommunitySpaceView: View {
    @Environment(AppEnvironment.self) private var environment
    let space: CommunitySpace
    @State private var posts: [CommunityPost] = []

    var body: some View {
        List(posts) { post in
            VStack(alignment: .leading, spacing: 6) {
                Text(post.pseudonym).font(.subheadline.weight(.semibold))
                Text(post.bodyAr)
                Label("\(post.reactions)", systemImage: "heart")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
        .navigationTitle(space.nameAr)
        .task { posts = await environment.community.posts(in: space.id) }
    }
}

#Preview {
    CommunityView()
        .environment(AppEnvironment.preview())
        .environment(\.layoutDirection, .rightToLeft)
}
