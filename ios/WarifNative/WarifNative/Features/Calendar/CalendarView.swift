import SwiftUI

struct CalendarView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var profile: CycleProfile?

    private let calendar = WarifCalendar.riyadh

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    WarifCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("تقويم الدورة").font(.headline)
                            Text("المواعيد المعروضة تقديرية، ولا يُعتمد عليها وحدها لمنع الحمل أو تأكيد الإباضة.")
                                .font(.footnote).foregroundStyle(WarifBrand.berryStrong)
                        }
                    }
                    monthGrid
                    legend
                }
                .padding()
            }
            .navigationTitle("التقويم")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task { profile = await environment.cycle.getProfile() }
    }

    private var monthGrid: some View {
        let today = Date()
        let comps = calendar.dateComponents([.year, .month], from: today)
        let first = calendar.date(from: comps) ?? today
        let range = calendar.range(of: .day, in: .month, for: first) ?? 1..<29
        let leading = (calendar.component(.weekday, from: first) - calendar.firstWeekday + 7) % 7
        let cells = Array(repeating: 0, count: leading) + Array(range)

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(Array(cells.enumerated()), id: \.offset) { _, day in
                if day == 0 {
                    Color.clear.frame(height: 40)
                } else {
                    dayCell(day: day, first: first, today: today)
                }
            }
        }
    }

    private func dayCell(day: Int, first: Date, today: Date) -> some View {
        let date = calendar.date(byAdding: .day, value: day - 1, to: first) ?? first
        let isPeriod = isPeriodDay(date)
        let isToday = calendar.isDate(date, inSameDayAs: today)
        return Text("\(day)")
            .font(.callout)
            .frame(maxWidth: .infinity, minHeight: 40)
            .background(isPeriod ? WarifBrand.rose.opacity(0.25) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(WarifBrand.berry, lineWidth: isToday ? 2 : 0)
            )
    }

    private func isPeriodDay(_ date: Date) -> Bool {
        guard let profile else { return false }
        let elapsed = WarifCalendar.days(from: profile.lastPeriodStart, to: date, calendar)
        let length = max(profile.cycleLength, 1)
        let into = ((elapsed % length) + length) % length
        return into < profile.periodLength
    }

    private var legend: some View {
        HStack(spacing: 16) {
            Label("الطمث", systemImage: "circle.fill").foregroundStyle(WarifBrand.rose)
            Label("اليوم", systemImage: "circle").foregroundStyle(WarifBrand.berry)
        }
        .font(.footnote)
    }
}

#Preview {
    CalendarView()
        .environment(AppEnvironment.preview())
        .environment(\.layoutDirection, .rightToLeft)
}
