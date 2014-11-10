//
//  SiteViewController.swift
//  SwiftRandomData
//
//  Created by OKU Junichirou on 2014/10/05.
//  Copyright (c) 2014年 OKU Junichirou. All rights reserved.
//

import UIKit
import CoreData

// MARK: - Utility functions

func unique<T: Equatable>(array: [T]) -> [T] {
    var result = [T]()
    
    for elm in array {
        if find(result, elm) == nil {
            result += [elm]
        }
    }
    return result
}

func difference<T: Equatable>(x: [T], y: [T]) -> [T] {
    return x.filter {find(y, $0) == nil}
}

func intersection<T: Equatable>(x: [T], y: [T]) -> [T] {
    return x.filter {find(y, $0) == nil ? false : true}
}

class SiteViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    // MARK: - Properties
    
    var detailItem: NSManagedObject?
    var deferedClosure = Array<()->Void>()
    var appData = [String: String]()
    
    // MARK: - Coordinator functions between keys and index paths
    
    private var _keyToIndexPath: [String: NSIndexPath] {
        get {
            if self._editing {
                return
                    [
                        "title":   NSIndexPath(forRow: 0, inSection:0),
                        "url":     NSIndexPath(forRow: 1, inSection:0),
                        "userid":  NSIndexPath(forRow: 0, inSection:1),
                        "pass":    NSIndexPath(forRow: 0, inSection:2),
                        "length":  NSIndexPath(forRow: 1, inSection:2),
                        "char":    NSIndexPath(forRow: 2, inSection:2),
                        "picker":  NSIndexPath(forRow: 3, inSection:2),
                        "set":     NSIndexPath(forRow: 4, inSection:2),
                        "memo":    NSIndexPath(forRow: 0, inSection:3) ]
                
            }
            else {
                return
                    [
                        "title":   NSIndexPath(forRow: 0, inSection:0),
                        "url":     NSIndexPath(forRow: 1, inSection:0),
                        "userid":  NSIndexPath(forRow: 0, inSection:1),
                        "pass":    NSIndexPath(forRow: 1, inSection:1),
                        "memo":    NSIndexPath(forRow: 0, inSection:2) ]
            }
        }
    }

    private var _keyToPlaceholder: [String: String] {
        get {
            if self._editing {
                return [
                    "title":   "Title of the site",
                    "url":     "URL",
                    "userid":  "User ID",
                    "pass":    "Password",
                    "memo":    "Memo" ]
                
            }
            else {
                return [
                    "title":   "Title of the site",
                    "url":     "URL",
                    "userid":  "User ID",
                    "pass":    "Password",
                    "memo":    "Memo" ]
            }
        }
    }

    func keyToIndexPath(key: String) -> NSIndexPath? {
        if let val = self._keyToIndexPath[ key ] {
            return val
        }
        else {
            return nil
        }
    }
    
    func indexPathToKey(indexPath: NSIndexPath) -> String? {
        var result: String? = nil
        for (key, val) in self._keyToIndexPath {
            if indexPath == val {
                if result == nil {
                    result = key
                }
                else {
                    assertionFailure("invalid _keyToIndexPath")
                }
            }
        }
        return result
    }
    
    private var _keyToTag: [String: Int] = [
        "title":    10,
        "url":      11,
        "userid":   12,
        "pass":     13,
        "length":   14,
        "char":     15,
        "picker":   16,
        "set":      17,
        "memo":     18
    ]
    
    func keyToTag(key: String) -> Int? {
        return self._keyToTag[key]
    }
    
    func tagToKey(tag: Int) -> String? {
        var result: String? = nil
        for (key, val) in self._keyToTag {
            if val == tag {
                if result == nil {
                    result = key
                }
                else {
                    assertionFailure("invalid _keyToTag")
                }
            }
        }
        return result
    }
    
    // MARK: - Editing functions

    private var _editing: Bool = false
    
    override func setEditing(editing: Bool, animated: Bool) {
        
        if !animated {
            self._editing = editing
            self.configureButtons(animated: animated)
        }
        else {
            self.tableView.beginUpdates()

            let beforeSection: Int = self._keyToIndexPath.values.array.map { $0.section }.reduce(-1) { max($0, $1) }
//            let beforePaths: [NSIndexPath] = unique( self._keyToIndexPath.values.array.sorted {
//                    $0.section == $1.section ? $0.row < $0.row : $0.section < $0.section
//                } )
            let beforePaths: [NSIndexPath] = self._keyToIndexPath.values.array
            
            self._editing = editing

            let afterSection: Int = self._keyToIndexPath.values.array.map { $0.section }.reduce(-1) { max($0, $1) }
//            let afterPaths: [NSIndexPath]  = unique( self._keyToIndexPath.values.array.sorted {
//                    $0.section == $1.section ? $0.row < $0.row : $0.section < $0.section
//                } )
            let afterPaths: [NSIndexPath]  = self._keyToIndexPath.values.array

            // compare sections
            // a new section is added
//            var insertedSections = [Int]()
            if beforeSection < afterSection {
                for i in (beforeSection + 1)...afterSection {
                    self.tableView.insertSections(NSIndexSet(index: i), withRowAnimation: .Fade)
//                    insertedSections += [i]
                }
            }

            if afterSection < beforeSection {
                for i in (afterSection + 1)...beforeSection {
                    self.tableView.deleteSections(NSIndexSet(index: i), withRowAnimation: .Fade)
                }
            }

            var newRows = difference(afterPaths, beforePaths)
            let oldRows = difference(beforePaths, afterPaths)
            let updRows = intersection(beforePaths, afterPaths)
 /*
            println("new rows=\(newRows)")
            println("old rows=\(oldRows)")
            println("upd rows=\(updRows)")
*/
//            newRows = newRows.filter { !(find(insertedSections, $0.section) != nil && $0.row == 0) }
            
            self.tableView.insertRowsAtIndexPaths(newRows, withRowAnimation: .Fade)
            self.tableView.deleteRowsAtIndexPaths(oldRows, withRowAnimation: .Fade)
            self.tableView.reloadRowsAtIndexPaths(updRows, withRowAnimation: .Fade)
            
            
            // compare rows
/*
            while ( bi < beforePath.count && ai < afterPath.count ) {
                let bv = beforePath[ bi ].section
                let av = afterPath[ ai  ].section
                println("before[\(bi)]=\(bv) after[\(ai)]=\(av)")
                if bv < av {
                    // a new section is added
                    println("insert section=\(av)")
                    self.tableView.insertSections(NSIndexSet.init(index: av), withRowAnimation: .Automatic)
                    ai++
                }
                else if bv > av {
                    // the section is deleted
                    println("delete section=\(bv)")
                    self.tableView.deleteSections(NSIndexSet.init(index: bv), withRowAnimation: .Automatic)
                    bi++
                }
                else {
                    println("reload section=\(bv)")
//                    self.tableView.reloadSections(NSIndexSet.init(index: av), withRowAnimation: .Fade)
                    ai++
                    bi++
                }
            }

            // compare rows
            var bi = 0
            var ai = 0
            while ( bi < beforePaths.count && ai < afterPaths.count ) {
                let (bsec, brow) = (beforePaths[ bi ].section, beforePaths[ bi ].row)
                let (asec, arow) = (afterPaths[ ai  ].section, afterPaths[ ai  ].row)
                let  bval = bsec * 100 + brow
                let  aval = asec * 100 + arow
                print("before[\(bi)]=(\(bsec), \(brow)) after[\(ai)]=(\(asec), \(arow)) ")
                if bval < aval {
                    // a new cell is added
                    let indexPath = NSIndexPath.init(forRow: arow, inSection: asec)
                    println("insert row=\(asec) \(arow)")
                    self.tableView.insertRowsAtIndexPaths([afterPaths[ai]], withRowAnimation: .Automatic)
                    ai++
                }
                else if bval > aval {
                    // the section is deleted
                    let indexPath = NSIndexPath.init(forRow: brow, inSection: bsec)
                    println("delete row=\(bsec) \(brow)")
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    bi++
                }
                else {
                    let indexPath = NSIndexPath.init(forRow: arow, inSection: asec)
                    println("reload row=\(asec) \(arow)")
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    ai++
                    bi++
                }
            }

            for (key, val) in self._keyToIndexPath {
                if let indexPath = self.keyToIndexPath(key) {
                    NSLog("setEditing key=%@ val=%d indexPath=(%d,%d)", key, val, indexPath.section, indexPath.row)
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
            }
*/
            self.tableView.endUpdates()
            self.configureButtons(animated: animated)
        }
    }
    
    func setToEditingMode(sender: AnyObject) {
        self.setEditing(true, animated: true)
    }
    
    func exitFromEdigintMode(sender: AnyObject) {
        self.setEditing(false, animated: true)
    }
    
    func editing() -> Bool {
        return self._editing
    }
    
    // MARK: - View controller life cycle

    func configureButtons(#animated: Bool) {
        if  self.editing() {
            let addButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "exitFromEdigintMode:")
            self.navigationItem.setRightBarButtonItem(addButton, animated: animated)
        }
        else {
            let addButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "setToEditingMode:")
            self.navigationItem.setRightBarButtonItem(addButton, animated: animated)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for key in  [  "title", "url", "userid", "pass", "memo" ] {
            self.appData[ key ] = self.detailItem?.valueForKey( key )?.description
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.configureButtons(animated: false)
    }

    override func viewWillAppear(animated: Bool) {
//      self.title = self.detailItem?.valueForKey("title")?.description
        self.title = self.appData["title"]
    }
    
    override func viewDidDisappear(animated: Bool) {
        for closure in self.deferedClosure {
            closure()
        }
        self.deferedClosure = Array<()->Void>()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        var sec = 0
        for (key, val) in self._keyToIndexPath {
            sec = max( sec, val.section)
        }
        return sec + 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        var rows = 0
        for (key, val) in self._keyToIndexPath {
            if section == val.section {
                rows = max( rows, val.row )
            }
        }
        return rows + 1
    }

    func findSubview<T>(contentView: UIView, forClass: T) -> T? {
        let subViews = contentView.subviews.filter {$0 is T}
        if subViews.count <= 0 {
            println("Any class is found in \(contentView.description)" )
            return nil
        }
        else if subViews.count > 1 {
            println("Some classes are found in \(contentView.description)" )
            return nil
        }
        else {
            return subViews[0] as? T
        }
    }

    func addTarget(control: UIControl, action: Selector, forControlEvents controlEvents: UIControlEvents) {
        var act: Selector?
        if let acts = control.actionsForTarget(self, forControlEvent: controlEvents) {
            for a in acts {
                if action == Selector(a as String) {
                    act = Selector(a as String)
                }
            }
        }
        if act == nil {
            control.addTarget(self, action: action, forControlEvents: controlEvents)
        }
        else {
            println("\(action.description) is already added for event \(controlEvents) in \(control)")
        }
        
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        if  self.editing() {
            if let key = self.indexPathToKey(indexPath) {
                switch key {
                case "title", "url", "userid", "pass", "memo":
                    let tag = self.keyToTag(key) ?? 0
                    // get a text field view
                    if let tf = self.findSubview(cell.contentView, forClass: UITextField()) {
//                      tf.text        = self.detailItem?.valueForKey(key)?.description
                        tf.text        = self.appData[ key ]
                        tf.placeholder = self._keyToPlaceholder[key]
                        tf.tag = tag
                        self.addTarget(tf, action: "tapped:", forControlEvents: .EditingDidEnd)
                    }
                    
/*
                    var tfs = cell.contentView.subviews.filter {$0 is UITextField}
                    if tfs.count <= 0 || tfs.count > 1 {
                        println( "\(cell) does not contain UITextField")
                        return
                    }
                    assert(tfs[0] is UITextField, "\(tfs[0]) is not an UITextField")
                    let tf = tfs[0] as UITextField

                    // get the value and the place holder at indexPath
//                    var text:    String? = nil
//                    var pholder: String? = nil
//                    if let key = self.indexPathToKey(indexPath) {
//                        text    = self.detailItem?.valueForKey(key)?.description
//                        pholder = self._keyToPlaceholder[key]
//                    }
                    
                    tf.text        = self.detailItem?.valueForKey(key)?.description
                    tf.placeholder = self._keyToPlaceholder[key]
*/

                case "picker":
                    var pvs = cell.contentView.subviews.filter {$0 is UIPickerView}
                    if pvs.count <= 0 || pvs.count > 1 {
                        println( "\(cell) does not contain UIPickerView")
                        return
                    }
                    let pv = pvs[0] as UIPickerView
                    pv.delegate = self
                    pv.dataSource = self
                default:
                    assert(true, "\(key) is exhausted")
                }
            }
        }
        else {
            if let key = self.indexPathToKey(indexPath) {
//              cell.textLabel.text = self.detailItem?.valueForKey(key)?.description
                cell.textLabel.text = self.appData[key]
            }
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let key = self.indexPathToKey(indexPath) {
            var height: CGFloat = 0.0
            switch key {
              case "picker":
                    height = 162.0
            default:
                height = tableView.rowHeight
            }
            return height
        }
        else {
            return tableView.rowHeight
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        
        if self.editing() {
            let key: String? = self.indexPathToKey(indexPath)
            switch key! {
            case "set":
                cell = (tableView.dequeueReusableCellWithIdentifier("CellSet", forIndexPath: indexPath) as UITableViewCell)
            case "length":
                cell = (tableView.dequeueReusableCellWithIdentifier("CellLength", forIndexPath: indexPath) as UITableViewCell)
            case "char":
                cell = (tableView.dequeueReusableCellWithIdentifier("CellCharacters", forIndexPath: indexPath) as UITableViewCell)
            case "picker":
                cell = (tableView.dequeueReusableCellWithIdentifier("CellPicker", forIndexPath: indexPath) as UITableViewCell)
            default:
                cell = (tableView.dequeueReusableCellWithIdentifier("CellEdit", forIndexPath: indexPath) as UITableViewCell)
            }
        }
        else {
            cell = (tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell)

        }
        self.configureCell(cell!, atIndexPath: indexPath)
        return cell!
    }



    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return false
    }


    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - UIControl Event
    func tapped(sender: AnyObject){
        if let key = self.tagToKey(sender.tag) {
            switch(key) {
            case "title", "url", "userid", "pas":
                let str = (sender as UITextField).text
//              self.detailItem?.setValue(str, forKey: key)
                self.appData[key] = str
                
                self.deferedClosure.append( {
                    self.detailItem?.setValue(str, forKey: key)
                    let cdm = J1CoreDataManager.sharedInstance
                    let context = cdm.managedObjectContext!
                    var error: NSError? = nil
                    if !context.save(&error) {
                        abort()
                    }
                })
            default:
                println("not implemented for \(key)")
            }
        }
        else {
            println("Unknown sender: \(sender.description)")
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }

    // MARK: - Picker View Delegate
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return J1RandomOption.OptionsEnd.rawValue
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return J1RandomOption(rawValue: row)?.toString()
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        println("picker view selected")
//        var random: J1RandomEntry = self.detailItem as J1RandomEntry
//        random.option = J1RandomOption(rawValue: row )!
 //       self.detailItem = random;
    }
}
