//
//  RemindersView.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 28.01.2026.
//
import SwiftUI
import SwiftData

struct RemindersView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(ReminderPersistenceService.self) private var persistenceService
    @Environment(NavigationManager.self) private var navigation
    
    private var notificationService = NotificationService.shared
    
    @State private var reminderFilter: ReminderFilterState = ReminderFilterState()
    @State private var showingAddSheet = false
    @State private var showingFilterSheet = false
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    
    var body: some View {
        RemindersListContent(
            filterState: reminderFilter,
            persistenceService: persistenceService,
            onTap: { item in navigation.remindersPath.append(ReminderRoute.details(item.id)) },
            onProlongate: { item in
                do {
                    try persistenceService.prolongate(item)
                } catch {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        )
        .safeAreaInset(edge: .top) {
            if notificationService.authorizationStatus == .denied {
                notificationWarningBanner
            }
        }
        .navigationTitle(Tab.reminders.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    FilterToolbarButton(filterState: $reminderFilter) {
                        showingFilterSheet = true
                    }
                    
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .accessibilityHidden(true)
                    }
                    .accessibilityLabel(Text(".accessibility.reminders.add"))
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddEditReminderSheet(persistenceService: persistenceService, item: nil)
        }
        .sheet(isPresented: $showingFilterSheet) {
            ReminderFilterSheet(filterState: $reminderFilter)
        }
        .alert(".title.error", isPresented: $showError) {
            Button(".button.ok", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .task {
            await notificationService.checkAuthorizationStatus()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                Task {
                    await notificationService.checkAuthorizationStatus()
                }
            }
        }
        
    }
    
    private var notificationWarningBanner: some View {
        Button {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "bell.slash.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .accessibilityHidden(true)
                
                Text(".label.reminder.notifications_disabled")
                    .font(.caption)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.orange.opacity(0.15))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .accessibilityLabel(Text(".label.reminder.notifications_disabled"))
        .accessibilityHint(Text(".accessibility.reminders.notifications_disabled_hint"))
    }
}

 // MARK: - List Content with @Query

struct RemindersListContent: View {
    let filterState: ReminderFilterState
    let persistenceService: ReminderPersistenceService
    let onTap: (ReminderItem) -> Void
    let onProlongate: (ReminderItem) -> Void
    
    @Query private var allReminders: [ReminderItem]
    
    init(
        filterState: ReminderFilterState,
        persistenceService: ReminderPersistenceService,
        onTap: @escaping (ReminderItem) -> Void,
        onProlongate: @escaping (ReminderItem) -> Void
    ) {
        self.filterState = filterState
        self.persistenceService = persistenceService
        self.onTap = onTap
        self.onProlongate = onProlongate

        let reminderType: ReminderType? = switch filterState.itemType {
        case .subscriptions: .subscription
        case .licences: .license
        case .all: nil
        }
        
        var predicate: Predicate<ReminderItem>? = nil
        if let reminderType {
            let raw = reminderType.rawValue
            predicate = #Predicate { i in
                i.typeRaw == raw
            }
        }
        
        _allReminders = Query(
            filter: predicate ?? #Predicate { _ in true },
            sort: [SortDescriptor(\.name)]
        )
    }
    
    private var filteredReminders: [ReminderItem] {
        allReminders.filter { item in
            !filterState.isExpiringSoon || item.isExpiringOrExpired
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredReminders) { item in
                ReminderItemCard(item: item)
                    .listRowInsets(EdgeInsets(top: 3, leading: 16, bottom: 3, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onTap(item)
                    }
                    .accessibilityAddTraits(.isButton)
                    .accessibilityHint(Text(".accessibility.reminders.open_hint"))
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        if item.renewalType != .lifetime && item.renewalType != .none {
                            Button {
                                onProlongate(item)
                            } label: {
                                Label(".button.renewed", systemImage: "repeat.circle")
                            }
                            .tint(.yellow)
                        }
                    }
            }
        }
        .listStyle(.plain)
        .overlay {
            if filteredReminders.isEmpty {
                VStack {
                    Spacer()
                    Text(".label.common.list_empty")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
    }
}

enum ReminderTypeFilter: String, FilterTypeOption {
    case all
    case subscriptions
    case licences

    var id: String { rawValue }
    var label: String {
        switch self {
        case .all: return String(localized: ".type.common.all")
        case .subscriptions: return String(localized: ".type.reminder.subscriptions")
        case .licences: return String(localized: ".type.reminder.licenses")
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "rectangle.stack.fill"
        case .subscriptions: return "arrow.triangle.2.circlepath"
        case .licences: return "key.fill"
        }
    }
}

struct ReminderFilterState: CommonFilterState {
    typealias FilterType = ReminderTypeFilter
    
    var itemType: ReminderTypeFilter = .all
    var isExpiringSoon: Bool = false

    var isActive: Bool {
        itemType != .all || isExpiringSoon
    }

    var activeCount: Int {
        var count = 0
        if itemType != .all { count += 1 }
        if isExpiringSoon { count += 1 }
        return count
    }
}

 // MARK: - Extensions

struct ReminderItemHelper {
    static func getColor(_ item: ReminderItem) -> Color {
        if item.isExpired { return .gray }
        if item.isExpiringCriticalSoon { return .orange }
        if item.isExpiringSoon { return .yellow }
        return .green
    }
    
}

extension ReminderType {
    var displayName: LocalizedStringKey {
        switch self {
        case .subscription: return ".badge.reminder.subscription"
        case .license: return ".badge.reminder.license"
        }
    }
}

extension RenewalType {
    var displayName: String {
        switch self {
        case .monthly: return String(localized: ".type.reminder.renew.month")
        case .yearly: return String(localized: ".type.reminder.renew.year")
        case .lifetime: return String(localized: ".type.reminder.renew.lifetime")
        case .custom: return String(localized: ".type.reminder.renew.custom")
        case .none: return String(localized: ".type.reminder.renew.na")
        }
    }
}

extension PeriodUnit {
    var displayNameSuffix: String {
        switch self {
        case .days: return String(localized: ".type.reminder.period.day")
        case .months: return String(localized: ".type.reminder.period.month")
        case .years: return String(localized: ".type.reminder.period.year")
        }
    }
    func displayNamePluralSuffix(amount: Int) -> String {
        switch self {
        case .days: return String(localized: ".type.reminder.period.x_days \(amount)")
        case .months: return String(localized: ".type.reminder.period.x_months \(amount)")
        case .years: return String(localized: ".type.reminder.period.x_years \(amount)")
        }
    }
}
