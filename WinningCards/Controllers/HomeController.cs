using System.Web.Mvc;
using WinningCards.Models;

namespace WinningCards.Controllers
{
    
    public class HomeController : Controller
    {
        // GET: Home
        public ActionResult Index()
        {
            return View(new Config());
        }
    }
}