using backend.BLL.DTOs.Project;
using backend.BLL.Interfaces;
using backend.DAL.Interfaces;
using backend.DAL.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.BLL.Services;

public class ProjectService : IProjectService
{
    private readonly IUnitOfWork _unitOfWork;

    public ProjectService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<IEnumerable<ProjectDto>> GetProjectsByClassAsync(int classId)
    {
        var projects = await _unitOfWork.Repository<Project>().GetQueryable()
            .Include(p => p.Milestones)
                .ThenInclude(m => m.Submissions)
            .Where(p => p.ClassId == classId)
            .ToListAsync();

        return projects.Select(p => new ProjectDto
        {
            Id = p.Id,
            ClassId = p.ClassId,
            Title = p.Title,
            Description = p.Description,
            MilestoneCount = p.Milestones.Count,
            CompletedMilestones = p.Milestones.Count(m => m.Submissions.Any()),
            Milestones = p.Milestones.Select(m => new MilestoneDto
            {
                Id = m.Id,
                ProjectId = m.ProjectId,
                Title = m.Title,
                Description = m.Description,
                DueDate = m.DueDate
            }).ToList()
        });
    }

    public async Task<ProjectDto?> GetProjectByIdAsync(int id)
    {
        var project = await _unitOfWork.Repository<Project>().GetQueryable()
            .Include(p => p.Milestones)
                .ThenInclude(m => m.Submissions)
            .FirstOrDefaultAsync(p => p.Id == id);
            
        if (project == null) return null;

        return new ProjectDto
        {
            Id = project.Id,
            ClassId = project.ClassId,
            Title = project.Title,
            Description = project.Description,
            MilestoneCount = project.Milestones.Count,
            CompletedMilestones = project.Milestones.Count(m => m.Submissions.Any()),
            Milestones = project.Milestones.Select(m => new MilestoneDto
            {
                Id = m.Id,
                ProjectId = m.ProjectId,
                Title = m.Title,
                Description = m.Description,
                DueDate = m.DueDate
            }).ToList()
        };
    }

    public async Task<ProjectDto> CreateProjectAsync(CreateProjectDto dto)
    {
        var project = new Project
        {
            ClassId = dto.ClassId,
            Title = dto.Title,
            Description = dto.Description
        };

        await _unitOfWork.Repository<Project>().AddAsync(project);
        await _unitOfWork.SaveChangesAsync();

        return new ProjectDto
        {
            Id = project.Id,
            ClassId = project.ClassId,
            Title = project.Title,
            Description = project.Description
        };
    }

    public async Task<bool> DeleteProjectAsync(int id)
    {
        var project = await _unitOfWork.Repository<Project>().GetByIdAsync(id);
        if (project == null) return false;

        _unitOfWork.Repository<Project>().Delete(project);
        await _unitOfWork.SaveChangesAsync();
        return true;
    }

    public async Task<IEnumerable<MilestoneDto>> GetMilestonesByProjectAsync(int projectId)
    {
        var milestones = await _unitOfWork.Repository<Milestone>().GetQueryable()
            .Where(m => m.ProjectId == projectId)
            .ToListAsync();

        return milestones.Select(m => new MilestoneDto
        {
            Id = m.Id,
            ProjectId = m.ProjectId,
            Title = m.Title,
            Description = m.Description,
            DueDate = m.DueDate
        });
    }

    public async Task<MilestoneDto?> GetMilestoneByIdAsync(int id)
    {
        var milestone = await _unitOfWork.Repository<Milestone>().GetByIdAsync(id);
        if (milestone == null) return null;

        return new MilestoneDto
        {
            Id = milestone.Id,
            ProjectId = milestone.ProjectId,
            Title = milestone.Title,
            Description = milestone.Description,
            DueDate = milestone.DueDate
        };
    }

    public async Task<MilestoneDto> CreateMilestoneAsync(CreateMilestoneDto dto)
    {
        var milestone = new Milestone
        {
            ProjectId = dto.ProjectId,
            Title = dto.Title,
            Description = dto.Description,
            DueDate = dto.DueDate ?? DateTime.UtcNow.AddDays(7)
        };

        await _unitOfWork.Repository<Milestone>().AddAsync(milestone);
        await _unitOfWork.SaveChangesAsync();

        return new MilestoneDto
        {
            Id = milestone.Id,
            ProjectId = milestone.ProjectId,
            Title = milestone.Title,
            Description = milestone.Description,
            DueDate = milestone.DueDate
        };
    }

    public async Task<bool> DeleteMilestoneAsync(int id)
    {
        var milestone = await _unitOfWork.Repository<Milestone>().GetByIdAsync(id);
        if (milestone == null) return false;

        _unitOfWork.Repository<Milestone>().Delete(milestone);
        await _unitOfWork.SaveChangesAsync();
        return true;
    }

    public async Task<MilestoneSubmissionDto> SubmitMilestoneAsync(CreateMilestoneSubmissionDto dto, int userId)
    {
        var milestone = await _unitOfWork.Repository<Milestone>().GetByIdAsync(dto.MilestoneId)
            ?? throw new KeyNotFoundException("Không tìm thấy Milestone.");

        var submission = new MilestoneSubmission
        {
            MilestoneId = dto.MilestoneId,
            UserId = userId,
            FileUrl = dto.FileUrl,
            Description = dto.Description,
            SubmittedAt = DateTime.UtcNow
        };

        await _unitOfWork.Repository<MilestoneSubmission>().AddAsync(submission);
        await _unitOfWork.SaveChangesAsync();

        var user = await _unitOfWork.Repository<User>().GetByIdAsync(userId);

        return new MilestoneSubmissionDto
        {
            Id = submission.Id,
            MilestoneId = submission.MilestoneId,
            UserId = submission.UserId,
            UserFullName = user?.FullName ?? "Unknown User",
            FileUrl = submission.FileUrl,
            Description = submission.Description,
            SubmittedAt = submission.SubmittedAt
        };
    }

    public async Task<IEnumerable<MilestoneSubmissionDto>> GetSubmissionsByMilestoneAsync(int milestoneId)
    {
        var submissions = await _unitOfWork.Repository<MilestoneSubmission>().GetQueryable()
            .Include(s => s.User)
            .Where(s => s.MilestoneId == milestoneId)
            .ToListAsync();

        return submissions.Select(s => new MilestoneSubmissionDto
        {
            Id = s.Id,
            MilestoneId = s.MilestoneId,
            UserId = s.UserId,
            UserFullName = s.User?.FullName ?? "Unknown User",
            FileUrl = s.FileUrl,
            Description = s.Description,
            SubmittedAt = s.SubmittedAt
        });
    }
}
