//
//  HomePageViewController.swift
//  Think
//
//  Created by 이신원 on 1/4/24.
//

import UIKit

class HomePageViewController: UIViewController{
    let userViewModel = UserViewModel.shared
    let classroomViewModel = ClassroomViewModel.shared
    // MARK: - 교탁
    let rectangleBox = UIView()
    
    // MARK: - 학습하기 버튼
    let studyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("학습하기", for: .normal)
        button.setTitleColor(.black, for: .normal)

        button.layer.cornerRadius = 20
        button.backgroundColor = .systemYellow
        button.layer.shadowRadius = 2
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        button.addTarget(self, action: #selector(studyButtonAction), for: .touchUpInside)
        return button
    }()
    
    // MARK: - collectionView properties
    var gridColumns: Int = 0
    var gridRows: Int = 0
    var spacing: Bool = false
    var boxes: [Bool] = []
    var collectionView: UICollectionView!
    var studentList: [String] = []
    
    
    // MARK: - navigationBar properties
    let logoImageView:UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(named: "think")
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y:0, width: 35, height:35)
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    let userNameLabel:UILabel = {
       let label = UILabel()
        label.text = "김땡땡 선생님"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        
        return label
    }()
    
//    let profileButton: UIButton = {
//        let button = UIButton()
//        button.backgroundColor = .white
//        let symbolImage = UIImage(systemName: "person.icon.circle")
//        let largeConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .light, scale: .default)
//        let largeSymbolImage = symbolImage?.applyingSymbolConfiguration(largeConfig)
//        button.setImage(largeSymbolImage, for: .normal)
//        button.tintColor = .black
//        
//        button.addTarget(self, action: #selector(profileButtonAction), for: .touchUpInside)
//        
//        return button
//    }()
    
    let profileButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        if let image = UIImage(named: "profileIconCircle") {
            button.setImage(image, for: .normal)
        }
        button.tintColor = .black // 필요에 따라 틴트 색상을 설정하세요.

        button.addTarget(self, action: #selector(profileButtonAction), for: .touchUpInside)

        return button
    }()

//    let customView = UIView()
    let separatorLine = UIView()

    
    //MARK: - initialize
    func loadClassroomData(completion: @escaping () -> Void) {
        guard let classId = userViewModel.user.studentsListSimple?.last?.id else {
            print("No classId available")
            completion()
            return
        }

        classroomViewModel.loadClassroomData(classId: classId) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    guard let gridRows = self?.classroomViewModel.classroom.listRow,
                          let gridColumns = self?.classroomViewModel.classroom.listCol,
                          let spacing = self?.classroomViewModel.classroom.seatSpacing else {
                        print("Failed to unwrap classroom data")
                        return
                    }
                    
                    self?.gridRows = gridRows
                    self?.gridColumns = gridColumns
                    self?.spacing = spacing
                    self?.boxes = Array(repeating: false, count: gridRows * gridColumns)
                    completion()
                } else {
                    print("Error loading classroom data")
                }
            }
        }
    }

    
    
    // MARK: - viewDidLoad
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadClassroomData() {
            self.configureUI()
        }
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - UI Configuration
    private func configureUI() {
        view.backgroundColor = .white
        userNameLabel.text = userViewModel.user.name! + "  선생님"
        setupNav()
        setupRectangleBox()
        setupCollectionView()
        setupStudyButton()
        setupConstraints()
        
    }
    
    // MARK: - navigationBar 설정
    func setupNav() {
        // 로고 이미지 뷰와 사용자 이름 레이블을 customView에 추가
        view.addSubview(logoImageView)
        view.addSubview(userNameLabel)
        view.addSubview(profileButton)
        view.addSubview(separatorLine)
        
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.translatesAutoresizingMaskIntoConstraints = false

        separatorLine.backgroundColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1.0)

        
        NSLayoutConstraint.activate([
            logoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 65),
            logoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 14),
            logoImageView.widthAnchor.constraint(equalToConstant: 90),
            logoImageView.heightAnchor.constraint(equalToConstant: 24),
            
            userNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 170),
            userNameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 14),
            
            profileButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 720),
            profileButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 14),
            profileButton.widthAnchor.constraint(equalToConstant: 34),
            profileButton.heightAnchor.constraint(equalToConstant: 34)
        ])
        
        NSLayoutConstraint.activate([
                separatorLine.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 15),
                separatorLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                separatorLine.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                separatorLine.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        //         customView를 왼쪽 바 버튼 아이템으로 설정
        //        let leftBarButtonItem = UIBarButtonItem(customView: customView)
        //        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        //
        //        let rightBarButtonItem = UIBarButtonItem(customView: profileButton)
        //        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        //         네비게이션 바 스타일 설정
        //        let appearance = UINavigationBarAppearance()
        //        appearance.backgroundColor = .white // 배경색을 흰색으로 설정
        //        navigationController?.navigationBar.standardAppearance = appearance
        //        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
    }
    
    private func setupConstraints() {
        guard let layout = collectionView.collectionViewLayout as? CustomCollectionView else {
            return
        }

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        
        // Use properties from CustomGridLayout for totalCellWidth and totalCellHeight
        let spacenum = CGFloat(layout.gridColumns) - 1
        let totalCellWidth = (layout.cellWidth * CGFloat(layout.gridColumns)) + (layout.baseSpacing * spacenum)
        let totalCellHeight = (layout.cellHeight * CGFloat(gridRows)) + (layout.baseHeight * CGFloat(gridRows - 1))
        
        NSLayoutConstraint.activate([
            rectangleBox.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -46),
            rectangleBox.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            rectangleBox.widthAnchor.constraint(equalToConstant: 300),
            rectangleBox.heightAnchor.constraint(equalToConstant: 30),
            
            collectionView.widthAnchor.constraint(equalToConstant: totalCellWidth),
            collectionView.heightAnchor.constraint(equalToConstant: totalCellHeight),
            collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -10),
            
            
            studyButton.widthAnchor.constraint(equalToConstant: 110),
            studyButton.heightAnchor.constraint(equalToConstant: 40),
            studyButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -41),
            studyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -38)
            
        ])
        
    }
    
    
    private func setupRectangleBox() {
        rectangleBox.backgroundColor = UIColor(red: 208/255, green: 208/255, blue: 208/255, alpha: 1.0)
        rectangleBox.layer.cornerRadius = 5
        rectangleBox.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rectangleBox)


        let label = UILabel()
        label.text = "교탁"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17.166, weight: .regular)
        label.textColor = UIColor(white: 107/255, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        rectangleBox.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: rectangleBox.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: rectangleBox.centerYAnchor)
        ])
    }

    
    private func setupStudyButton(){
        view.addSubview(studyButton)
        studyButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    private func setupCollectionView() {        let layout = CustomCollectionView(columns: gridColumns, spacing: spacing, cellHeight:40, cellWidth:80)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(HomeCustomCollectionViewCell.self, forCellWithReuseIdentifier: HomeCustomCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
    
    }
    
    @objc func profileButtonAction(){
        print("profileButtonTapped")
        
        let detailVC = ProfileViewController()
        detailVC.modalPresentationStyle = .overFullScreen
        self.present(detailVC, animated: false, completion: nil)
    }
    
    @objc func studyButtonAction(){
//        self.navigationController?.isNavigationBarHidden = false
//        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
//        backBarButtonItem.tintColor = .black
//        navigationItem.backBarButtonItem = backBarButtonItem
//        
//        let changeViewController = LearnViewController()
//        navigationController?.pushViewController(changeViewController, animated: true)
//        
        let changeViewController = LearnViewController()
        let navigationController = UINavigationController(rootViewController: changeViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
        
        
    }
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    

    
    
}

extension HomePageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gridRows * gridColumns
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCustomCollectionViewCell.identifier, for: indexPath) as? HomeCustomCollectionViewCell else {
            fatalError("Unable to dequeue LearnCustomCollectionViewCell")
        }
        
        //cell.configure(with: studentList[indexPath.row])
        cell.configure(with: classroomViewModel.classroom.studentsList![indexPath.row].name!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let detailVC = DetailBottomSheetViewController(index: indexPath.row)
        detailVC.modalPresentationStyle = .overFullScreen
        self.present(detailVC, animated: false, completion: nil)
    }
    
}

