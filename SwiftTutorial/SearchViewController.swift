//
//  ViewController.swift
//  SwiftTutorial
//
//  Created by Hoang-Minh Nguyen on 10/4/14.
//  Copyright (c) 2014 minnavtech. All rights reserved.
//

import UIKit
import QuartzCore

class SearchResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, APIControllerProtocol
{
    //Properties
    var imageCache = [String: UIImage]()
    let kCellIdentifier: String = "SearchResultCell"
    var api : APIController?
    
    @IBOutlet weak var appTableView: UITableView!
    var albums = [Album]()
    var tableData = []
    
    //Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        api = APIController(delegate: self)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        api!.searchItunesFor("Beatles")
//        self.api.delegate = self
//        api.searchItunesFor("Angry Birds")
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //TableView Implementation
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    //Set Up TableView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell : UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MyTestCell")
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as! UITableViewCell
        let rowData = self.albums[indexPath.row]
//        cell.textLabel?.text = "Row #\(indexPath.row)"
//        cell.detailTextLabel?.text = "Subtitle #\(indexPath.row)"
        //Add a check to make sure this exists
        cell.textLabel?.text = rowData.title
        cell.imageView?.image = UIImage(named: "Blank52")
        //Get the formatted price string for display in the subtitle
        let formattedPrice = rowData.price
        
        //Jump into the background thread to get the image for this item
        let urlString = rowData.thumbnailImageURL
        //Check our image cache for the existing key. This is just a dictionary of UIImages
        var image = self.imageCache[urlString]
        if(image == nil) {
            var imgURL: NSURL = NSURL(string: urlString)!
            let request: NSURLRequest = NSURLRequest(URL: imgURL)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                if error == nil {
                    image = UIImage(data: data)
                    //Store the image in to our cache
                    self.imageCache[urlString] = image
                    dispatch_async(dispatch_get_main_queue(), {
                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                            cellToUpdate.imageView?.image = image
                        }
                    })
                }
                else {
                    println("Error: \(error.localizedDescription)")
                }
            })
        }
        else {
            dispatch_async(dispatch_get_main_queue(), {
                if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                    cellToUpdate.imageView?.image = image
                }
            })
        }
        cell.detailTextLabel?.text = formattedPrice
        return cell
    }
    
    //Table Cell Click Delegate Functions
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
////        let rowData: NSDictionary = self.tableData[indexPath.row] as NSDictionary
////        var name: String = rowData["trackName"] as String
////        var formattedPrice: String = rowData["formattedPrice"] as String
//        var alert: UIAlertView = UIAlertView()
////        alert.title = name
////        alert.message = formattedPrice
//        alert.title = "Test"
//        alert.message = "Message"
//        alert.addButtonWithTitle("OK")
//        alert.show()
//    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animateWithDuration(0.25, animations: {
           cell.layer.transform = CATransform3DMakeScale(1,1,1)
        })
    }
    //Custom methods
    func didReceiveAPIResults(results: NSDictionary) {
        //Moved from funcSearchItunes
        var resultsArr: NSArray = results["results"] as! NSArray
        dispatch_async(dispatch_get_main_queue(), {
            self.albums = Album.albumsWithJSON(resultsArr)
            self.appTableView!.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }

    //Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var detailsViewController: DetailsViewController = segue.destinationViewController as! DetailsViewController
        var albumIndex = appTableView!.indexPathForSelectedRow()!.row
        var selectedAlbum = self.albums[albumIndex]
        detailsViewController.album = selectedAlbum
    }
}
