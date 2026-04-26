//
//  ScheduleCollectionViewLayout.swift
//  ScheduleImpl
//
//  Created by 23ji
//

import UIKit

// MARK: - ScheduleCollectionViewLayout
/// 스케줄 화면의 UICollectionView의 섹션별 뼈대를 정의하는 클래스입니다.
/// 총 4개의 섹션(상단/달력/카테고리/스케줄리스트)으로 나누어 각기 다른 레이아웃과 스크롤 방식을 가집니다.
final class ScheduleCollectionViewLayout {
    
    /// 메인 뷰 컨트롤러에서 사용할 Compositional Layout 객체를 생성해 반환합니다.
    static func create() -> UICollectionViewCompositionalLayout {
        // 섹션 인덱스(0, 1, 2, 3)에 따라 서로 다른 형태의 그룹 배치를 리턴합니다.
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            switch sectionIndex {
            case 0: // Section 0: 상단 타이틀 ("공구일정") 및 필터 버튼
                return createTopSection()
            case 1: // Section 1: 달력 영역 (가운데 거대 컨테이너)
                return createCalendarSection()
            case 2: // Section 2: 카테고리 기차 (전체, 뷰티, 푸드...)
                return createCategorySection()
            default: // Section 3: 하단 실제 스케줄 나열 (스케줄 리스트)
                return createScheduleListSection()
            }
        }
    }
    
    // MARK: - 1. Top Section (상단)
    
    // 화면 맨 위에 위치할 "공구일정" 글씨와, 그 밑에 다크/화이트 컬러의 필터 버튼이 들어가는 세로형 섹션
    private static func createTopSection() -> NSCollectionLayoutSection {
        // 아이템: 너비는 100%(fractionalWidth 1.0), 높이는 대략 50으로 추정(estimated)하며 내부 컨텐츠 양에 따라 자동 조절됨
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // 그룹: 위 아이템들을 '세로(vertical)'로 묶어줄 그룹. 그룹의 폭도 100% 보장.
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        // 아이템 위아래 사이에 10px 씩 고정된 틈을 줌 (타이틀과 버튼 사이 간격)
        group.interItemSpacing = .fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        // 섹션 겉부분에 패딩(Insets)을 주어서 화면 끝에서 살짝 떨어지게 함
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 20, trailing: 0)
        return section
    }

    // MARK: - 2. Calendar Section (달력)
    
    // 달력 섹션. 버그를 방지하기 위해 일반 아이템 리스트가 아니라 '단일 컨테이너 셀' 1개를 넣는 고정 섹션
    private static func createCalendarSection() -> NSCollectionLayoutSection {
        // 아이템: 그룹 내부 크기를 꽉(1.0) 채워서 1개의 컨테이너 셀만 들어갈 수 있도록 조치
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // 그룹: 달력 전체 뷰의 높이를 60px(아이템들 높이)로 꽉 잡음
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(60))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 20, trailing: 0)
        
        // 달력 머리 위에 올릴 "2026년 4월 < >" 글씨와 요일 표시기(월화수목금토일) 공간 마련
        // 헤더 뷰의 높이를 90px로 넉넉하게 잡음
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(90))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top // 섹션의 맨 위에 헤더를 붙임
        )
        // 섹션에 헤더 아이템 바인딩
        section.boundarySupplementaryItems = [header]
        return section
    }

    // MARK: - 3. Category Section (카테고리 칩)
    
    // 동그란 사각형의 칩들을 사용자가 옆으로 쭉쭉 밀 수 있는 가로형 카테고리 섹션
    private static func createCategorySection() -> NSCollectionLayoutSection {
        // 단일 칩 아이템 (그룹 크기 내부에 꽉 차게)
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // 가로 80px, 세로 90px 크기의 작은 직사각형 그룹으로 만듦 
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(80), heightDimension: .absolute(90))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        // 화면 바깥으로 스크롤 넘침(Carousel Effect)을 구현하기 위해 Orthogonal 옵션을 'continuous(스무스한 관성 이동)'로 설정!
        section.orthogonalScrollingBehavior = .continuous
        // 각 카테고리 칩 간의 좌우 간격 16px
        section.interGroupSpacing = 16
        // 화면 양 끝 마진값 적용 (좌 20, 우 20)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20)
        return section
    }

    // MARK: - 4. Schedule List Section (오늘의 일정)
    
    // 최종 결과물인 스케줄 썸네일 카드들이 세로로 쭉 나열되는 기본 형태의 섹션
    private static func createScheduleListSection() -> NSCollectionLayoutSection {
        // 각 스케줄 카드 높이는 대략 100px. 안드로이드 Wrap_Content 처럼 유동적으로 조절됨
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        // 카드들 위아래 사이 간격 16px
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 30, trailing: 0)
        
        // "오늘의 일정" 이라고 적힐 글씨와 회색 구분선이 들어갈 헤더 디자인 영역(높이 50px)
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
}
