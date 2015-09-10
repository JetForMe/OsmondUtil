//
//  AppDelegate.swift
//  PCBPrep
//
//  Created by Roderick Mann on 9/9/2015.
//  Copyright © 2015 Latency: Zero, LLC. All rights reserved.
//

import Cocoa

import ZipZap

@NSApplicationMain
class
AppDelegate: NSObject, NSApplicationDelegate
{
	func
	applicationDidFinishLaunching(inNotification: NSNotification)
	{
	}

	func
	applicationWillTerminate(aNotification: NSNotification)
	{
	}

	func
	application(inApp: NSApplication, openFiles inFilenames: [String])
	{
		let urls = inFilenames.map
		{ inFile in
			return NSURL(fileURLWithPath: inFile)
		}
		
		let r = processFiles(urls)
		inApp.replyToOpenOrPrint(r ? .Success : .Failure)
	}
	
	func
	processFiles(inFiles: [NSURL])
		-> Bool
	{
		var urls = [NSURL]()
		for file in inFiles
		{
			let files = processFile(file)
			urls += files
		}
		
		//	Test each file against the dictionary to determine what to do…
		
		let d = [ "rename" : [
								"AUX1.GBR" : "$proj.gko",
								"LAYER1.GBR" : "$proj.gtl",
								"LAYER2.GBR" : "$proj.g2l",
								"LAYER3.GBR" : "$proj.g3l",
								"LAYER4.GBR" : "$proj.gbl",
								"MASK1.GBR" : "$proj.gts",
								"MASK2.GBR" : "$proj.gbs",
								"SILK1.GBR" : "$proj.gto",
								"SILK2.GBR" : "$proj.gbo",
								"DRILL.TXT" : "$proj.xln"
							]
		];
		
		//	Create the archive entries…
		
		var entries = [ZZArchiveEntry]()
		
		let renameD = d["rename"]
		let projectName = "Podtique"
		
		for url in urls
		{
			debugLog("File: \(url.path!)")
			
			guard var filename = url.lastPathComponent else
			{
				continue
			}
			
			//	Rename the file, if needed…
			
			if let rnd = renameD,
				let newName = rnd[filename]
			{
				//	If newName has template variables, replace them…
				
				if newName.containsString("$")
				{
					filename = newName.stringByReplacingTempalteVar("proj", with: projectName)
				}
				else
				{
					filename = newName
				}
				debugLog("Renamed to: \(filename)")
				
				//	Only add to the archive if it was found in the dictionary…
				
				let ae = ZZArchiveEntry(fileName: filename, compress: true)
				{ (outError) -> NSData! in
					let data = NSData(contentsOfURL: url)
					return data
				}
				entries.append(ae)
			}
			
		}
		
		//	Make the zipfile…
		
		do
		{
			let dirs = NSSearchPathForDirectoriesInDomains(.DesktopDirectory, .UserDomainMask, true)
			let dir = NSURL(fileURLWithPath: dirs[0])
			let archiveURL = dir.URLByAppendingPathComponent("\(projectName).zip")
			let za = try ZZArchive(URL: archiveURL, options: [ZZOpenOptionsCreateIfMissingKey : true])
			try za.updateEntries(entries)
			
			debugLog("Archive written to: \(archiveURL.path!)")
			return true
		}
		
		catch
		{
			debugLog("An error occurred writing the archive")
			return false
		}
	}
	
	func
	processFile(inFile: NSURL)
		-> [NSURL]
	{
		guard let path = inFile.path else
		{
			debugLog("Bad URL: \(inFile)")
			return [NSURL]()
		}
		
		let fm = NSFileManager.defaultManager()
		var isDir: ObjCBool = false
		if !fm.fileExistsAtPath(path, isDirectory: &isDir)
		{
			return [NSURL]()
		}
		
		//	If it’s a directory, iterate its contents…
		
		if isDir
		{
			do
			{
				let urls = try fm.contentsOfDirectoryAtURL(inFile, includingPropertiesForKeys: nil, options: [.SkipsHiddenFiles, .SkipsPackageDescendants, .SkipsSubdirectoryDescendants])
				return urls
			}
			
			catch
			{
				debugLog("Exception getting directory contents")
				return [NSURL]()
			}
		}
		
		//	It’s not a directory, return it in an array…
		
		return [inFile]
	}
}


extension
String
{
	func
	stringByReplacingTempalteVar(inVar: String, with inReplacement: String)
		-> String
	{
		if let r = self.rangeOfString("$\(inVar)")
		{
			var s = self
			s.replaceRange(r, with: inReplacement)
			return s
		}
		return self
	}
}

public
func
debugLog<T>(inMsg: T, _ inFile : String = __FILE__, _ inLine : Int = __LINE__)
{
	let file = (inFile as NSString).lastPathComponent
	print("\(file):\(inLine)    \(inMsg)")
}
