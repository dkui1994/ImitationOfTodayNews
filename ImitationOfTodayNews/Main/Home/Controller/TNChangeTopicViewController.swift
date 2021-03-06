//
//  TNChangeTopicViewController.swift
//  ImitationOfTodayNews
//
//  Created by 杜奎 on 2017/6/26.
//  Copyright © 2017年 杜奎. All rights reserved.
//

import UIKit
import SVProgressHUD

class TNChangeTopicViewController: UIViewController,TopicViewDelegate {
    
    var myTopics : [TNHomeTopTitleModel]?
    var otherTopics : [TNHomeTopTitleModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = UIColor.white
        navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"add_channels_close_20x20_"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(closeBarButtonClicked))
        
//        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.barTintColor = UIColor.white
        createUI()
        fetchData()
    }
    
    func createUI() {
        
        view.addSubview(scrollView)
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.addSubview(myTopicLabel)
        myTopicLabel.x = kMargin
        myTopicLabel.y = 10
        
        scrollView.addSubview(myTopicSubLabel)
        myTopicSubLabel.x = myTopicLabel.right + kMargin
        myTopicSubLabel.bottom = myTopicLabel.bottom
        
        scrollView.addSubview(operateBtn)
        operateBtn.right = view.width - kMargin
        operateBtn.centerY = myTopicLabel.centerY
        
        scrollView.addSubview(topicView)
        topicView.delegate = self
        topicView.isMine = true
        topicView.topics = myTopics
        topicView.y = myTopicLabel.bottom + kMargin
        topicView.height = topicView.getContentHeight(myTopics!.count)
        
        scrollView.addSubview(commendTopicLabel)
        commendTopicLabel.x = kMargin
        commendTopicLabel.y = topicView.bottom + kHomeMargin
        
        scrollView.addSubview(commendTopicSubLabel)
        commendTopicSubLabel.x = commendTopicLabel.right + kMargin
        commendTopicSubLabel.bottom = commendTopicLabel.bottom
        
        scrollView.addSubview(commendTopicView)
        commendTopicView.delegate = self
        commendTopicView.isMine = false
        commendTopicView.y = commendTopicLabel.bottom + kMargin
        
        scrollView.contentSize = CGSize(width: self.view.width, height: scrollView.height)
    }
    
    func fetchData() {
        NetworkManager.shareManager.fetchAllTopic({[weak self] (topics) in
            print(topics)
            self?.otherTopics = topics
            self?.commendTopicView.topics = topics
            self?.commendTopicView.height = (self?.commendTopicView.getContentHeight(topics.count))!
            self?.scrollView.contentSize = CGSize(width: self!.view.width, height: self!.commendTopicView.bottom + kHomeMargin)
        }) { (error) in
            SVProgressHUD.showError(withStatus: "加载失败...")
        }
    }
    
    func closeBarButtonClicked() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func operateBtnClicked() {
        if self.operateBtn.titleLabel?.text != "编辑" {
            self.operateBtn.setTitle("编辑", for: UIControlState.normal)
            self.topicView.hideCloseImageView(true)
            self.commendTopicView.isUserInteractionEnabled = true
        }else {
            self.operateBtn.setTitle("完成", for: UIControlState.normal)
            self.topicView.hideCloseImageView(false)
            self.commendTopicView.isUserInteractionEnabled = false
            
        }
    }
    
    //MARK: topicview delegate
    func topicViewItemLabelTaped(_ itemLabel: UILabel, _ topicView: TNTopicView) {
//        let newItemLabel = itemLabel.copy()
        if topicView == self.commendTopicView {
            let newRect = self.topicView.getNewLastRect()
            let tranRect = self.commendTopicView.convert(newRect, from: self.topicView)
            self.commendTopicView.startSelectCommendTopicLabelMoveAction(tranRect) {[weak self] in
                print("lalalalalallala")
                let topic = (self?.otherTopics?[itemLabel.tag])!
                self?.myTopics?.append(topic)
                self?.otherTopics?.remove(at: itemLabel.tag)
                self?.topicView.addNewItemLabel(newRect, topic)
                if self?.topicView.height != self?.topicView.getContentHeight((self?.myTopics?.count)!) || self?.commendTopicView.height != self?.commendTopicView.getContentHeight((self?.otherTopics?.count)!) {
                    let offsetY = (self?.topicView.getContentHeight((self?.myTopics?.count)!))! - (self?.topicView.height)!
                    UIView.animate(withDuration: 0.3, animations: {[weak self] in
                        self?.topicView.height = (self?.topicView.height)! + offsetY
                        self?.commendTopicLabel.y = (self?.commendTopicLabel.y)! + offsetY
                        self?.commendTopicSubLabel.y = (self?.commendTopicSubLabel.y)! + offsetY
                        self?.commendTopicView.y = (self?.commendTopicView.y)! + offsetY
                        self?.commendTopicView.height = (self?.commendTopicView.getContentHeight((self?.otherTopics?.count)!))!
                        }, completion: { (finished) in
                            if finished {
                                self!.scrollView.contentSize = CGSize(width: self!.scrollView.contentSize.width, height: self!.scrollView.contentSize.height + offsetY)
                            }
                    })
                }
            }

        }
    }
    
    func topicViewItemLabelLongPress() {
        if self.operateBtn.titleLabel?.text == "编辑" {
            self.operateBtnClicked()
        }
    }
    
    func topicViewItemLabelClosed(_ itemLabel: UILabel) {
        let topic = (self.myTopics?[itemLabel.tag])!
        self.myTopics?.remove(at: itemLabel.tag)
        self.topicView.removeTopic(itemLabel.tag)
        self.otherTopics?.append(topic)
        self.commendTopicView.addNewItemLabel(CGRect.zero, topic)
        if self.topicView.height != self.topicView.getContentHeight((self.myTopics?.count)!) || self.commendTopicView.height != self.commendTopicView.getContentHeight((self.otherTopics?.count)!) {
            let offsetY = self.topicView.getContentHeight((self.myTopics?.count)!) - self.topicView.height
            UIView.animate(withDuration: 0.3, animations: {[weak self] in
                self?.topicView.height = (self?.topicView.height)! + offsetY
                self?.commendTopicLabel.y = (self?.commendTopicLabel.y)! + offsetY
                self?.commendTopicSubLabel.y = (self?.commendTopicSubLabel.y)! + offsetY
                self?.commendTopicView.y = (self?.commendTopicView.y)! + offsetY
                self?.commendTopicView.height = (self?.commendTopicView.getContentHeight((self?.otherTopics?.count)!))!
                }, completion: { (finished) in
                    if finished {
                        self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.scrollView.contentSize.height + offsetY)
                    }
            })
        }
    }
    
    //MARK: lazy loading
    fileprivate lazy var scrollView : UIScrollView = {
        let scroll = UIScrollView(frame: CGRect(x: 0, y: 64, width: self.view.width, height: self.view.height - 64))
        scroll.backgroundColor = UIColor.clear
        return scroll
    }()
    
    fileprivate lazy var myTopicLabel : UILabel = {
        let myTopicLabel = UILabel()
        myTopicLabel.textColor = UIColor.black
        myTopicLabel.text = "我的频道"
        myTopicLabel.font = ContentFont17
        myTopicLabel.sizeToFit()
        return myTopicLabel
    }()
    
    fileprivate lazy var myTopicSubLabel : UILabel = {
        let myTopicSubLabel = UILabel()
        myTopicSubLabel.textColor = UIColor.lightGray
        myTopicSubLabel.text = "点击进入频道"
        myTopicSubLabel.font = ContentFont11
        myTopicSubLabel.sizeToFit()
        return myTopicSubLabel
    }()
    
    fileprivate lazy var operateBtn : UIButton = {
        let btn = UIButton(type: UIButtonType.custom)
        btn.setTitle("编辑", for: UIControlState.normal)
        btn.setTitleColor(TNColor(210, 63, 66, 1.0), for: UIControlState.normal)
        btn.titleLabel?.font = ContentFont14
        btn.sizeToFit()
        btn.width = btn.width + 15
        btn.height = btn.height - 5
        btn.layer.cornerRadius = btn.height * 0.5
        btn.layer.masksToBounds = true
        btn.layer.borderColor = TNColor(210, 63, 66, 1.0).cgColor
        btn.layer.borderWidth = 0.6
        btn.addTarget(self, action: #selector(operateBtnClicked), for: UIControlEvents.touchUpInside)
        return btn
    }()
    
    fileprivate lazy var commendTopicLabel : UILabel = {
        let commendTopicLabel = UILabel()
        commendTopicLabel.textColor = UIColor.black
        commendTopicLabel.text = "推荐频道"
        commendTopicLabel.font = ContentFont17
        commendTopicLabel.sizeToFit()
        return commendTopicLabel
    }()
    
    fileprivate lazy var commendTopicSubLabel : UILabel = {
        let commendTopicSubLabel = UILabel()
        commendTopicSubLabel.textColor = UIColor.lightGray
        commendTopicSubLabel.text = "点击进入频道"
        commendTopicSubLabel.font = ContentFont11
        commendTopicSubLabel.sizeToFit()
        return commendTopicSubLabel
    }()
    
    fileprivate lazy var topicView : TNTopicView = {
        let topic = TNTopicView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 0))
        return topic
    }()
    
    fileprivate lazy var commendTopicView : TNTopicView = {
        let topic = TNTopicView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 0))
        return topic
    }()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
