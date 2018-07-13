//
//  ViewController.swift
//  XStartFileTransform
//
//  Created by Sylar on 2018/7/12.
//  Copyright © 2018年 Sylar. All rights reserved.
//

import Cocoa
import SnapKit


class ViewController: NSViewController,NSAlertDelegate {
    var hud:MBProgressHUD!;
    
    var alert = NSAlert()
    
    var projectSourcePath:NSMutableDictionary = NSMutableDictionary()
    
    var fileNameDataSource = [String]() ;
    
    var filePathArray = [NSString]();
    
    @IBOutlet weak var fileNameTableView: NSTableView!
    
    @IBOutlet weak var mainFileFolderLockBtn: NSButton!

    @IBOutlet weak var mainFileFolderPathTextField: NSTextField!
    
    @IBOutlet weak var projectFolderPathTextField: NSTextField!
    
    @IBOutlet weak var projectFolderLockBtn: NSButton!
    
    @IBOutlet weak var projectSubFolderLockBtn: NSButton!
    
    
    @IBOutlet weak var projectSubFolderPathTextField: NSTextField!
    
    
    @IBOutlet weak var beginProcessBtn: NSButton!
    

    @IBOutlet weak var BeautyCameraCheckBox: NSButton!
    
    @IBOutlet weak var XStarCheckBox: NSButton!
    
    @IBOutlet weak var JaneCheckBox: NSButton!
    
    @IBOutlet weak var ArtCheckBox: NSButton!
    
    @IBOutlet weak var InterPhotoCheckBox: NSButton!
    
    @IBOutlet weak var PocoCameraCheckBox: NSButton!
    
    
    @IBOutlet weak var overWriteBtn: NSButton!
    
    
    @IBOutlet var logsTextView: NSTextView!
    
    
    var logStringConsole:NSMutableString = NSMutableString()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alert.messageText = "项目路径不能为空!"
        alert.delegate = self;
        alert.addButton(withTitle: "OK");
        fileNameTableView.delegate = self;
        fileNameTableView.dataSource = self;
        logStringConsole = ""
        
        self.logWithStringString("Launch");
        
        let userDefault = UserDefaults.standard;
        //New Source Path Init
        if userDefault.bool(forKey: "mainPathLock") {
            mainFileFolderLockBtn.state = NSControl.StateValue(rawValue: 1)
            mainFileFolderPathTextField.stringValue = userDefault.object(forKey: "mainPath") as! String;
            mainFileFolderPathTextField.isEditable = false;
        }else{
            mainFileFolderLockBtn.state = NSControl.StateValue(rawValue: 0)
            mainFileFolderPathTextField.stringValue = "";
            mainFileFolderPathTextField.isEditable = true;
        }
        
        //Project Source Init
        if userDefault.bool(forKey: "projectPathLock") {
            projectFolderLockBtn.state = NSControl.StateValue(rawValue: 1);
            projectFolderPathTextField.stringValue = userDefault.object(forKey: "projectPath") as! String;
            projectFolderPathTextField.isEditable = false;
        }else{
            projectFolderLockBtn.state = NSControl.StateValue(rawValue: 0);
            projectFolderPathTextField.stringValue = "";
            projectFolderPathTextField.isEditable = true;
        }
        
        if userDefault.bool(forKey: "projectSubPathLock") {
            projectSubFolderLockBtn.state = NSControl.StateValue(rawValue: 1);
            projectSubFolderPathTextField.stringValue = userDefault.object(forKey: "projectSubPath") as! String;
            projectSubFolderPathTextField.isEditable = false;
        }else{
            projectSubFolderLockBtn.state = NSControl.StateValue(rawValue: 0);
            projectSubFolderPathTextField.stringValue = "";
            projectSubFolderPathTextField.isEditable = true;
        }

        
    }
    
    //Begin Transfer
    @IBAction func BeginTransformAction(_ sender: Any) {
        if mainFileFolderPathTextField.stringValue.isEmpty || projectFolderPathTextField.stringValue.isEmpty {
            alert.beginSheetModal(for: view.window!, completionHandler: nil);
            return;
        }
        hud = MBProgressHUD.showAdded(to: self.view, animated: true);
        hud.detailsLabelText = "Processing";

        let filemanager = FileManager.default
        
        //Check Source File Folder
        if !filemanager.fileExists(atPath: mainFileFolderPathTextField.stringValue) {
            self.hudWithTextOnly("新素材文件夹不存在");
            self.logWithStringString("Folder is not exists")
            return;
        }
        
        //Scaning
        self.hudWithLoadingText("Scaning");
        
        filePathArray .removeAll();
        
        do {
            try filePathArray = filemanager.contentsOfDirectory(atPath: mainFileFolderPathTextField.stringValue) as [NSString];
        } catch _ {
            self.hudWithTextOnly("读取素材文件列表错误")
            return;
        }
        
        //Remove .DS_store
        filePathArray = filePathArray.filter{($0 != ".DS_Store")};
        //备份文件夹
        filePathArray = filePathArray.filter{($0 != "BackUP")}
        fileNameDataSource = NSArray.init(array: filePathArray) as! [String]
//        fileArray = fileArray.map({mainFileFolderPathTextField.stringValue + "/" + $0})
        
        
        fileNameTableView.reloadData()
        
        //Genearte Destination Dic
        self.configDestinationDic()
        
        //Transfer
        self.beginTransfering()
        
        //End
        self.hudWithTextOnly("Transfer Completed")
        
        self.fileNameDataSource .removeAll()
        
        self.fileNameTableView.reloadData()
    }
    
    @IBAction func mainPathLockBtnToggle(_ sender: NSButton) {
        let userDefault = UserDefaults.standard;
        userDefault.set(mainFileFolderPathTextField.stringValue, forKey: "mainPath");
        if sender.state.rawValue == 0 {
            //Selected -> UnSelected
            mainFileFolderPathTextField.isEditable = true;
            userDefault.set(false, forKey: "mainPathLock");
        }else{
            mainFileFolderPathTextField.isEditable = false;
            userDefault.set(true, forKey: "mainPathLock");
        }
        
    }
    
    
    @IBAction func projectPathLockBtnToggle(_ sender: NSButton) {
        let userDefault = UserDefaults.standard;
        userDefault.set(projectFolderPathTextField.stringValue, forKey: "projectPath");
        if sender.state.rawValue == 0 {
            //Selected -> UnSelected
            projectFolderPathTextField.isEditable = true;
            userDefault.set(false, forKey: "projectPathLock");
        }else{
            projectFolderPathTextField.isEditable = false;
            userDefault.set(true, forKey: "projectPathLock");
        }
            
    }
    
    
    @IBAction func projectSubPathLockBtnToggle(_ sender: NSButton) {
        let userDefault = UserDefaults.standard;
        userDefault.set(projectSubFolderPathTextField.stringValue, forKey: "projectSubPath");
        if sender.state.rawValue == 0 {
            //Selected -> UnSelected
            projectSubFolderPathTextField.isEditable = true;
            userDefault.set(false, forKey: "projectSubPathLock");
        }else{
            projectSubFolderPathTextField.isEditable = false;
            userDefault.set(true, forKey: "projectSubPathLock");
        }
    }
    


    func hudWithTextOnly(_ textString:String) -> Void {
        hud.removeFromSuperViewOnHide = true;
        hud.hide(false);
        hud = MBProgressHUD.showAdded(to: self.view, animated: true);
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = textString;
        hud.margin = 10;
        hud.yOffset = 150;
        hud.removeFromSuperViewOnHide = true;
        hud.hide(true, afterDelay: 1);
    }
    
    func hudWithLoadingText(_ textSring:String) -> Void {
        hud.removeFromSuperViewOnHide = true;
        hud.hide(false);
        hud = MBProgressHUD.showAdded(to: self.view, animated: true);
        hud.removeFromSuperViewOnHide = true;
        hud.detailsLabelText = textSring;
    }
    
    func hideHUD() -> Void {
        hud.removeFromSuperViewOnHide = true;
        hud.hide(false);
    }
    
    
    func logWithStringString(_ logString:NSString) -> Void {
        if (logString as String).isEmpty {
            return;
        }
        logStringConsole.append((logString as String)+"\r\n")
        
        self.logsTextView.string = logStringConsole as String
    }
    
    
    func configDestinationDic() -> Void {
        self.projectSourcePath.removeAllObjects()
        let BeautyCamera = "BeautyCamera";
        let XStar = "XStar";
        let Jane = "Jane";
        let Art = "Art";
        let InterPhoto = "InterPhoto";
        let Poco = "Poco";
        
        //Appen projectPath
        let mainPath = projectFolderPathTextField.stringValue;
        let subPath = projectSubFolderPathTextField.stringValue;
        
        if BeautyCameraCheckBox.state.rawValue == 1 {
            var destinationPath = ""
            destinationPath = (mainPath as NSString).appendingPathComponent(BeautyCamera)
            destinationPath = (destinationPath as NSString).appendingPathComponent(subPath)
            projectSourcePath.setValue(destinationPath, forKey: BeautyCamera)
        }
        
        if XStarCheckBox.state.rawValue == 1 {
            var destinationPath = ""
            destinationPath = (mainPath as NSString).appendingPathComponent(XStar)
            destinationPath = (destinationPath as NSString).appendingPathComponent(subPath)
            projectSourcePath.setValue(destinationPath, forKey: XStar)
        }
        
        if JaneCheckBox.state.rawValue == 1 {
            var destinationPath = ""
            destinationPath = (mainPath as NSString).appendingPathComponent(Jane)
            destinationPath = (destinationPath as NSString).appendingPathComponent(subPath)
            projectSourcePath.setValue(destinationPath, forKey: Jane)
        }
        
        if ArtCheckBox.state.rawValue == 1 {
            var destinationPath = ""
            destinationPath = (mainPath as NSString).appendingPathComponent(Art)
            destinationPath = (destinationPath as NSString).appendingPathComponent(subPath)
            projectSourcePath.setValue(destinationPath, forKey: Art)
        }
        
        if InterPhotoCheckBox.state.rawValue == 1 {
            var destinationPath = ""
            destinationPath = (mainPath as NSString).appendingPathComponent(InterPhoto)
            destinationPath = (destinationPath as NSString).appendingPathComponent(subPath)
            projectSourcePath.setValue(destinationPath, forKey: InterPhoto)
        }
        
        if PocoCameraCheckBox.state.rawValue == 1 {
            var destinationPath = ""
            destinationPath = (mainPath as NSString).appendingPathComponent(Poco)
            destinationPath = (destinationPath as NSString).appendingPathComponent(subPath)
            projectSourcePath.setValue(destinationPath, forKey: Poco)
        }
        
        
    }
    
    
    func beginTransfering() -> Void {
        self.hudWithLoadingText("Transfering")
        let fileManager = FileManager.default
        let oriBackupFolder = (mainFileFolderPathTextField.stringValue as NSString).appendingPathComponent("BackUP")
        if !fileManager.fileExists(atPath: oriBackupFolder) {
            do{
               try fileManager.createDirectory(atPath: oriBackupFolder, withIntermediateDirectories: true, attributes: nil);
            }catch{
                self.logWithStringString(error.localizedDescription as NSString)
            }
            
        }
        
        if filePathArray.count == 0{
            self.hideHUD()
            self.hudWithTextOnly("素材文件夹无文件")
            return
        }
        
        self.logWithStringString("Create Original BackUP File")
        
        
        
        for fileName in filePathArray {
            let Scr = (mainFileFolderPathTextField.stringValue as NSString).appendingPathComponent(fileName as String)
            let oriBackupFilePath = (oriBackupFolder as NSString).appendingPathComponent(fileName as String);
            do {
                if fileManager.fileExists(atPath: oriBackupFilePath){
                    try fileManager.removeItem(atPath: oriBackupFilePath)
                }
                try fileManager.copyItem(atPath: Scr, toPath: oriBackupFilePath);
            }catch{
                self.logWithStringString(error.localizedDescription as NSString)
            }
            
            
            for (_,value) in projectSourcePath{
                    print(value)
                do{
                    
                    let Des = (value as! NSString).appendingPathComponent(fileName as String);
                    
                    if fileManager.fileExists(atPath: Des) {
                        if overWriteBtn.state.rawValue == 0{
                            //BackUP
                            let DesBackUp = (value as! NSString).appendingPathComponent((fileName as String) + ".backUP");
                            if fileManager.fileExists(atPath: DesBackUp){
                                try fileManager.removeItem(atPath: DesBackUp);
                            }
                            try fileManager.copyItem(atPath: Des, toPath: DesBackUp);
                            
                            self.logWithStringString("Did Backup Destination File")
                        }
                        
                        //fileExists
                        //OverWrite
                        try fileManager.removeItem(atPath: Des);
                        
                        let message = "Destination File" + Des + "Removed"
                        self.logWithStringString(message as NSString)
                    }
                    
                    try fileManager.copyItem(atPath: Scr as String, toPath: Des)
                    
                    let message = "Ori File" + Scr + "Transfering To" + Des;
                    self.logWithStringString(message as NSString)
                    
                    
                    
                    
                } catch {
                     self.logWithStringString(error.localizedDescription as NSString)
                }
                
                
            }
            
            
            try! fileManager.removeItem(atPath: Scr)
            
            
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
   
    

}


extension ViewController:NSTableViewDataSource{
    func numberOfRows(in tableView: NSTableView) -> Int {
        return fileNameDataSource.count;
    }
}

extension ViewController:NSTableViewDelegate{

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellIdentifier =  "NameCellID"
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView{
            cell.textField?.stringValue = fileNameDataSource[row];
            return cell
        }
        return nil;
    }
}


