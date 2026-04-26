//
//  ScheduleViewController.swift
//  ScheduleImpl
//
//  Created by 23ji
//

import UIKit
import AppCore
import DesignSystem
import Shared_DI
import Shared_ReactiveX
import Shared_UI

// MARK: - ScheduleViewController
/// 스케줄 탭의 진입점이자 메인 뷰 컨트롤러입니다. ReactorKit의 View 프로토콜을 따라 상태 바인딩을 수행합니다.
final class ScheduleViewController: UIViewController, FactoryModule, View {
    
    // MARK: - Properties
    
    // RxSwift 구독들을 관리하는 가방, 뷰가 파괴될 때(deinit) 모든 바인딩을 함께 메모리 상에서 해제합니다.
    var disposeBag = DisposeBag()

    // MARK: - UI Components
    
    // 레이아웃이 설정된 UICollectionView를 지연(lazy) 생성합니다.
    private lazy var collectionView: UICollectionView = {
        // ScheduleCollectionViewLayout 객체에서 반환하는 CompositionalLayout 설정을 적용합니다.
        let cv = UICollectionView(
            frame: .zero,
            collectionViewLayout: ScheduleCollectionViewLayout.create()
        )
        // 다크모드/라이트모드 대응되는 기본 배경색 설정
        cv.backgroundColor = .systemBackground
        
        // 만들어둔 각종 Custom Cell을 컬렉션 뷰에 모두 등록해둡니다.
        // String(describing:)을 통해 클래스 이름 문자열 그대로 Identifier를 지정합니다.
        cv.register(ScheduleTitleCell.self, forCellWithReuseIdentifier: String(describing: ScheduleTitleCell.self)) // "공구일정" 라벨 셀
        cv.register(ScheduleFilterCell.self, forCellWithReuseIdentifier: String(describing: ScheduleFilterCell.self)) // 필터버튼 셀
        cv.register(ScheduleCalendarContainerCell.self, forCellWithReuseIdentifier: String(describing: ScheduleCalendarContainerCell.self)) // 달력 컨테이너 셀
        cv.register(ScheduleCategoryCell.self, forCellWithReuseIdentifier: String(describing: ScheduleCategoryCell.self)) // 뷰티, 푸드 등 둥근 카테고리 셀
        cv.register(ScheduleCardCell.self, forCellWithReuseIdentifier: String(describing: ScheduleCardCell.self)) // 실제 스케줄 리스트 카드 셀
        
        // 보조 뷰(Header)들도 식별자와 함께 등록합니다.
        cv.register(ScheduleCalendarHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: String(describing: ScheduleCalendarHeaderView.self)) // 예: "2026년 4월" 헤더
        cv.register(ScheduleListHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: String(describing: ScheduleListHeaderView.self)) // 예: "오늘의 일정" 헤더
        
        // iOS 자동 여백 조절 기능 해제(안전 영역에 직접 맞추기 위함)
        cv.contentInsetAdjustmentBehavior = .never
        return cv
    }()

    // MARK: - Init
    
    // 외부(AppDI 등)에서 들어올 의존성을 선언합니다. 이 경우는 스케줄 리액터 객체가 필수적으로 필요합니다.
    struct Dependency {
        let reactor: ScheduleReactor
    }

    // 의존성을 주입받아 모듈을 초기화합니다.
    init(dependency: Dependency, payload: Void) {
        super.init(nibName: nil, bundle: nil)
        // 프로토콜(View)에 정의된 self.reactor에 주입받은 리액터를 넣으면, 
        // 이때 내부적으로 bind(reactor:) 함수가 자동으로 호출됩니다!
        self.reactor = dependency.reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // 스토리보드 사용하지 않으므로 에러로 막아둠
    }

    // MARK: - Lifecycle
    
    // 뷰 컨트롤러의 화면이 메모리에 로딩 완료되었을 때 실행
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        setupLayout() // 뷰 계층 구조 및 오토레이아웃 설정 트리거
    }
    
    // MARK: - Setup
    
    // UI 컴포넌트들을 화면(View) 계층에 올리고 위치를 잡아주는 함수
    private func setupLayout() {
        view.addSubview(collectionView) // 컬렉션 뷰를 메인 뷰에 추가
        
        // 컬렉션 뷰가 화면의 안전 영역(Safe Area)을 꽉 채우도록 설정 (SnapKit 사용)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
  
    // MARK: - Bind
    
    // ReactorKit 의 View 프로토콜 핵심 함수. 리액터와 UI 간의 이벤트 교류를 세팅합니다.
    func bind(reactor: ScheduleReactor) {
        
        // ----------------------------------------------------
        // 1. DataSource (셀 그리기 설정)
        // ----------------------------------------------------
        // RxDataSources 라이브러리를 사용하여 애니메이션이 들어간 형태의 DataSource 객체를 만듭니다.
        // 현재는 insert, reload, delete 시의 기본 깜빡임 애니메이션을 모두 .none(없음)으로 꺼두었습니다.
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<ScheduleSectionModel>(
            animationConfiguration: .init(insertAnimation: .none, reloadAnimation: .none, deleteAnimation: .none),
            
            // 각 섹션 아이템의 케이스별로 어떤 셀 구조체를 만들고 리턴할지 여기서 정합니다.
            configureCell: { dataSource, collectionView, indexPath, item in
                switch item {
                case .title:
                    // 타이틀 셀 렌더링
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleTitleCell.self), for: indexPath) as! ScheduleTitleCell
                    return cell
                case .filter:
                    // 그룹핑 필터 버튼 렌더링
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleFilterCell.self), for: indexPath) as! ScheduleFilterCell
                    return cell
                case let .calendarContainer(dates, todayIndex):
                    // 달력 전체를 감싸는 컨테이너 셀 렌더링 (가장 핵심)
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCalendarContainerCell.self), for: indexPath) as! ScheduleCalendarContainerCell
                    // 날짜 배열과 오늘의 초기 인덱스를 넘겨서 내부에 달력이 구성되도록 지시
                    cell.configure(dates: dates, todayIndex: todayIndex)
                    
                    // 내부 달력이 스크롤되면, 현재 인덱스가 몇 번째인지 리액터로 콜백(Action 발송) 해줍니다.
                    cell.onPageChanged = { [weak self] index in
                        self?.reactor?.action.onNext(.updateVisibleCalendarIndex(index))
                    }
                    return cell
                case let .category(icon, name, isSelected):
                    // 카테고리 셀 (선택 됨/안됨에 따라 색깔 처리 로직 존재)
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCategoryCell.self), for: indexPath) as! ScheduleCategoryCell
                    cell.configure(icon: icon, name: name, isSelected: isSelected)
                    return cell
                case let .schedule(_, influencer, title, color, _):
                    // 하단에 뜰 카드 리스트
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCardCell.self), for: indexPath) as! ScheduleCardCell
                    cell.configure(title: title, influencer: influencer, color: color)
                    return cell
                }
            },
            
            // 각 섹션 구역마다 어떤 헤더(SupplementaryView)를 달아줄지 정합니다.
            configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
                // 만약 헤더(SectionHeader)를 그려야 하는 요청이라면
                if kind == UICollectionView.elementKindSectionHeader {
                    if indexPath.section == 1 {
                        // Section 1: 달력 영역의 헤더 (상단에 연/월과 버튼들이 들어있음)
                        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: ScheduleCalendarHeaderView.self), for: indexPath) as! ScheduleCalendarHeaderView
                        
                        // 현재 텍스트값(상태)이 존재하면 즉시 연/월 타이틀 적용
                        if let text = self.reactor?.currentState.currentYearMonth, !text.isEmpty {
                            header.titleLabel.text = text
                        }
                        
                        // < (왼쪽) 버튼을 누르면 달력 컨테이너에 -1 주(Week) 만큼 스크롤 하라고 명령
                        header.leftButton.rx.tap
                            .subscribe(onNext: { [weak self] in
                                self?.scrollContainerByWeek(offset: -1)
                            })
                            .disposed(by: header.disposeBag)
                            
                        // > (오른쪽) 버튼 누르면 달력 +1 주 스크롤
                        header.rightButton.rx.tap
                            .subscribe(onNext: { [weak self] in
                                self?.scrollContainerByWeek(offset: 1)
                            })
                            .disposed(by: header.disposeBag)
                            
                        return header
                        
                    } else if indexPath.section == 3 {
                        // Section 3: "오늘의 일정" 이라고 적힌 구분선과 글씨 헤더
                        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: ScheduleListHeaderView.self), for: indexPath) as! ScheduleListHeaderView
                        return header
                    }
                }
                // 나머지는 빈 뷰를 던져줌
                return UICollectionReusableView()
            }
        )

        // ----------------------------------------------------
        // 2. Action (뷰 -> 리액터로 던지는 행동)
        // ----------------------------------------------------

        // Bind 스코프 진입 즉시 한 번만 "viewDidLoad"라는 이벤트를 리액터 단에 발송합니다.
        Observable.just(Reactor.Action.viewDidLoad)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        // ----------------------------------------------------
        // 3. State (리액터 -> 뷰로 받는 상태 변화)
        // ----------------------------------------------------

        // [중요: 방어 코드] 기존 Delegate가 남아있어서 생기는 Multiple Bind Assertion Crash 방지를 위함
        self.collectionView.dataSource = nil
        
        // 리액터의 Sections 배열 상태가 변경되면 이를 즉시 관찰(observe)하여 컬렉션뷰의 아이템으로 Bind(바인딩) 합니다!
        reactor.state.map(\.sections)
            .observe(on: MainScheduler.instance) // 딜레이를 주면 초기 스크롤에 실패할 수 있으므로 메인 스레드에서 무조건 즉시 실행
            .bind(to: self.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
            
        // 리액터가 파악한 현재 가로 페이징 위치의 "2026년 X월" 텍스트가 바뀔 때만(distinct) 실행
        reactor.state.map(\.currentYearMonth)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                guard let self = self, !text.isEmpty else { return }
                
                // 화면에 뿌려놓은 1번 섹션(달력)의 상위 헤더 뷰 인스턴스(객체)를 찾아옵니다
                let indexPath = IndexPath(item: 0, section: 1)
                guard let header = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: indexPath) as? ScheduleCalendarHeaderView else { return }
                // 찾은 헤더뷰의 라벨 텍스트를 즉각 교체합니다
                header.titleLabel.text = text
            })
            .disposed(by: self.disposeBag)
    }
    
    // MARK: - Method (헬퍼 메서드 모음)
    
    /// ViewController의 버튼 터치 이벤트를, 내부에 품겨져있는 CalendarContainerCell 로 전달해 실질적인 동작(스크롤)을 수행하도록 토스하는 함수입니다.
    private func scrollContainerByWeek(offset: Int) {
        // Section 1 의 첫 번째 아이템(단일 달력 컨테이너)을 메모리 상에서 가져옴
        guard let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? ScheduleCalendarContainerCell else { return }
        // 컨테이너가 자체적으로 갖고 있는 주 단위 스크롤 함수를 호출 (-1 또는 1)
        cell.scrollByWeek(offset: offset)
    }
}
