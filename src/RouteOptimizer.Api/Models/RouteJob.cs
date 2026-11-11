using RouteOptimizer.Api.Data;

namespace RouteOptimizer.Api.Models;

public sealed class RouteJob
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid UserId { get; set; }

    public ApplicationUser User { get; set; } = null!;

    public string InputJson { get; set; } = "{}";

    public RouteJobStatus Status { get; set; } = RouteJobStatus.Queued;

    public int Progress { get; set; }

    public string? ResultJson { get; set; }

    public string? ErrorMessage { get; set; }

    public DateTimeOffset CreatedAtUtc { get; set; } = DateTimeOffset.UtcNow;

    public DateTimeOffset? StartedAtUtc { get; set; }

    public DateTimeOffset? CompletedAtUtc { get; set; }
}
