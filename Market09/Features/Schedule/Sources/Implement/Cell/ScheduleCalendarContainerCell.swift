//
//  ScheduleCalendarContainerCell.swift
//  ScheduleImpl
//
//  Created by 23ji
//

import UIKit

import SnapKit
import Shared_ReactiveX
import RxSwift

final class ScheduleCalendarContainerCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var dates: [CalendarDateInfo] = []
    private var disposeBag = DisposeBag()
    
    // 외부에 스크롤 결과 연/월 텍스트, 날짜 전달 등을 위한 콜백
    var onPageChanged: ((Int) -> Void)?
    
    let calendarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(calendarCollectionView)
        calendarCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        calendarCollectionView.register(ScheduleCalendarDateCell.self, forCellWithReuseIdentifier: String(describing: ScheduleCalendarDateCell.self))
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
    }
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(dates: [CalendarDateInfo], todayIndex: Int) {
        self.dates = dates
        calendarCollectionView.reloadData()
        
        // 확실한 스크롤 보장
        DispatchQueue.main.async {
            guard self.dates.count > todayIndex else { return }
            self.calendarCollectionView.scrollToItem(at: IndexPath(item: todayIndex, section: 0), at: .left, animated: false)
            self.onPageChanged?(todayIndex)
        }
    }
    
    func scrollByWeek(offset: Int) {
        // offset: -1 or +1 for weeks
        let currentOffset = calendarCollectionView.contentOffset.x
        let pageWidth = calendarCollectionView.bounds.width
        let visiblePageIndex = Int(round(currentOffset / pageWidth))
        let targetPageIndex = visiblePageIndex + offset
        
        let targetX = CGFloat(targetPageIndex) * pageWidth
        if targetX >= 0 && targetX <= calendarCollectionView.contentSize.width - pageWidth {
            calendarCollectionView.setContentOffset(CGPoint(x: targetX, y: 0), animated: true)
            onPageChanged?(targetPageIndex * 7)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.width
        if pageWidth > 0 {
            let pageIndex = Int(round(scrollView.contentOffset.x / pageWidth))
            onPageChanged?(pageIndex * 7)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCalendarDateCell.self), for: indexPath) as! ScheduleCalendarDateCell
        cell.configure(date: dates[indexPath.item].date, isSelected: dates[indexPath.item].isSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 정확히 7개로 쪼개기
        return CGSize(width: collectionView.bounds.width / 7.0, height: 60)
    }
}
