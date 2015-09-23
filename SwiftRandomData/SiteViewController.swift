//
//  SiteViewController.swift
//  SwiftRandomData
//
//  Created by OKU Junichirou on 2014/10/05.
//  Copyright (c) 2014年 OKU Junichirou. All rights reserved.
//

import UIKit
import CoreData

class SiteViewController: UITableViewController {

    // MARK: - Managers
    var passManager: PassManager   = PassManager.sharedManager()

    // MARK: - Properties
    
    var detailItem: Site? = nil
    var proxy: J1ManagedObjectProxy?
    
    // MARK: - Instances
    var random = ""
    
    let lengthArray          = [ 4, 5, 6, 8, 10, 12, 14, 16, 20, 24, 32 ]
    var lengthLabel: UILabel?
    
    
    let charsArray: [CypherCharacters] = [
        CypherCharacters.Digits,                // "0-9"
        CypherCharacters.UpperCaseLetters,      // "0-A-Z"
        CypherCharacters.LowerCaseLetters,      // "0-Z a-z"
        CypherCharacters.ArithmeticCharacters,  // "0-z *+-/"
        CypherCharacters.AlphaNumericSymbols    // "0-z !#$%*+-/=?@^_|~"
        ]
 
    let charsArrayString: [CypherCharacters: String] = [
        CypherCharacters.Digits:                "0-9",
        CypherCharacters.UpperCaseLetters:      "0-A-Z",
        CypherCharacters.LowerCaseLetters:      "0-Za-z",
        CypherCharacters.ArithmeticCharacters:  "0-z*+-/",
        CypherCharacters.AlphaNumericSymbols:   "!#$%?@^_|~"
    ]

    var optionLabel: UILabel?
    
    var passField: UITextField?
    
    var randgen = J1RandomData()
    var randomField: UITextField?
    
    let STEPPER_LENGTH = 1
    let STEPPER_OPTION = 2
    
    let cipherMan = J1CipherMan()


    // MARK: - Coordinator functions between keys and index paths

//    let keys: [String] = [ "title", "url", "userid", "pass", "memo", "length", "option" ]
    
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
                            "option":    NSIndexPath(forRow: 2, inSection:2),
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

            let beforePaths: [NSIndexPath] = Array( self._keyToIndexPath.values )
            let beforeSections: [Int] = beforePaths.map { $0.section }
            
            self._editing = editing
            if !self._editing && self._generatorShowed {
                self.refreshControl = nil
                self._generatorShowed = false
            }
            
            let afterPaths: [NSIndexPath]  = Array( self._keyToIndexPath.values )
            let afterSections: [Int] = afterPaths.map { $0.section }
            
            _ = difference(afterSections, y: beforeSections).map {
                self.tableView.insertSections(NSIndexSet(index: $0), withRowAnimation: .Fade)
            }
            _ = difference(beforeSections, y: afterSections).map {
                self.tableView.deleteSections(NSIndexSet(index: $0), withRowAnimation: .Fade)
            }
            
            self.tableView.insertRowsAtIndexPaths(difference(afterPaths, y: beforePaths), withRowAnimation: .Fade)
            self.tableView.deleteRowsAtIndexPaths(difference(beforePaths, y: afterPaths), withRowAnimation: .Fade)
            self.tableView.reloadRowsAtIndexPaths(intersection(beforePaths, y: afterPaths), withRowAnimation: .Fade)
            
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
            let str = NSString( format: "%d", self.proxy!.valueForKey("length") as! Int? ?? 0 )
            label.text = str as String
        }
    }

    func configureButtons(animated animated: Bool) {
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
        
        self.proxy = J1ManagedObjectProxy(managedObject: self.detailItem!)

        self.configureButtons(animated: false)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.title = self.proxy!.valueForKey("title") as? String
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.proxy!.hasChanges {
            self.proxy!.writeBack {
                (key, val) in
                if let indexPath = self.keyToIndexPath(key as! String) {
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)

                }
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        let changed = self.proxy!.hasChanges
        self.proxy!.writeBack { (key, val) in }
        if changed {
            let cdm = J1CoreDataManager.sharedInstance
            let context = cdm.managedObjectContext!
            var error: NSError? = nil
            _ = error
            do {
                try context.save()
            } catch let error1 as NSError {
                error = error1
                abort()
            }
            
        }
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
        for (_, val) in self._keyToIndexPath {
            sec = max( sec, val.section)
        }
        return sec + 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        var rows = 0
        for (_, val) in self._keyToIndexPath {
            if section == val.section {
                rows = max( rows, val.row )
            }
        }
        return rows + 1
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
            print("\(action.description) is already added for event \(controlEvents) in \(control)")
        }
        
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        if  self.editing() {
            if let key = self.indexPathToKey(indexPath) {
                switch key {
                case "title", "url", "userid", "pass", "memo":
                    let tag = self.keyToTag(key) ?? 0
                    // get a text field view
                    if let tf = (cell as? J1TextFieldCell)?.textField {
                        tf.text        = self.proxy!.valueForKey(key) as? String
                        tf.placeholder = self._keyToPlaceholder[key]
                        tf.tag = tag
                        self.addTarget(tf, action: "tapped:", forControlEvents: .EditingDidEnd)
                        if key == "pass" {
                            self.passField = tf
                        }
                    }
                    
                case "length":
                    if let stepper = (cell as? J1StepperCell)?.stepper {
                        self.addTarget(stepper, action: "valueChanged:", forControlEvents: .ValueChanged)
                        stepper.minimumValue = Double( 0 )
                        stepper.maximumValue = Double( lengthArray.count - 1 )
                        stepper.stepValue    = Double( 1 )
                        stepper.value        = Double( 0 )
                        stepper.continuous   = false
                        stepper.tag          = STEPPER_LENGTH
                        
                        if let len = self.proxy!.valueForKey("length") as? Int {
                            if let i = self.lengthArray.indexOf(len ) {
                                stepper.value = Double( i )
                            }
                            else {
                                self.proxy!.setValue(lengthArray[0], forKey: "length")
                            }
                        }
                    }
                    if let label = (cell as? J1StepperCell)?.label {
                        if self.lengthLabel != nil {
                            assert(self.lengthLabel == label, "lengthLabel is reallocated \(self.lengthLabel) \(label)")
                        }
                        self.lengthLabel = label
                        let str = NSString( format: "%d", self.proxy!.valueForKey("length") as! Int? ?? 0 )
                        label.text = str as String
                    }

                case "option":
                    if let stepper = (cell as? J1StepperCell)?.stepper {
                        self.addTarget(stepper, action: "valueChanged:", forControlEvents: .ValueChanged)
                        stepper.minimumValue = Double(0)
                        stepper.maximumValue = Double(charsArray.count - 1)
                        stepper.stepValue    = Double(1)
                        stepper.continuous   = false
                        stepper.tag          = STEPPER_OPTION

                        var elm = 0
                        if let num = self.proxy!.valueForKey("option") as? NSNumber {
                            if let e = charsArray.map({CypherCharacters(rawValue: num.unsignedIntValue).distance($0)}).enumerate().minElement({$0.1 < $1.1}) {
                            elm = e.0
                            }
                        }
//                        var elm = 0
//                        var min = CypherCharacters.Digits.distance(.Digits)
//                        if let num = self.proxy!.valueForKey("option") as? NSNumber {
//                            for (idx, val) in charsArray.map({
//                                    CypherCharacters(rawValue: num.unsignedIntValue).distance($0)
//                            }).enumerate() {
//                                if val <= min {
//                                    min = val
//                                    elm = idx
//                                }
//                            }
//                        }
                        let opt = charsArray[elm]
                        stepper.value = Double( elm )

                        let label = (cell as! J1StepperCell).label
                        if self.optionLabel != nil {
                            assert(self.optionLabel == label, "optionLabel is reallocated \(self.optionLabel) \(label)")
                        }
                        self.optionLabel = label
                        if let str = charsArrayString[opt] {
                            label.text = str
                        }
                        else {
                            label.text = ""
                        }
                    }
                    
                case "generator":
                    if let button = (cell as? J1ButtonCell)?.button {
                        button.titleLabel?.text = "Password Generator"
                        button.addTarget(self, action: "tapped:", forControlEvents: .TouchDown)
                        let tag = self.keyToTag(key) ?? 0
                        button.tag = tag
                    }

                case "generated":
                    if let tf = (cell as? J1GeneratedPassCell)?.textField {
                        self.randomField = tf
                        tf.text = self.random
                    }
                    
                case "set":
                    if let button = (cell as? J1ButtonCell)?.button {
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
                cell.textLabel?.text = self.proxy!.valueForKey(key) as? String
                cell.accessoryType = (key == "url" || key == "pass") ? .DisclosureIndicator : .None
            }
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.rowHeight
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        
        if self.editing() {
            let key: String? = self.indexPathToKey(indexPath)
            switch key! {
            case "set":
                cell = (tableView.dequeueReusableCellWithIdentifier("CellSet", forIndexPath: indexPath) as UITableViewCell)
            case "length":
                cell = (tableView.dequeueReusableCellWithIdentifier("CellLength", forIndexPath: indexPath) as! J1StepperCell)
            case "option":
                cell = (tableView.dequeueReusableCellWithIdentifier("CellOption", forIndexPath: indexPath) as! J1StepperCell)
            case "char":
                cell = (tableView.dequeueReusableCellWithIdentifier("CellCharacters", forIndexPath: indexPath) as UITableViewCell)
            case "generator":
                cell = (tableView.dequeueReusableCellWithIdentifier("Cell-button", forIndexPath: indexPath) as! J1ButtonCell)
            case "generated":
                cell = (tableView.dequeueReusableCellWithIdentifier("Cell-" + key!, forIndexPath: indexPath) as! J1GeneratedPassCell)
            default:
                cell = (tableView.dequeueReusableCellWithIdentifier("CellEdit", forIndexPath: indexPath) as! J1TextFieldCell)
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
        
        let befPaths: [NSIndexPath] = Array(self._keyToIndexPath.values)
        let befSections: [Int] = befPaths.map { $0.section }
        
        self._generatorShowed = !self._generatorShowed
        
        let aftPaths: [NSIndexPath] = Array(self._keyToIndexPath.values)
        let aftSections: [Int] = aftPaths.map { $0.section }
        
        _ = difference(aftSections, y: befSections).map {
            self.tableView.insertSections(NSIndexSet(index: $0), withRowAnimation: .Fade)
        }
        _ = difference(befSections, y: aftSections).map {
            self.tableView.deleteSections(NSIndexSet(index: $0), withRowAnimation: .Fade)
        }
        
        self.tableView.insertRowsAtIndexPaths(difference(aftPaths, y: befPaths),   withRowAnimation: .Fade)
        self.tableView.deleteRowsAtIndexPaths(difference(befPaths, y: aftPaths),   withRowAnimation: .Fade)
        self.tableView.reloadRowsAtIndexPaths(intersection(befPaths, y: aftPaths), withRowAnimation: .Fade)
        
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
                let str = (sender as! UITextField).text
                self.proxy!.setValue(str, forKey: key)
                
            case "pass":
                let str = (sender as! UITextField).text
                self.proxy!.setValue(str, forKey: key)
                let pass = self.passManager.create(self.detailItem!)
                pass.pass   = self.proxy!.valueForKey("pass") as! String
                self.passManager.select(pass, site: self.detailItem!)

            case "generator":
                let str = self.passField?.text ?? self.detailItem!.pass
                self.random = str
                switchGenerator()
                
            case "set":
                self.proxy!.setValue(self.random, forKey: "pass")
                let pass = self.passManager.create(self.detailItem)
                pass.pass   = self.proxy!.valueForKey("pass") as! String
                self.passManager.select(pass, site: self.detailItem!)
                switchGenerator()
                
            default:
                print("not implemented for \(key)")
            }
        }
        else {
            print("Unknown sender: \(sender.description)")
        }
    }
    
 
    func valueChanged(stepper: UIStepper!) {
        switch stepper.tag {
        case STEPPER_LENGTH:
            self.proxy!.setValue(self.lengthArray[ Int( round( stepper.value ) ) ], forKey: "length")
            if let label = self.lengthLabel {
                let str = NSString( format: "%d", self.proxy!.valueForKey("length") as! Int )
                label.text = str as String
            }
        case STEPPER_OPTION:
            let val = Int(round(stepper.value))
            let opt = charsArray[val]
            self.proxy!.setValue(NSNumber(unsignedInt: opt.rawValue), forKey: "option")
            if let label = self.optionLabel {
                if let str = charsArrayString[opt] {
                    label.text = str
                }
                else {
                    label.text = ""
                }
            }
        default:
            _ = Int(round(stepper.value))
        }
        

        if let label = self.lengthLabel {
            let str = NSString( format: "%d", self.proxy!.valueForKey("length") as! Int )
            label.text = str as String
        }
 
        if let tf = self.randomField {
            let len = self.proxy!.valueForKey("length") as! Int
            var opt = CypherCharacters.Digits
            if let val = self.proxy!.valueForKey("option") as? NSNumber {
                opt = CypherCharacters(rawValue: val.unsignedIntValue)
            }
            self.random = self.randgen.getRandomString( len, chars: opt )!
            tf.text = self.random
        }
       
    }

    func refresh(sender:AnyObject)
    {
        if let tf = self.randomField {
            let len = self.proxy!.valueForKey("length") as! Int
            var opt = CypherCharacters.Digits
            if let val = self.proxy!.valueForKey("option") as? NSNumber {
                opt = CypherCharacters(rawValue: val.unsignedIntValue)
            }
            self.random = self.randgen.getRandomString( len, chars: opt )!
        tf.text = self.random
    }
        self.refreshControl!.endRefreshing()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "ShowPass" {
            (segue.destinationViewController as! PassViewController).context = self.detailItem
        }
        
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        var result = false
        if let cell: UITableViewCell = sender as? UITableViewCell {
            let indexPath = self.tableView.indexPathForCell(cell)
            let key = self.indexPathToKey(indexPath!)
            result = key == "pass"
            
        }
        return result
    }
    
    @IBAction func unwindToSiteView(segue: UIStoryboardSegue) {
        if let pvc: PassViewController = segue.sourceViewController as? PassViewController {
            let str = pvc.context!.selecting.pass
            self.proxy!.setValue(str, forKey: "pass")
        }
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

class J1ButtonCell: UITableViewCell {
    @IBOutlet var button: UIButton!
}

