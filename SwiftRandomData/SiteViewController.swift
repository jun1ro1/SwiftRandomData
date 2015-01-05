//
//  SiteViewController.swift
//  SwiftRandomData
//
//  Created by OKU Junichirou on 2014/10/05.
//  Copyright (c) 2014年 OKU Junichirou. All rights reserved.
//

import UIKit
import CoreData

class SiteViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    // MARK: - Managers
    var passManager: PassManager   = PassManager.sharedManager()

    // MARK: - Properties
    
    var detailItem: Site? = nil
/*
{
        didSet {
            for key in  [  "title", "url", "userid", "pass", "memo" ] {
                self.appData[ key ] = self.detailItem?.valueForKey( key )?.description
            }
            for key in [ "length", "option" ] {
                self.appData[ key ] = self.detailItem?.valueForKey( key )? as? Int
            }
 //           self.tableView.reloadData()
        }
    }
*/

//    var deferredClosure = Array<()->Void>()
//    var deferredClosure2 = Array<()->Void>()
    
    var appData: [String: AnyObject] = [String: AnyObject]()
    var appDataChanged: [String] = [String]()
/*{
        didSet {
//            self.configureView()
            self.tableView.reloadData()
        }
    }
*/

    let lengthArray          = [ 4, 5, 6, 8, 10, 12, 14, 16, 20, 24, 32 ]
    var lengthLabel: UILabel?
    
    var passField: UITextField?
    
    var randgen = J1RandomData()
    var randomField: UITextField?


    // MARK: - Coordinator functions between keys and index paths

    let keys: [String] = [ "title", "url", "userid", "pass", "memo", "length", "option" ]
    
    var _generatorShowed: Bool = false
    
    private var _keyToIndexPath: [String: NSIndexPath] {
        get {
            if self._editing {
                if self._generatorShowed {
                    return
                        [
                            "title":     NSIndexPath(forRow: 0, inSection:0),
                            "url":       NSIndexPath(forRow: 1, inSection:0),
                            
                            "userid":    NSIndexPath(forRow: 0, inSection:1),
                            "pass":      NSIndexPath(forRow: 1, inSection:1),
                            
                            "generated": NSIndexPath(forRow: 0, inSection:2),
                            "length":    NSIndexPath(forRow: 1, inSection:2),
                            "picker":    NSIndexPath(forRow: 2, inSection:2),
                            "set":       NSIndexPath(forRow: 3, inSection:2),

                            "memo":      NSIndexPath(forRow: 0, inSection:3) ]
                    
                }
                else {
                    return
                        [
                            "title":     NSIndexPath(forRow: 0, inSection:0),
                            "url":       NSIndexPath(forRow: 1, inSection:0),

                            "userid":    NSIndexPath(forRow: 0, inSection:1),
                            "pass":      NSIndexPath(forRow: 1, inSection:1),
                            "generator": NSIndexPath(forRow: 2, inSection:1),

                            "memo":      NSIndexPath(forRow: 0, inSection:2) ]
                }
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
        "memo":     18,
        "generator": 19
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

            let beforePaths: [NSIndexPath] = self._keyToIndexPath.values.array
            var beforeSections: [Int] = beforePaths.map { $0.section }
            
            self._editing = editing
            if !self._editing && self._generatorShowed {
                self.refreshControl = nil
                self._generatorShowed = false
            }
            
            let afterPaths: [NSIndexPath]  = self._keyToIndexPath.values.array
            var afterSections: [Int] = afterPaths.map { $0.section }
            
            difference(afterSections, beforeSections).map {
                self.tableView.insertSections(NSIndexSet(index: $0), withRowAnimation: .Fade)
            }
            difference(beforeSections, afterSections).map {
                self.tableView.deleteSections(NSIndexSet(index: $0), withRowAnimation: .Fade)
            }
            
            self.tableView.insertRowsAtIndexPaths(difference(afterPaths, beforePaths), withRowAnimation: .Fade)
            self.tableView.deleteRowsAtIndexPaths(difference(beforePaths, afterPaths), withRowAnimation: .Fade)
            self.tableView.reloadRowsAtIndexPaths(intersection(beforePaths, afterPaths), withRowAnimation: .Fade)
            
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

    func configureView() {
        if let label = self.lengthLabel {
            let str = NSString( format: "%d", self.appData[ "length" ] as Int? ?? 0 )
            label.text = str
        }
    }

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
    
    // MARK: - Observer
//    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
//        self.appDataChanged.append(keyPath)
//        println("observeValueForKeyPath=\(keyPath)")
//    }

    override func viewDidLoad() {
        super.viewDidLoad()

        for key in  [  "title", "url", "userid", "pass", "memo" ] {
            self.appData[ key ] = self.detailItem?.valueForKey( key )?.description
        }
        for key in [ "length", "option" ] {
            self.appData[ key ] = self.detailItem?.valueForKey( key )? as? Int
        }
        
//        self.keys.map {
//            (self.appData as NSDictionary).addObserver(self, forKeyPath: $0, options: (.New | .Old), context: nil)
//        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.configureButtons(animated: false)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//      self.title = self.detailItem?.valueForKey("title")?.description
        self.title = self.appData["title"] as? String
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        for key in self.appDataChanged {
            if let val: AnyObject? = self.appData[ key ] {
                self.detailItem!.setValue(val, forKey: key)
                if let indexPath = self.keyToIndexPath(key) {
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
            }
        }
        self.appDataChanged.removeAll(keepCapacity: false)
        
//        for closure in self.deferredClosure2 {
//            closure()
//        }
//        self.deferredClosure2 = Array<()->Void>()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        for key in self.appDataChanged {
            if let val: AnyObject? = self.appData[ key ] {
                self.detailItem!.setValue(val, forKey: key)
            }
        }
        if self.appDataChanged.count > 0 {
            let cdm = J1CoreDataManager.sharedInstance
            let context = cdm.managedObjectContext!
            var error: NSError? = nil
            if !context.save(&error) {
                abort()
            }
        }
        self.appDataChanged.removeAll(keepCapacity: false)

//        for closure in self.deferredClosure {
//            closure()
//        }
//        if self.deferredClosure.count > 0 {
//            let cdm = J1CoreDataManager.sharedInstance
//            let context = cdm.managedObjectContext!
//            var error: NSError? = nil
//            if !context.save(&error) {
//                abort()
//            }
//        }
//        self.deferredClosure = Array<()->Void>()
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
/*
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
*/
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
//                    if let tf = self.findSubview(cell.contentView, forClass: UITextField()) {
                    if let tf = (cell as? J1TextFieldCell)?.textField {
//                      tf.text        = self.detailItem?.valueForKey(key)?.description
                        tf.text        = self.appData[ key ] as? String
                        tf.placeholder = self._keyToPlaceholder[key]
                        tf.tag = tag
                        self.addTarget(tf, action: "tapped:", forControlEvents: .EditingDidEnd)
                        if key == "pass" {
                            self.passField = tf
                        }
                    }
                    
                case "length":
//                    if let stepper = self.findSubview(cell.contentView, forClass: UIStepper()) {
                    if let stepper = (cell as? J1StepperCell)?.stepper {
                        self.addTarget(stepper, action: "valueChanged:", forControlEvents: .ValueChanged)
                        stepper.minimumValue = Double( 0 )
                        stepper.maximumValue = Double( lengthArray.count - 1 )
                        stepper.stepValue    = Double( 1 )
                        stepper.value        = Double( 0 )
                        stepper.continuous   = false
                        if let len = self.appData[ "length" ] as? Int {
                            if let i = find(  self.lengthArray, self.appData[ "length" ] as Int ) {
                                stepper.value = Double( i )
                            }
                            else {
                                self.appData[ "length" ] = lengthArray[ 0 ]
                            }
                        }
                    }
//                    if let label = self.findSubview(cell.contentView, forClass: UILabel()) {
                    if let label = (cell as? J1StepperCell)?.label {
                        if self.lengthLabel != nil {
                            assert(self.lengthLabel == label, "lengthLabel is reallocated \(self.lengthLabel) \(label)")
                        }
                        self.lengthLabel = label
                        let str = NSString( format: "%d", self.appData[ "length" ] as Int? ?? 0 )
                        label.text = str
                    }

                case "picker":
//                  var pvs = cell.contentView.subviews.filter {$0 is UIPickerView}
//                        if pvs.count <= 0 || pvs.count > 1 {
//                            println( "\(cell) does not contain UIPickerView")
//                            return
//                        }
//                        let pv = pvs[0] as UIPickerView
                    if var pv = (cell as? J1PcikerCell)?.picker {
                        pv.delegate = self
                        pv.dataSource = self
                        pv.selectRow(self.appData[ "option"] as? Int ?? 0, inComponent: 0, animated: false)
                    }
                    
                case "generator":
                    if var button = (cell as? J1ButtonCell)?.button {
                        button.titleLabel?.text = "Password Generator"
                        button.addTarget(self, action: "tapped:", forControlEvents: .TouchDown)
                        let tag = self.keyToTag(key) ?? 0
                        button.tag = tag
                    }

                case "generated":
                    if var tf = (cell as? J1GeneratedPassCell)?.textField {
                        self.randomField = tf
//                        self.appData[ "random"] = self.randgen.getRandomString((self.appData[ "length"] as Int),
//                                    option: J1RandomOption(rawValue: (self.appData["option"] as Int))!)
                        tf.text = self.appData[ "random" ] as? String ?? ""
                    }
                    
                case "set":
                    if var button = (cell as? J1ButtonCell)?.button {
//                        button.titleLabel?.text = "Password Generator"
                        button.addTarget(self, action: "tapped:", forControlEvents: .TouchDown)
                        let tag = self.keyToTag(key) ?? 0
                        button.tag = tag
                    }
                    
                default:
                    assert(true, "\(key) is exhausted")
                }
            }
        }
        else {
            if let key = self.indexPathToKey(indexPath) {
//              cell.textLabel.text = self.detailItem?.valueForKey(key)?.description
                cell.textLabel?.text = self.appData[key] as? String
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
                cell = (tableView.dequeueReusableCellWithIdentifier("CellLength", forIndexPath: indexPath) as J1StepperCell)
            case "char":
                cell = (tableView.dequeueReusableCellWithIdentifier("CellCharacters", forIndexPath: indexPath) as UITableViewCell)
            case "picker":
                cell = (tableView.dequeueReusableCellWithIdentifier("CellPicker", forIndexPath: indexPath) as UITableViewCell)
            case "generator":
                cell = (tableView.dequeueReusableCellWithIdentifier("Cell-button", forIndexPath: indexPath) as J1ButtonCell)
            case "generated":
                cell = (tableView.dequeueReusableCellWithIdentifier("Cell-" + key!, forIndexPath: indexPath) as J1GeneratedPassCell)
            default:
                cell = (tableView.dequeueReusableCellWithIdentifier("CellEdit", forIndexPath: indexPath) as J1TextFieldCell)
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

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let key: String? = self.indexPathToKey(indexPath)
        switch key! {
        case "url":
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            if let str = cell?.textLabel?.text {
                if let url = NSURL(string: str) {
                    if UIApplication.sharedApplication().canOpenURL(url) {
                        UIApplication.sharedApplication().openURL(url)
                    }
                }
            }
        default:
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    // MARK: - UIControl Event
    func switchGenerator() {
        self.tableView.beginUpdates()
        
        let befPaths: [NSIndexPath] = self._keyToIndexPath.values.array
        let befSections: [Int] = befPaths.map { $0.section }
        
        self._generatorShowed = !self._generatorShowed
        
        let aftPaths: [NSIndexPath] = self._keyToIndexPath.values.array
        let aftSections: [Int] = aftPaths.map { $0.section }
        
        difference(aftSections, befSections).map {
            self.tableView.insertSections(NSIndexSet(index: $0), withRowAnimation: .Fade)
        }
        difference(befSections, aftSections).map {
            self.tableView.deleteSections(NSIndexSet(index: $0), withRowAnimation: .Fade)
        }
        
        self.tableView.insertRowsAtIndexPaths(difference(aftPaths, befPaths),   withRowAnimation: .Fade)
        self.tableView.deleteRowsAtIndexPaths(difference(befPaths, aftPaths),   withRowAnimation: .Fade)
        self.tableView.reloadRowsAtIndexPaths(intersection(befPaths, aftPaths), withRowAnimation: .Fade)
        
        self.tableView.endUpdates()
        
        if self._generatorShowed {
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refersh")
            self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        }
        else {
            self.refreshControl = nil
        }
    }
    
    func tapped(sender: AnyObject){
        if let key = self.tagToKey(sender.tag) {
            switch(key) {
            case "title", "url", "userid":
                let str = (sender as UITextField).text
                self.appData[key] = str
                self.appDataChanged.append(key)
//                self.deferredClosure.append { self.detailItem!.setValue(str, forKey: key) }
                
            case "pass":
                let str = (sender as UITextField).text
                self.appData[key] = str
                var pass = self.passManager.create(self.detailItem!)
                pass.pass   = self.appData["pass"] as String
                self.passManager.select(pass, site: self.detailItem!)
                self.appDataChanged.append(key)
//                self.deferredClosure.append { self.detailItem!.setValue(str, forKey: key) }

            case "generator":
                var str = self.passField?.text ?? self.detailItem!.pass
                self.appData[ "random" ] = str
                switchGenerator()
                self.appDataChanged.append("pass")
//                self.deferredClosure.append { self.detailItem!.setValue(self.appData[ "random" ], forKey: "pass") }
                
            case "set":
                self.appData[ "pass" ] = self.appData[ "random" ] as? String ?? ""
                var pass = self.passManager.create(self.detailItem)
                pass.pass   = self.appData["pass"] as String
                self.passManager.select(pass, site: self.detailItem!)
                switchGenerator()
                
            default:
                println("not implemented for \(key)")
            }
        }
        else {
            println("Unknown sender: \(sender.description)")
        }
    }
    
 
    func valueChanged( stepper: UIStepper! ) {
        self.appData[ "length" ] = self.lengthArray[ Int( round( stepper.value ) ) ]

        if let label = self.lengthLabel {
            let str = NSString( format: "%d", self.appData[ "length" ] as Int )
            label.text = str
        }
 
        if var tf = self.randomField {
            self.appData[ "random" ] = self.randgen.getRandomString((self.appData[ "length"] as Int),
                option: J1RandomOption(rawValue: (self.appData["option"] as Int))!)
            tf.text = self.appData[ "random" ] as String
        }
        self.appDataChanged.append("length")
//        self.deferredClosure.append { self.detailItem!.setValue(self.appData[ "length"], forKey: "length") }
       
    }

    func refresh(sender:AnyObject)
    {
        if var tf = self.randomField {
            self.appData[ "random" ] = self.randgen.getRandomString((self.appData[ "length"] as Int),
                option: J1RandomOption(rawValue: (self.appData["option"] as Int))!)
            tf.text = self.appData[ "random" ] as String
        }
        self.refreshControl!.endRefreshing()
//        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: false)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "ShowPass" {
            (segue.destinationViewController as PassViewController).context = self.detailItem
        }
        
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        return true
    }
    
    @IBAction func unwindToSiteView(segue: UIStoryboardSegue) {
        if let pvc: PassViewController = segue.sourceViewController as? PassViewController {
            let str = pvc.context!.selecting.pass
            self.appData[ "pass" ] = str
            self.appDataChanged.append("pass")

//            self.deferredClosure2.append {
//                self.detailItem?.setValue(str, forKey: "pass")
//                self.appData[ "pass" ] = str
////                self.tableView.reloadData()
//                if let indexPath = self.keyToIndexPath("pass") {
//                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//                }
//            }
        }
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
//        println("picker view selected")
        self.appData[ "option" ] = pickerView.selectedRowInComponent(0)
         if var tf = self.randomField {
          self.appData[ "random" ] = self.randgen.getRandomString((self.appData[ "length"] as Int),
            option: J1RandomOption(rawValue: (self.appData["option"] as Int))!)
          tf.text = self.appData[ "random" ] as String
        }
        self.appDataChanged.append("option")

//        let key = "option"
//        self.deferredClosure.append { self.detailItem!.setValue(self.appData[ key ], forKey: key) }
    }
}

// MARK: Cell Classes

class J1TextFieldCell: UITableViewCell {
    @IBOutlet var textField: UITextField!
}

class J1GeneratedPassCell: UITableViewCell {
    @IBOutlet var textField: UITextField!
}

class J1StepperCell: UITableViewCell {
    @IBOutlet var stepper: UIStepper!
    @IBOutlet var label: UILabel!
}

class J1PcikerCell: UITableViewCell {
    @IBOutlet var picker: UIPickerView!
}

class J1ButtonCell: UITableViewCell {
    @IBOutlet var button: UIButton!
}

