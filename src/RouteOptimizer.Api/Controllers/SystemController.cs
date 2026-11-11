using Microsoft.AspNetCore.Mvc;

namespace RouteOptimizer.Api.Controllers;

[ApiController]
[Route("api/system")]
public sealed class SystemController(IConfiguration configuration) : ControllerBase
{
    [HttpGet("instance")]
    public ActionResult<InstanceResponse> GetInstance()
    {
        var instance = configuration["ROUTE_OPTIMIZER_INSTANCE"] ?? Environment.MachineName;
        return Ok(new InstanceResponse(instance));
    }
}

public sealed record InstanceResponse(string Instance);
