//
//  CustomCell.swift
//  SwiftSegmentPushApp
//
//  Created by NIFTY on 2017/04/03.
//  Copyright © 2017年 NIFTY All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {
    var keyLabel: UILabel!
    var valueLabel: UILabel!
    
    var keyField: UITextField!
    var valueField: UITextField!
    var postBtn: UIButton!
    
    let CellMargin:CGFloat = 5.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /**
     通常セル (内容を表示するだけ)
     @param keyStr keyラベルに表示する文字列
     @param value valueラベルに表示するオブジェクト　（文字列、配列、Dictionary）
     */
    func setCell(keyStr:String, value:AnyObject?){
        
        keyLabel = UILabel.init()
        keyLabel.backgroundColor = UIColor.blue
        keyLabel.text = keyStr
        keyLabel.textColor = UIColor.white
        keyLabel.textAlignment = .center
        keyLabel.font = UIFont.systemFont(ofSize: 12.0)
        keyLabel.numberOfLines = 0
        
        valueLabel = UILabel.init()
        valueLabel.backgroundColor = UIColor.black
        if value != nil {
            valueLabel.text = ConvertString.convertNSStringToAnyObject(value!)
            valueLabel.textColor = UIColor.white
            if (reuseIdentifier == NOMAL_CELL_IDENTIFIER) {
                self.valueLabel.textAlignment = .center
            }
            self.valueLabel.font = UIFont.systemFont(ofSize: 12.0)
            self.valueLabel.numberOfLines = 0
        }
        
        self.addSubview(keyLabel)
        self.addSubview(valueLabel)
        
        self.setNeedsLayout()
    }

    /**
     value編集セル
     @param keyStr keyラベルに表示する文字列
     @param editValue valueテキストフィールドに表示する文字列
     */
    func setCell(keyStr:String, editValue:AnyObject?) {
        
        keyLabel = UILabel.init()
        keyLabel.backgroundColor = UIColor.blue
        keyLabel.text = keyStr
        keyLabel.textColor = UIColor.white
        keyLabel.textAlignment = .center
        keyLabel.font = UIFont.systemFont(ofSize: 12.0)
        keyLabel.numberOfLines = 0
        
        valueField = UITextField.init()
        valueField.borderStyle = .roundedRect
        valueField.placeholder = "value"
        if (editValue != nil) {
            valueField.text = ConvertString.convertNSStringToAnyObject(editValue!)
            valueField.textAlignment = .center
            valueField.font = UIFont.systemFont(ofSize: 12.0)
        }
        
        self.addSubview(keyLabel)
        self.addSubview(valueField)
        
        self.setNeedsLayout()
    }
    
    /**
     セルの最後は、追加keyと追加valueと更新ボタンを表示する
     */
    func setAddRecordCell() {
        
        keyField = UITextField.init()
        keyField.borderStyle = .roundedRect
        keyField.placeholder = "追加key"
        keyField.textAlignment = .center
        keyField.font = UIFont.systemFont(ofSize: 12.0)
        
        valueField = UITextField.init()
        valueField.borderStyle = .roundedRect
        valueField.placeholder = "追加value"
        valueField.textAlignment = .center
        valueField.font = UIFont.systemFont(ofSize: 12.0)
        
        // 更新ボタン
        postBtn = UIButton.init(type: .roundedRect)
        postBtn.backgroundColor = UIColor.black
        postBtn.setTitle("更新", for: .normal)
        postBtn.setTitleColor(UIColor.white, for: .normal)

        self.addSubview(keyField)
        self.addSubview(valueField)
        self.addSubview(postBtn)
        
        self.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if reuseIdentifier == NOMAL_CELL_IDENTIFIER || reuseIdentifier == MULTI_LINE_CELL_IDENTIFIER {
            // ノーマルセルとdeviceTokenセル
            keyLabel.frame = CGRect(x:0.0 + CellMargin, y:0.0 + CellMargin, width:self.frame.size.width * 0.3 - CellMargin, height:self.frame.size.height - CellMargin)
            valueLabel.frame = CGRect(x:self.frame.size.width * 0.3 + CellMargin, y:0.0 + CellMargin, width:self.frame.size.width * 0.7 - CellMargin * 2.0, height:self.frame.size.height - CellMargin)
        } else if (reuseIdentifier == EDIT_CELL_IDENTIFIER) {
            // value編集セル
            keyLabel.frame = CGRect(x:0.0 + CellMargin, y:0.0 + CellMargin, width:self.frame.size.width * 0.3 - CellMargin, height:self.frame.size.height - CellMargin);
            valueField.frame = CGRect(x:self.frame.size.width * 0.3 + CellMargin, y:0.0 + CellMargin, width:self.frame.size.width * 0.7 - CellMargin * 2.0, height:TABLE_VIEW_CELL_HEIGHT - CellMargin);
        } else {
            // 最後のセル
            keyField.frame = CGRect(x:0.0 + CellMargin, y:0.0 + CellMargin, width:self.frame.size.width * 0.3 - CellMargin, height:TABLE_VIEW_CELL_HEIGHT - CellMargin);
            valueField.frame = CGRect(x:self.frame.size.width * 0.3 + CellMargin, y:0.0 + CellMargin, width:self.frame.size.width * 0.7 - CellMargin * 2.0, height:TABLE_VIEW_CELL_HEIGHT - CellMargin);
            postBtn.frame = CGRect(x:(UIScreen.main.bounds.size.width - 100) / 2.0, y:self.valueField.frame.size.height + 20.0, width:100.0, height:50.0);
        }
    }
}
