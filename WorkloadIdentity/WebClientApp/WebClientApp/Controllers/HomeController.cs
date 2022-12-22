using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using Microsoft.Identity.Client;
using System.Diagnostics;
using System.Text;
using System.Text.Json.Nodes;
using WebClientApp.Models;

namespace WebClientApp.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;
        private readonly ConfidentialClientApplicationOptions _msalConfiguration;
        //private readonly IOptions<ConfidentialClientApplicationOptions> _msalConfiguration;
        private bool _confIsNull;

        public HomeController(ILogger<HomeController> logger, IOptions<ConfidentialClientApplicationOptions> msal)
        {
            _logger = logger;
            _confIsNull = (msal == null) || (msal.Value == null);
            if (_confIsNull)
            {
                _msalConfiguration = new ConfidentialClientApplicationOptions
                {
                    Instance = "https://login.microsoftonline.com",
                    ClientId = "6f377fa5-9da4-47bc-8fca-090b4a361870",
                    TenantId = "beitmerari.com"
                };
            } else
                _msalConfiguration = msal!.Value!;
        }

        public IActionResult Index()
        {
            return View();
        }

        //string _k8sToken = @"eyJhbGciOiJSUzI1NiIsImtpZCI6IjVmX3o0bDFsWHVpa0RINkVzYVhUT2xmZjJlNm1ZT3J2R2pheXNLYkFFbXMifQ.eyJhdWQiOlsiYXBpIl0sImV4cCI6MTY3MTQwMTA5MywiaWF0IjoxNjcxMzk3NDkzLCJpc3MiOiJodHRwczovL2t1YmVybmV0ZXMuZGVmYXVsdC5zdmMuY2x1c3Rlci5sb2NhbCIsImt1YmVybmV0ZXMuaW8iOnsibmFtZXNwYWNlIjoiZGVmYXVsdCIsInBvZCI6eyJuYW1lIjoiYXBpLWNsaWVudC03N2Y1NDk3Nzg1LWdtZ3diIiwidWlkIjoiYzZlYjQ5NjAtMzkzZi00OGQxLWE0OWMtYjU1ZjY1M2I0N2UzIn0sInNlcnZpY2VhY2NvdW50Ijp7Im5hbWUiOiJkZWZhdWx0IiwidWlkIjoiZTZmNGM4NDQtMDA3Yi00YzJkLTkzYjgtNWU4MmQ4ZTUxYjQxIn19LCJuYmYiOjE2NzEzOTc0OTMsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpkZWZhdWx0OmRlZmF1bHQifQ.AjsZl0nfEi0vjy8rV8Mw6-YbVf_L9K8ICiMxbNZm8dYvb4Ke7A9PM-L38FruNqKw0keLaDppLwOFzRX7Y27YX6xq9xlvIqDIwcDiW0I7SrRuD9WE7qcn0TYapvPKuWFc0J4wwb0joHxiDdfbEG2h8qZMx9V1j16leGQvdwDa8X5wOmeu1uU24QW5ttFUo-Epe0gXrsK5hT8IAwh5EdrUcLGJef0li2M_xa-FkIIL-riCH6-xeg5DVMz852SpoOksxWwIExpvBeEHZkvmMoZaWcHPmayybqPpZn_toChTNq9eMzpRhWk0w6vRLnpWQs3F8de_HpNAsC1I5uYYkW-3vQ";

        public async Task<IActionResult> Privacy()
        {
            var output = new List<string>();
            output.Add("Starting");
            try
            {
                output.Add($"Configuration was present: {_confIsNull}");
                _logger.LogInformation("Looking for k8s token");
                output.Add("Looking for k8s token");

                output.Add($"ClientId={_msalConfiguration.ClientId}");
                string k8sToken = String.Empty;
                try
                {
                    using (var sr = new StreamReader("/service-account/token"))
                    {
                        k8sToken = await sr.ReadToEndAsync();
                        _logger.LogInformation($"k8s token: {k8sToken}");
                        output.Add($"k8s token: {k8sToken}");
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex.Message);
                    output.Add(ex.Message);
                }
                if (!string.IsNullOrEmpty(k8sToken))
                {
                    _logger.LogInformation("Creating msal client");
                    output.Add("Creating msal client");
                    var msal = ConfidentialClientApplicationBuilder
                        .CreateWithApplicationOptions(_msalConfiguration)
                        .WithClientAssertion(k8sToken)
                        .Build();

                    try
                    {
                        _logger.LogInformation("Acquiring token");
                        output.Add("Acquiring token");
                        var tokens = await msal.AcquireTokenForClient(new string[] { "https://graph.microsoft.com/.default" }).ExecuteAsync();
                        _logger.LogInformation(tokens.AccessToken);
                        output.Add(tokens.AccessToken);
                    }
                    catch (MsalServiceException ex)
                    {
                        //_logger.LogError(ex.Message);
                        //output.Add(ex.Message);
                        var err = JsonNode.Parse(ex.ResponseBody);
                        _logger.LogError((string)err!["error_description"]!);
                        output.Add((string)err!["error_description"]!);
                    }
                }
            } catch(Exception ex)
            {
                output.Add(ex.Message);
            }

            return View(output);
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}