//
//  ScheduleSectionModel.swift
//  ScheduleImpl
//
//  Created by 23ji
//

import Foundation
import UIKit
import AppCore
import Shared_ReactiveX

// 1. 단일 날짜 정보를 담는 구조체 (RxDataSources의 Equatable(동일 데이터 비교) 미지원 이슈로 Tuple 대신 구조체 사용)
struct CalendarDateInfo: Equatable {
    let date: Date           // 화면에 렌더링될 객체화된 실제 날짜
    let isSelected: Bool     // 현재 유저에 의해 포커스되거나 오늘 날짜인지 판별하는 플래그
}

// 2. Schedule 앱 화면에 들어가는 개별 아이템(Cell)들의 종류를 하나의 Enum으로 통일
enum ScheduleSectionItem: IdentifiableType, Equatable {
    case title                                                   // "공구일정" 등 메인 타이틀을 띄워주는 고정 셀
    case filter                                                  // 상단의 다크/화이트 2개짜리 필터 버튼 셀
    case calendarContainer(dates: [CalendarDateInfo], todayIndex: Int) // 스크롤 버그 방지를 위해 가로 달력을 통째로 들고있는 거대 컨테이너 셀
    case category(icon: String, name: String, isSelected: Bool)  // 뷰티, 푸드 등 수평으로 넘어가는 카테고리 알약 버튼 셀
    case schedule(id: String, influencer: String, title: String, color: UIColor, image: String) // 최종 결과물인 스케줄 카드의 세부 정보 데이터 셀

    // 화면이 업데이트될 때 RxDataSources가 똑같은 셀인지 구분하기 위한 고유 식별자 키
    var identity: String {
        switch self {
        case .title: return "title"
        case .filter: return "filter"
        case .calendarContainer: return "calendarContainer"
        case .category(let name, _, _): return "category_\(name)"  // 이름이 무조건 다르므로 이름으로 구분
        case .schedule(let id, _, _, _, _): return "schedule_\(id)" // 고유 아이디 값으로 스케줄 분별
        }
    }
}

// 3. UI 컬렉션뷰의 4방향 나눔통(Section) 정의
enum ScheduleSectionModel: AnimatableSectionModelType {
    case top(items: [ScheduleSectionItem])          // Section 0: 앱 상단의 제목과 분류 스위치 구역
    case calendar(items: [ScheduleSectionItem])     // Section 1: 단 1개의 컨테이너 셀만 품는 캘린더 구역
    case category(items: [ScheduleSectionItem])     // Section 2: 카테고리 동글이 칩들이 나열될 구역
    case scheduleList(items: [ScheduleSectionItem]) // Section 3: 실제 스케줄 카드가 스크롤 아래쪽으로 계속 나열될 세로 구역

    typealias Item = ScheduleSectionItem

    // RxDataSources 필수 구현: 내부 아이템들을 배열로 뱉어주는 계산 프로퍼티
    var items: [ScheduleSectionItem] {
        switch self {
        case .top(let items): return items
        case .calendar(let items): return items
        case .category(let items): return items
        case .scheduleList(let items): return items
        }
    }

    // 각각의 Section 영역 자체도 바뀔 수 있으므로 영역의 고유 식별 지정
    var identity: String {
        switch self {
        case .top: return "top_section"
        case .calendar: return "calendar_section"
        case .category: return "category_section"
        case .scheduleList: return "scheduleList_section"
        }
    }

    // 리로드될 때 기존 구조를 유지시키며 내용물 Item들만 바꿔 끼워주는 생성자 로직
    init(original: ScheduleSectionModel, items: [ScheduleSectionItem]) {
        switch original {
        case .top: self = .top(items: items)
        case .calendar: self = .calendar(items: items)
        case .category: self = .category(items: items)
        case .scheduleList: self = .scheduleList(items: items)
        }
    }
}
