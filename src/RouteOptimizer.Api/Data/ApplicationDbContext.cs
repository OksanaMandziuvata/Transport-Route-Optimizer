using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using RouteOptimizer.Api.Models;

namespace RouteOptimizer.Api.Data;

public sealed class ApplicationDbContext(
    DbContextOptions<ApplicationDbContext> options)
    : IdentityDbContext<ApplicationUser, IdentityRole<Guid>, Guid>(options)
{
    public DbSet<RouteJob> RouteJobs => Set<RouteJob>();

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        builder.Entity<ApplicationUser>().ToTable("users");
        builder.Entity<IdentityRole<Guid>>().ToTable("roles");
        builder.Entity<IdentityUserRole<Guid>>().ToTable("user_roles");
        builder.Entity<IdentityUserClaim<Guid>>().ToTable("user_claims");
        builder.Entity<IdentityUserLogin<Guid>>().ToTable("user_logins");
        builder.Entity<IdentityRoleClaim<Guid>>().ToTable("role_claims");
        builder.Entity<IdentityUserToken<Guid>>().ToTable("user_tokens");

        builder.Entity<RouteJob>(entity =>
        {
            entity.ToTable("route_jobs");
            entity.HasKey(job => job.Id);
            entity.Property(job => job.Status)
                .HasConversion<string>()
                .HasMaxLength(24)
                .IsRequired();
            entity.Property(job => job.InputJson).HasColumnType("jsonb").IsRequired();
            entity.Property(job => job.ResultJson).HasColumnType("jsonb");
            entity.Property(job => job.ErrorMessage).HasMaxLength(1000);
            entity.HasIndex(job => new { job.UserId, job.CreatedAtUtc });
            entity.HasOne(job => job.User)
                .WithMany()
                .HasForeignKey(job => job.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });
    }
}
