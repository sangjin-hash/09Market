//
//  HomeCreatePostViewController.swift
//  Home
//
//  Created by Sangjin Lee
//

import PhotosUI
import UIKit

import AppCore
import DesignSystem
import Domain
import Shared_DI
import Shared_ReactiveX
import Shared_UI
import Util

final class HomeCreatePostViewController: UIViewController, FactoryModule {

    // MARK: - Init

    struct Dependency {
        let reactor: HomeCreatePostReactor
    }

    var disposeBag = DisposeBag()

    required init(dependency: Dependency, payload: Void) {
        super.init(nibName: nil, bundle: nil)
        defer { self.reactor = dependency.reactor }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - UI

    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.keyboardDismissMode = .onDrag
    }

    private let contentView = UIView()

    private let influencerSectionHeader = HomeCreatePostViewController.makeSectionHeader(
        icon: "person.crop.circle.badge.magnifyingglass",
        title: Strings.CreatePost.sectionInfluencer,
        isRequired: false
    )

    private let influencerTextField = HomeCreatePostViewController.makeTextField(
        placeholder: Strings.CreatePost.influencerPlaceholder
    )

    private let imageSectionHeader = HomeCreatePostViewController.makeSectionHeader(
        icon: "square.and.arrow.up",
        title: Strings.CreatePost.sectionProductImage,
        isRequired: false
    )

    private let imageUploadButton = UIButton(type: .system).then {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.titleLabel?.numberOfLines = 0
        $0.titleLabel?.textAlignment = .center
        $0.setTitleColor(.tertiaryLabel, for: .normal)
        $0.setTitle("\(Strings.CreatePost.imageAddButton)", for: .normal)
    }

    private let imageUploadDashedLayer = CAShapeLayer().then {
        $0.strokeColor = UIColor.systemGray4.cgColor
        $0.fillColor = UIColor.clear.cgColor
        $0.lineWidth = 1
        $0.lineDashPattern = [4, 3]
    }

    private let productNameSectionHeader = HomeCreatePostViewController.makeSectionHeader(
        icon: "shippingbox",
        title: Strings.CreatePost.sectionProductName,
        isRequired: true
    )

    private let productNameTextField = HomeCreatePostViewController.makeTextField(
        placeholder: Strings.CreatePost.productNamePlaceholder
    )

    private let priceSectionHeader = HomeCreatePostViewController.makeSectionHeader(
        icon: "dollarsign",
        title: Strings.CreatePost.sectionPrice,
        isRequired: true
    )

    private let priceTextField = HomeCreatePostViewController.makeTextField(placeholder: "0").then {
        $0.keyboardType = .numberPad
    }

    private let categorySectionHeader = HomeCreatePostViewController.makeSectionHeader(
        icon: "tag",
        title: Strings.CreatePost.sectionCategory,
        isRequired: true
    )

    private let categoryButton = HomeCreatePostViewController.makeSelectButton(
        placeholder: Strings.CreatePost.categoryPlaceholder
    )

    private let categoryChevronImageView = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.down")
        $0.tintColor = .secondaryLabel
        $0.contentMode = .scaleAspectFit
    }

    private let startDateSectionHeader = HomeCreatePostViewController.makeSectionHeader(
        icon: "calendar",
        title: Strings.CreatePost.sectionStartDate,
        isRequired: true
    )

    private let startDateButton = HomeCreatePostViewController.makeSelectButton(
        placeholder: Strings.CreatePost.datePlaceholder
    )

    private let startDateCalendarImageView = UIImageView().then {
        $0.image = UIImage(systemName: "calendar")
        $0.tintColor = Colors.primary
        $0.contentMode = .scaleAspectFit
    }

    private let endDateSectionHeader = HomeCreatePostViewController.makeSectionHeader(
        icon: "calendar",
        title: Strings.CreatePost.sectionEndDate,
        isRequired: true
    )

    private let endDateButton = HomeCreatePostViewController.makeSelectButton(
        placeholder: Strings.CreatePost.datePlaceholder
    )

    private let endDateCalendarImageView = UIImageView().then {
        $0.image = UIImage(systemName: "calendar")
        $0.tintColor = Colors.primary
        $0.contentMode = .scaleAspectFit
    }

    private let submitButton = UIButton(type: .system).then {
        $0.setTitle(Strings.CreatePost.submitButton, for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.backgroundColor = Colors.primary
        $0.layer.cornerRadius = 16
    }


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        setupStyle()
        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.submitButton.pin
            .horizontally(16)
            .bottom(self.view.pin.safeArea.bottom + 12)
            .height(52)

        self.scrollView.pin
            .top(self.view.pin.safeArea.top + 8)
            .horizontally()
            .above(of: self.submitButton)
            .marginBottom(12)

        self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        self.scrollView.verticalScrollIndicatorInsets = self.scrollView.contentInset

        self.contentView.pin
            .top()
            .horizontally()

        self.contentView.flex.layout(mode: .adjustHeight)
        self.scrollView.contentSize = self.contentView.frame.size

        self.imageUploadDashedLayer.frame = self.imageUploadButton.bounds
        self.imageUploadDashedLayer.path = UIBezierPath(
            roundedRect: self.imageUploadButton.bounds,
            cornerRadius: self.imageUploadButton.layer.cornerRadius
        ).cgPath

        self.categoryChevronImageView.pin
            .right(16)
            .vCenter()
            .size(16)

        self.startDateCalendarImageView.pin
            .left(12)
            .vCenter()
            .size(16)

        self.endDateCalendarImageView.pin
            .left(12)
            .vCenter()
            .size(16)
    }

    private func setupLayout() {
        self.view.addSubview(self.scrollView)
        self.view.addSubview(self.submitButton)

        self.scrollView.addSubview(self.contentView)

        self.contentView.flex.paddingHorizontal(16).paddingTop(16).paddingBottom(20).define { flex in
            flex.addItem(self.influencerSectionHeader)
            flex.addItem(self.influencerTextField).height(52).marginTop(8)

            flex.addItem(self.imageSectionHeader).marginTop(20)
            flex.addItem(self.imageUploadButton).height(88).marginTop(8)

            flex.addItem(self.productNameSectionHeader).marginTop(20)
            flex.addItem(self.productNameTextField).height(52).marginTop(8)

            flex.addItem(self.priceSectionHeader).marginTop(20)
            flex.addItem(self.priceTextField).height(52).marginTop(8)

            flex.addItem(self.categorySectionHeader).marginTop(20)
            flex.addItem(self.categoryButton).height(52).marginTop(8)

            flex.addItem().direction(.row).marginTop(20).define { row in
                row.addItem().grow(1).shrink(1).define { col in
                    col.addItem(self.startDateSectionHeader)
                    col.addItem(self.startDateButton).height(52).marginTop(8)
                }
                row.addItem().grow(1).shrink(1).marginLeft(10).define { col in
                    col.addItem(self.endDateSectionHeader)
                    col.addItem(self.endDateButton).height(52).marginTop(8)
                }
            }
        }

        self.imageUploadButton.layer.addSublayer(self.imageUploadDashedLayer)
        self.categoryButton.addSubview(self.categoryChevronImageView)
        self.startDateButton.addSubview(self.startDateCalendarImageView)
        self.endDateButton.addSubview(self.endDateCalendarImageView)
    }

    private func setupStyle() {
        self.influencerTextField.addLeftPadding(14)
        self.productNameTextField.addLeftPadding(14)
        self.priceTextField.addLeftPadding(14)
        self.startDateButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 34, bottom: 0, right: 12)
        self.endDateButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 34, bottom: 0, right: 12)
    }
}


// MARK: - Bind

extension HomeCreatePostViewController: View {
    func bind(reactor: HomeCreatePostReactor) {

        // MARK: - Action

        let backgroundTap = UITapGestureRecognizer()
        backgroundTap.cancelsTouchesInView = false
        self.scrollView.addGestureRecognizer(backgroundTap)
        backgroundTap.rx.event
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.view.endEditing(true)
            })
            .disposed(by: self.disposeBag)

        self.influencerTextField.rx.text.orEmpty
            .skip(1)
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.searchInfluencerKeyword($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        self.imageUploadButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                dismissKeyboardThenExecute {
                    reactor.action.onNext(.tapImagePicker)
                }
            })
            .disposed(by: self.disposeBag)

        self.productNameTextField.rx.text.orEmpty
            .skip(1)
            .map { Reactor.Action.inputProductName($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        self.priceTextField.rx.text.orEmpty
            .skip(1)
            .map { Int($0) ?? 0 }
            .map { Reactor.Action.inputPrice($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        self.categoryButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                dismissKeyboardThenExecute { [weak self] in
                    guard let self else { return }
                    self.showCategoryActionSheet(reactor: reactor)
                }
            })
            .disposed(by: self.disposeBag)

        self.startDateButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                dismissKeyboardThenExecute { [weak self] in
                    guard let self else { return }
                    self.showDatePicker(type: .start, reactor: reactor)
                }
            })
            .disposed(by: self.disposeBag)

        self.endDateButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                dismissKeyboardThenExecute { [weak self] in
                    guard let self else { return }
                    self.showDatePicker(type: .end, reactor: reactor)
                }
            })
            .disposed(by: self.disposeBag)

        self.submitButton.rx.tap
            .map { Reactor.Action.tapSubmit }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)


        // MARK: - State

        reactor.state
            .map { $0.isSubmitEnabled }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isEnabled in
                guard let self else { return }
                self.submitButton.isEnabled = isEnabled
                self.submitButton.alpha = isEnabled ? 1.0 : 0.5
            })
            .disposed(by: self.disposeBag)

        reactor.state
            .map { $0.selectedInfluencer }
            .distinctUntilChanged { $0?.id == $1?.id }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] influencer in
                guard let self else { return }
                self.influencerTextField.font = influencer != nil
                    ? .systemFont(ofSize: 16, weight: .semibold)
                    : .systemFont(ofSize: 16)
            })
            .disposed(by: self.disposeBag)

        reactor.state
            .map { $0.selectedCategory }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] category in
                guard let self else { return }
                if let category {
                    self.categoryButton.setTitle(category.rawValue, for: .normal)
                    self.categoryButton.setTitleColor(.label, for: .normal)
                } else {
                    self.categoryButton.setTitle(Strings.CreatePost.categoryPlaceholder, for: .normal)
                    self.categoryButton.setTitleColor(.tertiaryLabel, for: .normal)
                }
            })
            .disposed(by: self.disposeBag)

        reactor.state
            .map { $0.startDate }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] date in
                guard let self else { return }
                updateDateButton(self.startDateButton, date: date)
            })
            .disposed(by: self.disposeBag)

        reactor.state
            .map { $0.endDate }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] date in
                guard let self else { return }
                updateDateButton(self.endDateButton, date: date)
            })
            .disposed(by: self.disposeBag)

        reactor.pulse(\.$error)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                guard let self else { return }
                ErrorDialog.show(on: self, error: error)
            })
            .disposed(by: self.disposeBag)

        reactor.pulse(\.$dismiss)
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.dismiss(animated: true)
            })
            .disposed(by: self.disposeBag)

        reactor.pulse(\.$openImagePicker)
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                presentImagePicker()
            })
            .disposed(by: self.disposeBag)
    }
}


// MARK: - Private Helpers

private extension HomeCreatePostViewController {

    enum DateType { case start, end }

    var hasActiveTextField: Bool {
        return self.influencerTextField.isFirstResponder
            || self.productNameTextField.isFirstResponder
            || self.priceTextField.isFirstResponder
    }

    func dismissKeyboardThenExecute(_ action: @escaping () -> Void) {
        let needsDelay = self.hasActiveTextField
        self.view.endEditing(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + (needsDelay ? 0.3 : 0)) {
            action()
        }
    }

    func showCategoryActionSheet(reactor: HomeCreatePostReactor) {
        let alert = UIAlertController(
            title: Strings.CreatePost.sectionCategory,
            message: nil,
            preferredStyle: .actionSheet
        )
        for category in GroupBuyingCategory.allCases {
            alert.addAction(UIAlertAction(title: category.rawValue, style: .default) { _ in
                reactor.action.onNext(.selectCategory(category))
            })
        }
        alert.addAction(UIAlertAction(title: Strings.Common.cancel, style: .cancel))
        self.present(alert, animated: true)
    }

    func showDatePicker(type: DateType, reactor: HomeCreatePostReactor) {
        let titleText = type == .start
            ? Strings.CreatePost.sectionStartDate
            : Strings.CreatePost.sectionEndDate

        let alert = UIAlertController(
            title: titleText,
            message: "\n\n\n\n\n\n\n",
            preferredStyle: .actionSheet
        )

        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addSubview(picker)

        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 52),
            picker.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            picker.widthAnchor.constraint(equalTo: alert.view.widthAnchor, constant: -8),
            picker.heightAnchor.constraint(equalToConstant: 162)
        ])

        switch type {
        case .start:
            picker.minimumDate = Date()
            picker.date = reactor.currentState.startDate ?? Date()
        case .end:
            let minDate = reactor.currentState.startDate.flatMap {
                Calendar.current.date(byAdding: .day, value: 1, to: $0)
            } ?? Date()
            picker.minimumDate = minDate
            picker.date = reactor.currentState.endDate ?? minDate
        }

        alert.addAction(UIAlertAction(title: Strings.Common.confirm, style: .default) { _ in
            switch type {
            case .start: reactor.action.onNext(.selectStartDate(picker.date))
            case .end: reactor.action.onNext(.selectEndDate(picker.date))
            }
        })
        alert.addAction(UIAlertAction(title: Strings.Common.cancel, style: .cancel))
        self.present(alert, animated: true)
    }

    func updateDateButton(_ button: UIButton, date: Date?) {
        if let date {
            button.setTitle(Formatters.createPostDate.string(from: date), for: .normal)
            button.setTitleColor(.label, for: .normal)
        } else {
            button.setTitle(Strings.CreatePost.datePlaceholder, for: .normal)
            button.setTitleColor(.tertiaryLabel, for: .normal)
        }
    }

    func presentImagePicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        self.present(picker, animated: true)
    }

    static func makeSectionHeader(icon: String, title: String, isRequired: Bool) -> UIView {
        let container = UIView()
        let iconView = UIImageView().then {
            $0.image = UIImage(systemName: icon)
            $0.tintColor = Colors.primary
            $0.contentMode = .scaleAspectFit
        }
        let titleLabel = UILabel().then {
            $0.text = title
            $0.font = .systemFont(ofSize: 14, weight: .semibold)
            $0.textColor = .secondaryLabel
        }

        container.addSubview(iconView)
        container.addSubview(titleLabel)
        iconView.pin.left().vCenter().size(14)
        titleLabel.pin.after(of: iconView, aligned: .center).marginLeft(6).sizeToFit()

        if isRequired {
            let requiredLabel = UILabel().then {
                $0.text = "*"
                $0.font = .systemFont(ofSize: 14, weight: .semibold)
                $0.textColor = Colors.primary
            }
            container.addSubview(requiredLabel)
            requiredLabel.pin.after(of: titleLabel, aligned: .center).marginLeft(4).sizeToFit()
            container.pin.wrapContent()
            return container
        }

        container.pin.wrapContent()
        return container
    }

    static func makeTextField(placeholder: String) -> UITextField {
        return UITextField().then {
            $0.placeholder = placeholder
            $0.backgroundColor = .systemGray6
            $0.textColor = .label
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
            $0.font = .systemFont(ofSize: 16)
        }
    }

    static func makeSelectButton(placeholder: String) -> UIButton {
        return UIButton(type: .system).then {
            $0.setTitle(placeholder, for: .normal)
            $0.setTitleColor(.tertiaryLabel, for: .normal)
            $0.backgroundColor = .systemGray6
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
            $0.titleLabel?.font = .systemFont(ofSize: 16)
            $0.contentHorizontalAlignment = .left
            $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 32)
        }
    }
}


// MARK: - PHPickerViewControllerDelegate

extension HomeCreatePostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let result = results.first else { return }

        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let self, let image = object as? UIImage else { return }
            guard let data = image.jpegData(compressionQuality: 0.85) else { return }
            DispatchQueue.main.async {
                guard let reactor = self.reactor else { return }
                reactor.action.onNext(.didSelectImage(data, .jpeg))
            }
        }
    }
}
