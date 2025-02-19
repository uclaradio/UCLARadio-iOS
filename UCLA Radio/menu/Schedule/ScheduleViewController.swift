//
//  ScheduleViewController.swift
//  UCLA Radio
//
//  Created by Christopher Laganiere on 6/3/16.
//  Copyright © 2016 UCLA Student Media. All rights reserved.
//

import Foundation
import UIKit

fileprivate let reuseIdentifier = "ScheduleCell"
fileprivate let headerReuseIdentifier = "ScheduleHeader"

class ScheduleViewController: BaseViewController, APIFetchDelegate, UITableViewDataSource, UITableViewDelegate {
    
    static let storyboardID = "scheduleViewController"
    
    var tableView = UITableView()
    
    var schedule: Schedule?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ScheduleShowCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.register(ScheduleSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: headerReuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        // spicy
        // try just adding anchor contraints like brian in this viewdidload...not doing both this and preferred constraints
        tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 119.0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        tableView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        tableView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0).isActive = true
        tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        
        RadioAPI.fetchSchedule(self)
    }
    
    @objc func goToNavigation() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: NotificationViewController.storyboardID)
        if let notificationViewController = vc as? NotificationViewController {
            navigationController?.pushViewController(notificationViewController, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AnalyticsManager.sharedInstance.trackPageWithValue("Schedule")
        if schedule != nil {
            if NotificationManager.sharedInstance.totalNotificationsOnForSchedule(schedule!) > 0 {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "bell"), style: .plain, target: self, action: #selector(goToNavigation))
            } else {
                self.navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
    func today() -> Int {
        var day =  (Calendar.current as Calendar).component(.weekday, from: Date())
        // 1 = sunday => 0 = sunday, 6 = saturday
        day -= 1
        return day
    }
    
    // MARK: - API Fetch Delegate
    
    func cachedDataAvailable(_ data: Any) {
        updateSchedule(data)
    }
    
    func didFetchData(_ data: Any) {
        updateSchedule(data)
    }
    
    func failedToFetchData(_ error: String) {
        
    }
    
    private func updateSchedule(_ data: Any) {
        if let schedule = data as? Schedule {
            self.schedule = schedule
            tableView.reloadData()
            scrollToToday()
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedule?.showsForDay(section).count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ScheduleShowCell.preferredHeight((indexPath as NSIndexPath).row == self.tableView(tableView, numberOfRowsInSection: (indexPath as NSIndexPath).section) - 1)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if schedule?.showsForDay(section).isEmpty ?? false {
            return 0
        }
        return ScheduleSectionHeaderView.height
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        if let cell = cell as? ScheduleShowCell {
            let lastRowInSection = ((indexPath as NSIndexPath).row == self.tableView(tableView, numberOfRowsInSection: (indexPath as NSIndexPath).section) - 1)
            cell.addBottomPadding = lastRowInSection
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: headerReuseIdentifier)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = UIColor.clear
        return footer
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let show = schedule?.showForIndexPath(indexPath),
            let showCell = cell as? ScheduleShowCell {
            showCell.styleFromShow(show)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let scheduleHeader = view as? ScheduleSectionHeaderView {
            let dayString = Schedule.stringForDay(section)
            scheduleHeader.styleForString(dayString)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let show = schedule?.showForIndexPath(indexPath) else {
            return
        }

        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ShowViewController.storyboardID)
        if let showViewController = vc as? ShowViewController {
            showViewController.show = show
            navigationController?.pushViewController(showViewController, animated: true)
        }
    }

    // MARK: - Layout
    
    func scrollToToday() {
        if let showCount = schedule?.showsForDay(today()).count,
            showCount > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: today()), at: .top, animated: false)
        }
    }
    
    func preferredConstraints() -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        let views = ["table": tableView]
        print("hi\nhi\nhi\nhi\nhi\nhi\nhi\nhi\nhi\nhi\nhi\nhi\nhi\nhi\nhi\nhi\nhi\nhi\n")
//        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[table]|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[table]|", options: [], metrics: nil, views: views)
        return constraints
    }
}
