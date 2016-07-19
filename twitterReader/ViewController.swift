import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "FirstVC"
        
        var startFinishButton = UIButton(type: UIButtonType.System)
        startFinishButton.frame = CGRectMake(100, 100, 100, 50)
        startFinishButton.backgroundColor = UIColor.greenColor()
        startFinishButton.setTitle("Test Button", forState: UIControlState.Normal)
//        startFinishButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(startFinishButton)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

