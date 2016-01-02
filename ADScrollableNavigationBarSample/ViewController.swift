//
//  ViewController.swift
//  SampleSwift
//
//  Created by adapter00 on 2015/07/26.
//  Copyright © 2015年 adapter00. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UIGestureRecognizerDelegate {

    enum NavibationBarState {
        case None,Moving,Expand
    }
    @IBOutlet var mainTableView: UITableView!
    var scrollPreOffset:CGFloat = 0
    let statubarHeight = UIApplication.sharedApplication().statusBarFrame.height
    var deltaMax :CGFloat = 0
    var naviState: NavibationBarState = .None
    var autoNaviRefresh : Bool = false
    var defaultViewHeight : CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let panGesture = UIPanGestureRecognizer(target: self, action:Selector("handlePan:"))
        panGesture.delegate = self
        mainTableView.addGestureRecognizer(panGesture)
        deltaMax = self.navigationController!.navigationBar.frame.height - statubarHeight
        defaultViewHeight = view.frame.height
    }
    
    override func viewDidLayoutSubviews() {
    }
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    2}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell =  UITableViewCell(style: .Default, reuseIdentifier: "cell")
        cell.textLabel?.text = "cell\(indexPath.row)"
        return cell
    }
    
    func handlePan(sender: UIPanGestureRecognizer) {
        if sender.state == .Began {
            scrollPreOffset = sender.translationInView(mainTableView).y
        } else if sender.state == .Changed {
            let currentTouchPoint = sender.translationInView(mainTableView).y
            let diff = scrollPreOffset - currentTouchPoint
            scrollPreOffset = currentTouchPoint
            let delta = diff
            decideNaviState(delta)
            sizeFitToNavigation(delta)
        } else {
            scrollPreOffset = 0
        }
    }
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        //閾値を持ってNavigationBarをアニメーションさせる
        let threshold = (-deltaMax + self.statubarHeight)
        let naviPosition = self.navigationController!.navigationBar.frame.origin.y
        if naviPosition > threshold {
            showNavibar()
        }else {
            hideNavibar()
        }
    }
    func decideNaviState(delta:CGFloat){
        let naviFrame = self.navigationController?.navigationBar.frame
        let deltaFrame = naviFrame!.origin.y - delta
        if deltaFrame >= statubarHeight || deltaFrame <= -deltaMax {
            naviState = .Expand
        }else {
            naviState = .Moving
        }
    }
    func sizeFitToNavigation(delta :CGFloat) {
        if naviState == .Moving {
            let naviFrame = self.navigationController!.navigationBar.frame
            self.navigationController?.navigationBar.frame = CGRectMake(naviFrame.origin.x,naviFrame.origin.y - delta, naviFrame.width, naviFrame.height)
            view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y - delta, view.frame.width,  view.frame.height + delta)
            self.view.layoutIfNeeded()
        }
    }
    func showNavibar () {
        UIView.animateWithDuration(0.05, animations: { () -> Void in
            let naviFrame = self.navigationController!.navigationBar.frame
            self.navigationController?.navigationBar.frame.origin = CGPoint(x: 0, y: self.statubarHeight)
            self.view.frame.origin = CGPoint(x: self.view.frame.origin.x, y: naviFrame.height + self.statubarHeight)
            self.view.frame.size = CGSize(width: self.view.frame.width, height: self.defaultViewHeight)
            }) { (finished) -> Void in
                self.view.layoutIfNeeded()
                self.naviState = .Expand
        }
    }
    
    func hideNavibar () {
        UIView.animateWithDuration(0.05, animations: { () -> Void in
            self.navigationController?.navigationBar.frame.origin = CGPoint(x: 0, y: -self.deltaMax)
            self.view.frame.origin = CGPoint(x: self.view.frame.origin.x, y: self.statubarHeight)
            self.view.frame.size = CGSize(width: self.view.frame.width, height: self.defaultViewHeight - self.statubarHeight)
            }) { (finished) -> Void in
                self.view.layoutIfNeeded()
                self.naviState = .Expand
        }
    }
}
