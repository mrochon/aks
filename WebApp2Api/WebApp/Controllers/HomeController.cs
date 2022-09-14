using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;
using System.Net;
using WebApp.Models;

namespace WebApp.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;
        private readonly string _apiBaseUrl;

        public HomeController(ILogger<HomeController> logger)
        {
            _logger = logger;
            _apiBaseUrl = Environment.GetEnvironmentVariable("WebApiBaseAddress") ?? "http://api";
        }

        public IActionResult Index()
        {
            ViewBag.api = _apiBaseUrl;
            return View();
        }

        public async Task<IActionResult> Privacy()
        {
            _logger.LogInformation("Starting API call");

            var http = new HttpClient();
            ViewBag.weather = await http.GetStringAsync($"{_apiBaseUrl}/weatherforecast");  


            //HttpClientHandler httpClientHandler = new HttpClientHandler();
            //httpClientHandler.ServerCertificateCustomValidationCallback = (message, cert, chain, errors) => {
            //    _logger.LogInformation("API server cert accepted");
            //    return true; 
            //};
            //var http = new HttpClient(httpClientHandler);
            //http.DefaultRequestHeaders.Add("Accept", "application/json");
            ////var resp = await http.GetStringAsync("https://localhost:51443/weatherforecast");  //cannot assign requested address
            //var req = new HttpRequestMessage(HttpMethod.Get, $"{_apiBaseUrl}/weatherforecast");
            //try
            //{
            //    var resp = await http.SendAsync(req);
            //    ViewBag.weather = await resp.Content.ReadAsStringAsync();
            //} catch(Exception ex)
            //{
            //    _logger.LogError(ex, "Error calling API");
            //    throw;
            //}
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}