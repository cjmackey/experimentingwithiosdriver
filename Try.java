



import org.uiautomation.ios.IOSCapabilities;
import org.uiautomation.ios.UIAModels.*;
import org.uiautomation.ios.UIAModels.predicate.*;
import org.uiautomation.ios.client.uiamodels.impl.RemoteUIADriver;



public class Try {
    public static void main(String[] args) {
	
	IOSCapabilities cap = IOSCapabilities.iphone(System.getenv().get("APP_NAME"),
						     System.getenv().get("APP_VERSION"));
	    //						     "InternationalMountains", "1.1");
	//cap.setLanguage("zh-Hant");
	cap.setLanguage("en");
	
	RemoteUIADriver driver = new RemoteUIADriver("http://localhost:4444/wd/hub", cap);

	UIATarget target = driver.getLocalTarget();
	UIAWindow mainWindow = target.getFrontMostApp().getMainWindow();
	
	// find the first element of type UIATableCell.
	UIAElement element = mainWindow.findElement(new TypeCriteria(UIATableCell.class));
	element.tap();
	
	target.takeScreenshot("step2.png");
	
	driver.quit();
    }
}