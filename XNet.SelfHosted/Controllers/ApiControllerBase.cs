using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace XNet.SelfHosted.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(AuthenticationSchemes = "Bearer")]
public abstract class ApiControllerBase : ControllerBase
{
    protected string? UserId => User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
}
