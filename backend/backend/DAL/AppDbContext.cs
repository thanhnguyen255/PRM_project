using backend.DAL.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.DAL;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    // ── DbSets ──────────────────────────────────────────────────────────────
    public DbSet<User>                 Users                { get; set; }
    public DbSet<Course>               Courses              { get; set; }
    public DbSet<Class>                Classes              { get; set; }
    public DbSet<ClassMember>          ClassMembers         { get; set; }
    public DbSet<LearningPath>         LearningPaths        { get; set; }
    public DbSet<LearningMaterial>     LearningMaterials    { get; set; }
    public DbSet<Activity>             Activities           { get; set; }
    public DbSet<ActivitySubmission>   ActivitySubmissions  { get; set; }
    public DbSet<EvidenceComment>      EvidenceComments     { get; set; }
    public DbSet<Project>              Projects             { get; set; }
    public DbSet<Milestone>            Milestones           { get; set; }
    public DbSet<MilestoneSubmission>  MilestoneSubmissions { get; set; }
    public DbSet<ReviewSession>        ReviewSessions       { get; set; }
    public DbSet<ReviewAssignment>     ReviewAssignments    { get; set; }
    public DbSet<Feedback>             Feedbacks            { get; set; }
    public DbSet<Notification>         Notifications        { get; set; }

    // ── Fluent API Configuration ─────────────────────────────────────────────
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // ── User ──────────────────────────────────────────────────────────────
        modelBuilder.Entity<User>(entity =>
        {
            entity.HasIndex(u => u.Email).IsUnique();

            entity.Property(u => u.Email).HasMaxLength(255).IsRequired();
            entity.Property(u => u.PasswordHash).HasMaxLength(500).IsRequired();
            entity.Property(u => u.FullName).HasMaxLength(100).IsRequired();
            entity.Property(u => u.AvatarUrl).HasMaxLength(500);
        });

        // ── Course ────────────────────────────────────────────────────────────
        modelBuilder.Entity<Course>(entity =>
        {
            entity.HasOne(c => c.Instructor)
                  .WithMany(u => u.Courses)
                  .HasForeignKey(c => c.InstructorId)
                  .OnDelete(DeleteBehavior.Restrict);

            entity.Property(c => c.Title).HasMaxLength(200).IsRequired();
            entity.Property(c => c.Description).HasMaxLength(2000);
            entity.Property(c => c.CoverImageUrl).HasMaxLength(500);
        });

        // ── Class ─────────────────────────────────────────────────────────────
        modelBuilder.Entity<Class>(entity =>
        {
            entity.HasOne(c => c.Course)
                  .WithMany(co => co.Classes)
                  .HasForeignKey(c => c.CourseId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.Property(c => c.Name).HasMaxLength(100).IsRequired();
        });

        // ── ClassMember ───────────────────────────────────────────────────────
        modelBuilder.Entity<ClassMember>(entity =>
        {
            // Unique: 1 user chỉ join 1 lớp 1 lần
            entity.HasIndex(cm => new { cm.ClassId, cm.UserId }).IsUnique();

            entity.HasOne(cm => cm.Class)
                  .WithMany(c => c.Members)
                  .HasForeignKey(cm => cm.ClassId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(cm => cm.User)
                  .WithMany(u => u.ClassMembers)
                  .HasForeignKey(cm => cm.UserId)
                  .OnDelete(DeleteBehavior.Restrict);
        });

        // ── LearningPath ──────────────────────────────────────────────────────
        modelBuilder.Entity<LearningPath>(entity =>
        {
            entity.HasOne(lp => lp.Class)
                  .WithMany(c => c.LearningPaths)
                  .HasForeignKey(lp => lp.ClassId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.Property(lp => lp.Title).HasMaxLength(200).IsRequired();
        });

        // ── LearningMaterial ──────────────────────────────────────────────────
        modelBuilder.Entity<LearningMaterial>(entity =>
        {
            entity.HasOne(lm => lm.LearningPath)
                  .WithMany(lp => lp.Materials)
                  .HasForeignKey(lm => lm.LearningPathId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.Property(lm => lm.Title).HasMaxLength(200).IsRequired();
            entity.Property(lm => lm.FileUrl).HasMaxLength(500);
            entity.Property(lm => lm.LinkUrl).HasMaxLength(500);
        });

        // ── Activity ──────────────────────────────────────────────────────────
        modelBuilder.Entity<Activity>(entity =>
        {
            entity.HasOne(a => a.LearningPath)
                  .WithMany(lp => lp.Activities)
                  .HasForeignKey(a => a.LearningPathId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.Property(a => a.Title).HasMaxLength(200).IsRequired();
            entity.Property(a => a.Description).HasMaxLength(3000);
        });

        // ── ActivitySubmission ────────────────────────────────────────────────
        modelBuilder.Entity<ActivitySubmission>(entity =>
        {
            entity.HasOne(s => s.Activity)
                  .WithMany(a => a.Submissions)
                  .HasForeignKey(s => s.ActivityId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(s => s.User)
                  .WithMany(u => u.Submissions)
                  .HasForeignKey(s => s.UserId)
                  .OnDelete(DeleteBehavior.Restrict);

            entity.Property(s => s.FileUrl).HasMaxLength(500);
            entity.Property(s => s.Note).HasMaxLength(2000);
        });

        // ── EvidenceComment ───────────────────────────────────────────────────
        modelBuilder.Entity<EvidenceComment>(entity =>
        {
            entity.HasOne(ec => ec.Submission)
                  .WithMany(s => s.Comments)
                  .HasForeignKey(ec => ec.SubmissionId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(ec => ec.User)
                  .WithMany(u => u.Comments)
                  .HasForeignKey(ec => ec.UserId)
                  .OnDelete(DeleteBehavior.Restrict);

            entity.Property(ec => ec.Content).HasMaxLength(1000).IsRequired();
        });

        // ── Project ───────────────────────────────────────────────────────────
        modelBuilder.Entity<Project>(entity =>
        {
            entity.HasOne(p => p.Class)
                  .WithMany(c => c.Projects)
                  .HasForeignKey(p => p.ClassId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.Property(p => p.Title).HasMaxLength(200).IsRequired();
            entity.Property(p => p.Description).HasMaxLength(3000);
        });

        // ── Milestone ─────────────────────────────────────────────────────────
        modelBuilder.Entity<Milestone>(entity =>
        {
            entity.HasOne(m => m.Project)
                  .WithMany(p => p.Milestones)
                  .HasForeignKey(m => m.ProjectId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.Property(m => m.Title).HasMaxLength(200).IsRequired();
            entity.Property(m => m.Description).HasMaxLength(2000);
        });

        // ── MilestoneSubmission ───────────────────────────────────────────────
        modelBuilder.Entity<MilestoneSubmission>(entity =>
        {
            entity.HasOne(ms => ms.Milestone)
                  .WithMany(m => m.Submissions)
                  .HasForeignKey(ms => ms.MilestoneId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(ms => ms.User)
                  .WithMany(u => u.MilestoneSubmissions)
                  .HasForeignKey(ms => ms.UserId)
                  .OnDelete(DeleteBehavior.Restrict);

            entity.Property(ms => ms.FileUrl).HasMaxLength(500);
            entity.Property(ms => ms.Description).HasMaxLength(2000);
        });

        // ── ReviewSession ─────────────────────────────────────────────────────
        modelBuilder.Entity<ReviewSession>(entity =>
        {
            entity.HasOne(rs => rs.Class)
                  .WithMany(c => c.ReviewSessions)
                  .HasForeignKey(rs => rs.ClassId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(rs => rs.Activity)
                  .WithMany()
                  .HasForeignKey(rs => rs.ActivityId)
                  .OnDelete(DeleteBehavior.NoAction);

            entity.Property(rs => rs.Title).HasMaxLength(200).IsRequired();
        });

        // ── ReviewAssignment ──────────────────────────────────────────────────
        // ReviewerId và RevieweeId đều FK đến User → phải dùng NoAction
        // để tránh multiple cascade paths trong SQL Server
        modelBuilder.Entity<ReviewAssignment>(entity =>
        {
            entity.HasOne(ra => ra.Session)
                  .WithMany(rs => rs.Assignments)
                  .HasForeignKey(ra => ra.SessionId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(ra => ra.Reviewer)
                  .WithMany()
                  .HasForeignKey(ra => ra.ReviewerId)
                  .OnDelete(DeleteBehavior.NoAction);

            entity.HasOne(ra => ra.Reviewee)
                  .WithMany()
                  .HasForeignKey(ra => ra.RevieweeId)
                  .OnDelete(DeleteBehavior.NoAction);
        });

        // ── Feedback ──────────────────────────────────────────────────────────
        modelBuilder.Entity<Feedback>(entity =>
        {
            entity.HasOne(f => f.Assignment)
                  .WithMany(ra => ra.Feedbacks)
                  .HasForeignKey(f => f.AssignmentId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.Property(f => f.Content).HasMaxLength(2000).IsRequired();
            entity.Property(f => f.Rating).IsRequired();
        });

        // ── Notification ──────────────────────────────────────────────────────
        modelBuilder.Entity<Notification>(entity =>
        {
            entity.HasOne(n => n.User)
                  .WithMany(u => u.Notifications)
                  .HasForeignKey(n => n.UserId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.Property(n => n.Title).HasMaxLength(200).IsRequired();
            entity.Property(n => n.Body).HasMaxLength(500).IsRequired();
        });
    }
}
