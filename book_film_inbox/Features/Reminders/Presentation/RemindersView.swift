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
    
    @State private var showingAddSheet = false
    @State private var searchText: String = ""
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    @State private var selectedFilterType: ReminderType? = nil
    @State private var selectedFilterExpired: Bool = false
    
    var body: some View {
            RemindersListContent(
                filterType: selectedFilterType,
                isExpiring: selectedFilterExpired,
                searchText: searchText,
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
                VStack(spacing: 0) {
                    filterSection
                        .padding(.vertical, 4)
                        .padding(.horizontal, 16)
                        .background(Color(uiColor: .systemBackground))
                    
                    if notificationService.authorizationStatus == .denied {
                        notificationWarningBanner
                            .padding(.horizontal, 16)
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic))
            .navigationTitle(Tab.reminders.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddEditReminderSheet(persistenceService: persistenceService, item: nil)
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
    
    // MARK: - Filter Section
    
    private var filterSection: some View {
        HStack(spacing: 8) {
            FilterButton(
                iconName: ReminderType.license.icon,
                predicate: persistenceService.makeFilterPredicate(typeFilter: .license, text: searchText),
                isSelected: selectedFilterType == .license,
                action: {
                    selectedFilterType = (selectedFilterType == .license) ? nil : .license
                }
            )

            FilterButton(
                iconName: ReminderType.subscription.icon,
                predicate: persistenceService.makeFilterPredicate(typeFilter: .subscription, text: searchText),
                isSelected: selectedFilterType == .subscription,
                action: {
                    selectedFilterType = (selectedFilterType == .subscription) ? nil : .subscription
                }
            )

            Spacer()
            
            FilterButton(
                iconName: "hourglass.bottomhalf.fill",
                predicate: persistenceService.makeFilterPredicate(typeFilter: selectedFilterType, text: searchText),
                postSearchFilter: { !selectedFilterExpired || $0.isExpiringOrExpired },
                isSelected: selectedFilterExpired,
                action: {
                    selectedFilterExpired = !selectedFilterExpired
                }
            )

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
                
                Text(".label.reminder.notifications_disabled")
                    .font(.caption)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.orange.opacity(0.15))
        }
        .buttonStyle(.plain)
    }
}

 // MARK: - List Content with @Query

struct RemindersListContent: View {
    let filterType: ReminderType?
    let isExpiring: Bool
    let searchText: String
    let persistenceService: ReminderPersistenceService
    let onTap: (ReminderItem) -> Void
    let onProlongate: (ReminderItem) -> Void
    
    @Query private var allReminders: [ReminderItem]
    
    init(
        filterType: ReminderType?,
        isExpiring: Bool,
        searchText: String,
        persistenceService: ReminderPersistenceService,
        onTap: @escaping (ReminderItem) -> Void,
        onProlongate: @escaping (ReminderItem) -> Void
    ) {
        self.filterType = filterType
        self.isExpiring = isExpiring
        self.searchText = searchText
        self.persistenceService = persistenceService
        self.onTap = onTap
        self.onProlongate = onProlongate
        
        let predicate = persistenceService.makeFilterPredicate(typeFilter: filterType, text: searchText)
        
        _allReminders = Query(
            filter: predicate ?? #Predicate { _ in true },
            sort: [SortDescriptor(\.name)]
        )
    }
    
    private var filteredReminders: [ReminderItem] {
        allReminders.filter { !isExpiring || $0.isExpiringOrExpired }
    }
    
    var body: some View {
        List {
            ForEach(filteredReminders) { item in
                ReminderItemCard(item: item)
                    .listRowInsets(EdgeInsets(top: 3, leading: 16, bottom: 3, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .onTapGesture {
                        onTap(item)
                    }
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
}
