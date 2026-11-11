using RouteOptimizer.Api.Data;

namespace RouteOptimizer.Api.Services;

public interface IAccessTokenService
{
    Task<AccessToken> CreateAsync(ApplicationUser user, CancellationToken cancellationToken);
}

public sealed record AccessToken(string Value, DateTimeOffset ExpiresAtUtc);
