//
//  ViewController.swift
//  SwiftSegmentPushApp
//
//  Created by NIFTY on 2017/04/03.
//  Copyright © 2017年 NIFTY All rights reserved.
//

import UIKit
import NCMB

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    // title (CurrentInstallation)
    private var titleLabel: UILabel!
    // installationの内容を表示するリスト
    private var tableView:UITableView!
    // 通信結果を表示するラベル
    var statusLabel: UILabel!
    // installation
    var installation:NCMBInstallation!
    // currentInstallationに登録されているkeyの配列
    private var instKeys:Array<String> = []
    // installationに初期で登録されているキー
    private let initialInstKeys =  ["objectId","appVersion","badge","deviceToken","sdkVersion","timeZone","createDate","updateDate","deviceType","applicationName","acl"]
    // tableViewに表示しないinstallationのキー
    private var removeKeys = ["acl","deviceType","applicationName"]
    // 追加セルのマネージャー
    var addFieldManager = (keyStr:"",valueStr:"")
    // textFieldの位置情報
    var textFieldPosition:CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        installation = NCMBInstallation.current()
        
        var keyArray = installation!.allKeys() as! [String]
        for removeKey in removeKeys {
            if let removeIndex = keyArray.index(of: removeKey) {
                keyArray.remove(at: removeIndex)
            }
        }
        instKeys = keyArray
        
        // トップ画面表示用タイトル
        titleLabel = UILabel.init()
        titleLabel.text = "CurrentInstallation"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 28.0)
        
        // 通信結果を表示するラベル
        statusLabel = UILabel.init()
        statusLabel.textAlignment = .center
        statusLabel.font = UIFont.systemFont(ofSize: 12.0)
        
        // tableView
        tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = UIColor.clear // グリッド線を消す
        tableView.allowsSelection = false // セルを選択できないようにする
        
        view.addSubview(titleLabel)
        titleLabel.addSubview(statusLabel)
        
        view.addSubview(tableView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapScreen(_:)))
        self.view.addGestureRecognizer(tapGesture)
    
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        titleLabel.frame = CGRect(x:0.0, y:0.0, width:self.view.frame.size.width, height:self.view.frame.size.height / 5.0)
        statusLabel.frame = CGRect(x:0.0, y:self.titleLabel.frame.size.height - self.titleLabel.frame.size.height / 4.0, width:self.view.frame.size.width, height:self.titleLabel.frame.size.height / 4.0)
        tableView.frame = CGRect(x:0.0, y:self.titleLabel.frame.size.height, width:self.view.frame.size.width, height:self.view.frame.size.height - self.titleLabel.frame.size.height)
        
    }
    
    // MARK: TableViewDataSource
    
    /**
     TableViewのheaderの高さを返します。
     */
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TABLE_VIEW_HEADER_HEIGHT
    }
    
    /**
     TableViewのheaderViewを返します。
     */
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView.init(frame: CGRect(x:0.0, y:0.0, width:self.view.frame.size.width, height:TABLE_VIEW_HEADER_HEIGHT))
        
        if section == 0 {
            headerView.backgroundColor = UIColor.white
            
            let keyLabel = UILabel.init(frame: CGRect(x:0.0, y:0.0, width:TABLE_VIEW_KEY_LABEL_WIDTH, height:TABLE_VIEW_HEADER_HEIGHT))
            keyLabel.text = "key"
            keyLabel.textAlignment = .center
            keyLabel.font = UIFont.systemFont(ofSize: 12.0)

            let valueLabel = UILabel.init(frame: CGRect(x:TABLE_VIEW_KEY_LABEL_WIDTH, y:0.0, width:TABLE_VIEW_VALUE_LABEL_WIDTH, height:TABLE_VIEW_HEADER_HEIGHT))
            valueLabel.text = "value"
            valueLabel.textAlignment = .center
            valueLabel.font = UIFont.systemFont(ofSize: 12.0)
            
            headerView.addSubview(keyLabel)
            headerView.addSubview(valueLabel)

        }
        return headerView
    }
    
    /**
     TableViewのCellの数を設定します。
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instKeys.count + 1
    }

    /**
     TableViewのCellの高さを設定します。
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == instKeys.count {
            return TABLE_VIEW_POST_BTN_CELL_HEIGHT
        } else if instKeys[indexPath.row] == "deviceToken" {
            return MULTI_LINE_CELL_HEIGHT
        }
        
        return TABLE_VIEW_CELL_HEIGHT
    }

    /**
     TableViewのCellを返します。
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:CustomCell!
        
        if indexPath.row < instKeys.count {
            // 最後のセル以外
            let keyStr = instKeys[indexPath.row]
            let value = installation.object(forKey:keyStr) as AnyObject
            
            if !initialInstKeys.contains(keyStr) {
                // 既存フィールド以外とchannelsはvalueを編集できるようにする
                cell = tableView.dequeueReusableCell(withIdentifier: EDIT_CELL_IDENTIFIER) as! CustomCell!
                if cell == nil {
                    cell = CustomCell(style: UITableViewCellStyle.default, reuseIdentifier: EDIT_CELL_IDENTIFIER)
                }
                cell.setCell(keyStr: keyStr, editValue: value)
                cell.valueField.delegate = self
                cell.valueField.tag = indexPath.row
            } else {
                // 編集なしのセル (表示のみ)
                if keyStr == "deviceToken" {
                    // 表示文字数が多いセルはセルの高さを変更して全体を表示させる
                    cell = tableView.dequeueReusableCell(withIdentifier: MULTI_LINE_CELL_IDENTIFIER) as! CustomCell!
                    if cell == nil {
                        cell = CustomCell(style: UITableViewCellStyle.default, reuseIdentifier: MULTI_LINE_CELL_IDENTIFIER)
                    }
                } else {
                    // 通常のセル
                    cell = tableView.dequeueReusableCell(withIdentifier: NOMAL_CELL_IDENTIFIER) as! CustomCell!
                    if cell == nil {
                        cell = CustomCell(style: UITableViewCellStyle.default, reuseIdentifier: NOMAL_CELL_IDENTIFIER)
                    }
                }
                cell.setCell(keyStr: keyStr, value: value)
                
            }
        } else {
            // 最後のセルは追加用セルと登録ボタンを表示
            cell = tableView.dequeueReusableCell(withIdentifier: ADD_CELL_IDENTIFIER) as! CustomCell!
            if cell == nil {
                cell = CustomCell(style: UITableViewCellStyle.default, reuseIdentifier: ADD_CELL_IDENTIFIER)
            }
            cell.setAddRecordCell()
            cell.keyField.delegate = self
            cell.keyField.tag = indexPath.row
            cell.keyField.text = addFieldManager.keyStr
            cell.valueField.delegate = self
            cell.valueField.tag = indexPath.row
            cell.valueField.text = addFieldManager.valueStr
            cell.postBtn.addTarget(self, action: #selector(postInstallation(sender:)), for: UIControlEvents.touchUpInside)
        }
        return cell;
    }
    
    // MARK: requestInstallation
    
    /**
     最新のinstallationを取得します。
     */
    func getInstallation() {
        
        let installation = NCMBInstallation.current()
        
        // objectIdが取得できている場合はtableViewの表示を更新する
        if installation?.object(forKey: "objectId") != nil {
            //端末情報をデータストアから取得
            installation?.fetchInBackground({ error in
                if error == nil {
                    //端末情報の取得が成功した場合の処理
                    print("取得に成功")
                    self.installation = installation
                    var keyArray = installation!.allKeys() as! [String]
                    for removeKey in self.removeKeys {
                        if let removeIndex = keyArray.index(of: removeKey) {
                            keyArray.remove(at: removeIndex)
                        }
                    }
                    self.instKeys = keyArray
                    // 追加fieldの値を初期化する
                    self.addFieldManager.keyStr = ""
                    self.addFieldManager.valueStr = ""
                    self.tableView.reloadData()
                } else {
                    //端末情報の取得が失敗した場合の処理
                    self.statusLabel.text = "取得に失敗しました:\((error as! NSError).code)"
                }
            })
        }
    }
    
    /**
     送信ボタンをタップした時に呼ばれます
     */
    func postInstallation(sender:UIButton) {
        
        // textFieldの編集を終了する
        self.view.endEditing(true)
        
        // 追加フィールドにvalueだけセットされてkeyには何もセットされていない場合
        if addFieldManager.valueStr != "" && addFieldManager.keyStr == "" {
            statusLabel.text = "key,valueをセットで入力してください"
            return
        }
        
        // 追加用セルの値をinstallationにセットする
        if addFieldManager.keyStr != "" {
            // keyに値が設定されていた場合
            if addFieldManager.valueStr.range(of: ",") != nil {
                // value文字列に[,]がある場合は配列に変換してinstallationにセットする
                installation.setObject(addFieldManager.valueStr.components(separatedBy: ","), forKey: addFieldManager.keyStr)
            } else {
                installation.setObject(addFieldManager.valueStr, forKey: addFieldManager.keyStr)
            }
        }
        
        // installationを更新
        installation.saveInBackground { error in
            if error == nil {
                self.statusLabel.text = "保存に成功しました"
                // tableViewの内容を更新
                self.getInstallation()
            
            } else {
                self.statusLabel.text = "保存に失敗しました:\((error as! NSError).code)"
                // 保存に失敗した場合は、installationから削除する
                self.installation.remove(forKey: self.addFieldManager.keyStr)
            }
        }
    }
    
    // 背景をタップするとキーボードを隠す
    func tapScreen(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // MARK: TextFieldDelegate
    
    // キーボードの「Return」押下時の処理
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }
    
    /**
     textFieldの編集を開始したら呼ばれます
     textFieldの位置情報をセットします
     */
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        let indexpath = IndexPath.init(row: textField.tag, section: 0)
        let rectOfCellInTableView = tableView.rectForRow(at: indexpath)
        let rectOfCellInSuperview = tableView.convert(rectOfCellInTableView, to: tableView.superview)
        // textFieldの位置情報をセット
        textFieldPosition = rectOfCellInSuperview.origin.y
        
        return true
    }
    
    /**
     textFieldの編集が終了したら呼ばれます
     */
    func textFieldDidEndEditing(_ textField: UITextField) {
        // tableViewのdatasorceを編集する
        if textField.tag < instKeys.count {
            // 最後のセル以外はinstallationを更新する
            let instValueStr = ConvertString.convertNSStringToAnyObject(installation.object(forKey: instKeys[textField.tag]) as AnyObject)
            if instValueStr != textField.text {
                // valueの値に変更がある場合はinstallationを更新する
                if textField.text?.range(of: ",") != nil {
                    // value文字列に[,]がある場合は配列に変換してinstallationにセットする
                    installation.setObject(textField.text?.components(separatedBy: ","), forKey: instKeys[textField.tag])
                } else {
                    // それ以外は文字列としてinstallationにセットする
                    installation.setObject(textField.text, forKey: instKeys[textField.tag])
                }
            }
        } else {
            // 追加セルはmanagerクラスを更新する（installation更新時に保存する）
            let cell = tableView.cellForRow(at: IndexPath.init(row: textField.tag, section: 0)) as! CustomCell?
            if textField == cell!.keyField {
                // keyFieldの場合
                if addFieldManager.keyStr != textField.text {
                    // keyの値に変更がある場合はマネージャーを更新する
                    addFieldManager.keyStr = textField.text!
                }
            } else {
                // valueFieldの場合
                if (addFieldManager.valueStr != textField.text) {
                    // valueの値に変更がある場合はマネージャーを更新する
                    addFieldManager.valueStr = textField.text!
                }
            }
        }
    }
    
    // MARK: keyboardWillShow
    
    /**
     キーボードが表示されたら呼ばれる
     */
    func keyboardWillShow(_ notification: NSNotification) {
        
        var keyboardRect = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! CGRect
        keyboardRect = self.view.superview!.convert(keyboardRect, to: nil)
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]
        
        let keyboardPosition = self.view.frame.size.height - keyboardRect.size.height as CGFloat
        
        // 編集するtextFieldの位置がキーボードより下にある場合は、位置を移動する
        if textFieldPosition + TABLE_VIEW_CELL_HEIGHT > keyboardPosition {
            UIView.animate(withDuration: duration as! Double, animations: { () in
                // アニメーションでtextFieldを動かす
                var rect = self.tableView.frame
                rect.origin.y = keyboardRect.origin.y - self.textFieldPosition
                self.tableView.frame = rect
            })
        }
    }
    
    /**
     キーボードが隠れると呼ばれる
     */
    func keyboardWillHide(_ notification: NSNotification) {
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]
        
        // アニメーションでtextFieldを動かす
        UIView.animate(withDuration: duration as! Double, animations: { () -> Void in
            // アニメーションでtextFieldを動かす
            var rect = self.tableView.frame
            rect.origin.y = self.view.frame.size.height - self.tableView.frame.size.height
            self.tableView.frame = rect
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

