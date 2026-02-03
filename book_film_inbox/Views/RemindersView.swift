//
//  RemindersView.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 28.01.2026.
//
import SwiftUI

struct RemindersView: View {
    @EnvironmentObject var viewModel: ReminderViewModel
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var notificationService = NotificationService.shared
    @State private var pendingItemIdToOpen: UUID?

    @State private var showingAddSheet = false
    @State private var selectedItem: ReminderItem?
    @State private var searchText: String = ""
    
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    
    @State private var selectedFilterType: ReminderType? = nil
    @State private var selectedFilterExpired: Bool = false

    var filteredItems: [ReminderItem] {
        viewModel.filteredItems(typeFilter: selectedFilterType, isExpiring: selectedFilterExpired, text: searchText)
    }
    
    var body: some View {
        NavigationStack {
            
            List {
                ForEach(filteredItems) { item in
                    ReminderItemCard(item: item)
                        .listRowInsets(EdgeInsets(top: 3, leading: 16, bottom: 3, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .onTapGesture {
                            selectedItem = item
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            if item.renewalType != .lifetime && item.renewalType != .none {
                                Button() {
                                    do {
                                        try viewModel.prolongate(item)
                                    } catch {
                                        errorMessage = error.localizedDescription
                                        showError = true
                                    }
                                } label: {
                                    Label(".button.renewed", systemImage: "repeat.circle")
                                }
                                .tint(.yellow)
                            }
                        }
                        .alert(".title.error", isPresented: $showError) {
                            Button(".button.ok", role: .cancel) {}
                        } message: {
                            Text(errorMessage)
                        }
                }
            }
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
            .listStyle(.plain)
            .overlay {
                if filteredItems.isEmpty {
                    VStack {
                        Spacer()
                        Text(".label.common.list_empty")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic))
            .navigationTitle(".title.reminder.list")
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
                AddEditReminderSheet(viewModel: viewModel, item: nil)
            }
            .sheet(item: $selectedItem) { item in
                ReadonlyReminderSheet(viewModel: viewModel, item: item)
            }
            .onReceive(NotificationCenter.default.publisher(for: .openReminderDetails)) { notification in
                guard let itemId = notification.userInfo?["itemId"] as? UUID else { return }
                if let item = viewModel.findById(itemId) {
                    selectedItem = item
                } else {
                    pendingItemIdToOpen = itemId
                }
            }
            .onAppear {
                // if there pinding id - open it
                if let pendingId = pendingItemIdToOpen,
                   let item = viewModel.findById(pendingId) {
                    selectedItem = item
                    pendingItemIdToOpen = nil
                }
            }
            .task {
                // check notification status on screen open
                await notificationService.checkAuthorizationStatus()
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                // check whether applicaion become active (e.g., from being foregrounded)
                if newPhase == .active {
                    Task {
                        await notificationService.checkAuthorizationStatus()
                    }
                }
            }
        }
    }
    
    // MARK: - Filter Section
    
    private var filterSection: some View {
        HStack(spacing: 8) {
            
            FilterButton(
                iconName: ReminderType.license.icon,
                count: viewModel.count(typeFilter: .license, isExpiring: false),
                isSelected: selectedFilterType == .license
            ) {
                selectedFilterType = (selectedFilterType == .license) ? nil : .license
            }
            
            FilterButton(
                iconName: ReminderType.subscription.icon,
                count: viewModel.count(typeFilter: .subscription, isExpiring: false),
                isSelected: selectedFilterType == .subscription
            ) {
                selectedFilterType = (selectedFilterType == .subscription) ? nil : .subscription
            }
            
            Spacer()
            
            FilterButton(
                iconName: "hourglass.bottomhalf.fill",
                count: viewModel.count(typeFilter: selectedFilterType, isExpiring: true),
                isSelected: selectedFilterExpired
            ) {
                selectedFilterExpired = !selectedFilterExpired
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


extension ReminderItem {
    var statusColor: Color {
        if isExpired { return .gray }
        if isExpiringCriticalSoon { return .orange }
        if isExpiringSoon { return .yellow }
        return .green
    }
    
    var formattedRenewalType: String {
        let prefix = String(localized: ".label.reminder.renew_policy_prefix")
        
        switch renewalType {
        case .custom:
            guard let periodValue = customPeriodValue,
                  let unit = customPeriodUnit else {
                return prefix
            }
            
            let each = String(localized: ".label.reminder.renew_policy_each")
            let unitName = String.localizedStringWithFormat(
                NSLocalizedString(unit.displayNameSuffix, comment: ""),
                periodValue
            )
            
            return "\(prefix) \(each) \(periodValue) \(unitName)"
            
        default:
            return "\(prefix) \(renewalType.displayName)"
        }
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
