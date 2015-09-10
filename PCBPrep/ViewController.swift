//
//  ViewController.swift
//  PCBPrep
//
//  Created by Roderick Mann on 9/9/2015.
//  Copyright © 2015 Latency: Zero, LLC. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

	override
	func
	viewDidLoad()
	{
		super.viewDidLoad()
		
		self.dropZone.registerForDraggedTypes([NSFilenamesPboardType])
	}

	override var representedObject: AnyObject? {
		didSet {
		// Update the view, if already loaded.
		}
	}


	@IBOutlet weak var dropZone: DropZone!
}


class
DropZone : NSView
{
	override
	func
	drawRect(inDirtyRect: NSRect)
	{
		let bkndColor = self.dropping ? NSColor.grayColor() : NSColor.lightGrayColor()
		bkndColor.set()
		
		let p = NSBezierPath(rect: self.bounds)
		p.fill()
	}
	
	func
	showDropping()
	{
		self.dropping = true
		self.needsDisplay = true
		self.dropLabel.textColor = NSColor(white: 0.7, alpha: 1.0)
	}
	
	func
	showNotDropping()
	{
		self.dropping = false
		self.needsDisplay = true
		self.dropLabel.textColor = NSColor(white: 0.5, alpha: 1.0)
	}
	
	override
	func
	draggingEntered(inInfo: NSDraggingInfo)
		-> NSDragOperation
	{
		//	Make sure we have files…
		
		let pboard = inInfo.draggingPasteboard()
		guard let pboardTypes = pboard.types where pboardTypes.contains(NSFilenamesPboardType) else
		{
			return .None
		}
		
		//	We’ve got files, show the imminent drop…
		
		showDropping()
		
		return .Generic
	}
	
	override
	func
	draggingExited(inInfo: NSDraggingInfo?)
	{
		//	User exited, reset the UI…
		
		showNotDropping()
	}
	
	override
	func
	performDragOperation(inInfo: NSDraggingInfo)
		-> Bool
	{
		showNotDropping()
		
		let pboard = inInfo.draggingPasteboard()
		guard let pboardTypes = pboard.types where pboardTypes.contains(NSFilenamesPboardType) else
		{
			return false
		}
		
		if let files = pboard.propertyListForType(NSFilenamesPboardType) as? [String]
		{
			let urls = files.map
			{
				return NSURL(fileURLWithPath: $0)
			}
		
			let ad = NSApp.delegate as! AppDelegate
			ad.processFiles(urls)
			
			return true
		}
		
		return false
	}
	
	
	
	var dropping				=	false
	
	@IBOutlet weak var dropLabel: NSTextField!
}
