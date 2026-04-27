//
//  ScheduleReactor.swift
//  ScheduleImpl
// 
//  Created by 23ji
//

import UIKit
import AppCore
import Shared_DI
import Shared_ReactiveX
import ReactorKit // Reactor 프로토콜 사용을 위함

// MARK: - ScheduleReactor
/// 스케줄(공구일정) 화면의 모든 비즈니스 로직과 상태 관리를 전담하는 Reactor 객체입니다.
final class ScheduleReactor: Reactor, FactoryModule {

    // 1. 유저의 상호작용 또는 뷰 컨트롤러의 생명주기 이벤트를 정의 (사용자 입력)
    enum Action {
        // 화면이 처음 로드될 때 (데이터 셋업 트리거)
        case viewDidLoad
        // 달력을 스와이프하거나 화살표를 눌러서 화면에 보이는 "주(Week)"가 변경되었을 때
        case updateVisibleCalendarIndex(Int)
    }

    // 2. Action이 발생한 뒤 상태를 변경하기 전에 거치는 중간 단계 (상태 변경 명세서)
    enum Mutation {
        // 네트워크 로딩 스피너 등의 상태를 지시할 때
        case setLoading(Bool)
        // 컴파일 호환용으로 남겨둔 세팅 액션 (추후 데이터 교체용)
        case setSections([ScheduleSectionModel])
        // 화면 초기 진입 시 전체 뷰를 세팅하고 "오늘 날짜"로 스크롤하라고 View에 알려줌
        case setSectionsAndScroll(sections: [ScheduleSectionModel], scrollIndex: Int)
        // 화면에 보여야 할 최상단 연월("2026년 4월") 및 현재 스크롤 위치 기록
        case setCurrentYearMonth(String, Int)
    }

    // 3. View(화면)에 직접적으로 바인딩되어 뿌려질 모든 데이터들의 집합체 (현재 화면의 모습)
    struct State {
        // 로딩 여부 (아직 미사용)
        var isLoading: Bool = false
        // 화면을 그리는 4개의 섹션(상단, 캘린더, 카테고리, 일정 리스트) 데이터
        var sections: [ScheduleSectionModel] = []
        // 초기 로드가 끝난 후 컬렉션 뷰가 강제로 이동해야 하는 '이번 주'의 Index
        var initialScrollIndex: Int = 0 
        // 유저가 스크롤 중이거나 보고 있는 캘린더의 현재 아이템 인덱스 (페이지 인덱스 * 7)
        var currentVisibleIndex: Int = 0 
        // 좌측 상단에 뜰 커다란 년월 타이틀 ("2026년 4월")
        var currentYearMonth: String = ""
    }

    // 초기 상태값 선언 필수
    let initialState: State = State()

    // 의존성 주입(DI)를 위한 구조체 (현재는 빈 역할이지만 나중에 API Service가 들어올 수 있음)
    struct Dependency {}
    private let dependency: Dependency

    // 초기화 과정에서 의존성을 주입받음
    init(dependency: Dependency, payload: Void) {
        self.dependency = dependency
    }

    // 4. Action -> Mutation 변환 수행 (비즈니스 로직 연산, 타이머 처리를 여기서 수행)
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            // ----------------------------------------------------
            // (1) 섹션 0: 최상단 타이틀과 필터 버튼 영역 데이터 세팅
            // ----------------------------------------------------
            let topSection = ScheduleSectionModel.top(items: [.title, .filter])
            
            // ----------------------------------------------------
            // (2) 섹션 1: 캘린더 영역 데이터 세팅 및 날짜 계산 로직
            // ----------------------------------------------------
            var calendar = Calendar.current
            calendar.firstWeekday = 2 // iOS 달력 시스템 기준을 월요일(2)로 강제 고정
            
            // 앱이 커버할 수 있는 캘린더의 최초 시작 날짜를 2026년 1월 1일로 가정
            var dateComponents = DateComponents()
            dateComponents.year = 2026
            dateComponents.month = 1
            dateComponents.day = 1
            guard let janFirst2026 = calendar.date(from: dateComponents) else { return .empty() }
            
            // 2026년 1월 1일이 목요일이더라도, 무조건 그 주의 '월요일'로 카운트를 당겨옴
            var startOfCalendar = janFirst2026
            if let interval = calendar.dateInterval(of: .weekOfYear, for: janFirst2026) {
                startOfCalendar = interval.start
            }
            
            // 기준이 되는 "오늘"의 날짜, 그리고 오늘이 포함된 이번 주의 '월요일' 찾기
            let now = Date()
            var startOfCurrentWeek = now
            if let interval = calendar.dateInterval(of: .weekOfYear, for: now) {
                startOfCurrentWeek = interval.start // 이번 주 월요일 0시 0분
            }
            
            let totalWeeks = 150 // 약 3년 치 달력을 한 번에 생성해둠
            var calendarDates: [CalendarDateInfo] = []
            
            // 달력 시작일(25년도)부터 오늘(이번주)까지 총 며칠이 지났는지 수학적으로 차이를 구함
            let daysDiff = calendar.dateComponents([.day], from: startOfCalendar, to: startOfCurrentWeek).day ?? 0
            
            // 그 날짜 차이를 7로 나눈 몫에 7을 곱해서, 정확한 7의 배수(주차의 첫번째 아이템) 위치 획득
            let todayIndex = max(0, (daysDiff / 7) * 7)
            
            // for문을 이용해 모든 요일의 Date 객체를 생성
            for i in 0..<(totalWeeks * 7) {
                // startOfCalendar부터 1일씩 연속적으로 더해서 생성
                let date = calendar.date(byAdding: .day, value: i, to: startOfCalendar) ?? Date()
                let isSelected = calendar.isDate(date, inSameDayAs: now) // 날짜가 '오늘'과 똑같은가? -> 오늘이면 강제 선택 모양
                // RxDataSources 호환용 Struct로 래핑하여 배열에 추가
                calendarDates.append(CalendarDateInfo(date: date, isSelected: isSelected))
            }
            
            // 컨테이너 셀에 방금 생성한 배열과 오늘 날짜 위치 값을 집어넣어 섹션 1을 완성
            let calendarSection = ScheduleSectionModel.calendar(items: [.calendarContainer(dates: calendarDates, todayIndex: todayIndex)])
            
            // ----------------------------------------------------
            // (3) 섹션 2: 뷰티, 푸드 등의 카테고리 칩 버튼 5개 생성
            // ----------------------------------------------------
            let categorySection = ScheduleSectionModel.category(items: [
                .category(icon: "circle.grid.2x2.fill", name: "전체", isSelected: true), // 전체만 주황불 켜두기
                .category(icon: "sparkles", name: "뷰티", isSelected: false),
                .category(icon: "fork.knife", name: "푸드", isSelected: false),
                .category(icon: "bed.double", name: "리빙", isSelected: false),
                .category(icon: "tshirt", name: "패션", isSelected: false)
            ])
            
            // ----------------------------------------------------
            // (4) 섹션 3: 일정 카드가 나열되는 곳 (향후 API 연동 시 실제 데이터가 꽂힐 곳)
            // ----------------------------------------------------
            let listSection = ScheduleSectionModel.scheduleList(items: [
                .schedule(id: "1", influencer: "소윤테이블", title: "프리미엄 한식 다이닝 밀키트 5종 세트", color: UIColor.systemGreen, image: "food"),
                .schedule(id: "2", influencer: "지니", title: "데일리 룩 트렌치 코트 (베이지/블랙)", color: UIColor.systemBlue, image: "fashion"),
                .schedule(id: "3", influencer: "핏보이", title: "프리미엄 웨이 프로틴 2kg + 쉐이커 증정", color: UIColor.systemGreen, image: "health")
            ])
            
            // (5) 생성 완료된 모든 섹션을 던져줌과 동시에, "이번 주"로 자동 스크롤 하도록 Mutation 송출
            return .just(.setSectionsAndScroll(
                sections: [topSection, calendarSection, categorySection, listSection],
                scrollIndex: todayIndex
            ))
            
        case .updateVisibleCalendarIndex(let index):
            // 뷰 컨트롤러에서 "지금 유저가 X번째 아이템 캘린더를 보고있어요" 라고 알려오면 작동
            
            // 현재 내가 쥐고 있는 상태배열에서, 섹션 1 (달력 컨테이너) 추출 시도
            guard currentState.sections.count > 1,
                  case let .calendar(items) = currentState.sections[1] else { return .empty() }
            
            // 달력 컨테이너 안에는 아이템이 1개 뿐이므로 .first 로 가져옴
            if case let .calendarContainer(dates, _) = items.first {
                // 배열 아웃오브바운드 크래시 방지용 최대/최소값 클램핑 안전 연산
                let safeIndex = max(0, min(index, dates.count - 1))
                // 현재 인덱스 위치에 해당하는 바로 그 해당일 Date 객체를 가져옴
                let date = dates[safeIndex].date
                
                // 년/월 표시용 텍스트 변환 (예: 2026년 4월)
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy년 M월"
                let yearMonthString = formatter.string(from: date)
                
                // 연월 텍스트 표기 및 현재 인덱스를 최신화하라는 명령을 하달
                return .just(.setCurrentYearMonth(yearMonthString, safeIndex))
            }
            return .empty()
        }
    }

    // 5. Mutation -> State 변경 적용 (실제로 화면에 그리기 전 데이터가 변경되는 최종 관문)
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state // 상태는 항상 불변성을 지녀야 하므로 복사본 생성 후 변경
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        case .setSections(_):
            break // unused (현재 쓰이지 않는 액션)
        case .setSectionsAndScroll(let sections, let scrollIndex):
            newState.sections = sections
            newState.initialScrollIndex = scrollIndex // 처음 앱 켤 때 바로 이동 시킬 타겟 넘버
            newState.currentVisibleIndex = scrollIndex // 현재 내가 보고있는 것으로 마킹
        case .setCurrentYearMonth(let text, let index):
            newState.currentYearMonth = text // 새로 헤더에 쓸 "년월"
            newState.currentVisibleIndex = index // 최신화된 내비게이션 인덱스 기록 (< > 버튼 등에 씀)
        }
        return newState // 완전히 갱신된 새로운 상태본을 뷰에 방출
    }
}
