using System.Web.Mvc;
using WinningCards.Models;

namespace WinningCards.Controllers
{
    
    public class HomeController : Controller
    {
        // GET: Home
        public ActionResult Index()
        {
            Global.Logger.Debug("Home controller - Index view called");
            return View(new Config());
        }
    }
}