using backend.BLL.DTOs.Evidence;
using backend.BLL.Interfaces;
using backend.DAL.Interfaces;
using backend.DAL.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.BLL.Services;

public class EvidenceService : IEvidenceService
{
    private readonly IUnitOfWork _unitOfWork;

    public EvidenceService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<IEnumerable<EvidenceDto>> GetEvidencesAsync(int? classId, int instructorId)
    {
        var query = _unitOfWork.Repository<ActivitySubmission>().GetQueryable()
            .Include(s => s.User)
            .Include(s => s.Activity)
            .ThenInclude(a => a.LearningPath)
            .ThenInclude(lp => lp.Class)
            .ThenInclude(c => c.Course)
            .Where(s => s.Activity.LearningPath.Class.Course.InstructorId == instructorId);

        if (classId.HasValue)
        {
            query = query.Where(s => s.Activity.LearningPath.ClassId == classId.Value);
        }

        var submissions = await query.ToListAsync();

        return submissions.Select(s => new EvidenceDto
        {
            Id = s.Id,
            ActivityId = s.ActivityId,
            ActivityTitle = s.Activity.Title,
            UserId = s.UserId,
            UserFullName = s.User.FullName,
            FileUrl = s.FileUrl,
            Note = s.Note,
            Status = s.Status,
            SubmittedAt = s.SubmittedAt
        });
    }

    public async Task<EvidenceDto?> GetEvidenceByIdAsync(int id, int userId)
    {
        var s = await _unitOfWork.Repository<ActivitySubmission>().GetQueryable()
            .Include(s => s.User)
            .Include(s => s.Activity)
            .ThenInclude(a => a.LearningPath)
            .ThenInclude(lp => lp.Class)
            .ThenInclude(c => c.Course)
            .FirstOrDefaultAsync(s => s.Id == id && 
                (s.Activity.LearningPath.Class.Course.InstructorId == userId || s.UserId == userId));

        if (s == null) return null;

        return new EvidenceDto
        {
            Id = s.Id,
            ActivityId = s.ActivityId,
            ActivityTitle = s.Activity.Title,
            UserId = s.UserId,
            UserFullName = s.User.FullName,
            FileUrl = s.FileUrl,
            Note = s.Note,
            Status = s.Status,
            SubmittedAt = s.SubmittedAt
        };
    }

    public async Task<EvidenceDto?> UpdateEvidenceStatusAsync(int id, UpdateEvidenceStatusDto dto, int instructorId)
    {
        var s = await _unitOfWork.Repository<ActivitySubmission>().GetQueryable()
            .Include(s => s.User)
            .Include(s => s.Activity)
            .ThenInclude(a => a.LearningPath)
            .ThenInclude(lp => lp.Class)
            .ThenInclude(c => c.Course)
            .FirstOrDefaultAsync(s => s.Id == id && s.Activity.LearningPath.Class.Course.InstructorId == instructorId);

        if (s == null) return null;

        s.Status = dto.Status;
        s.ReviewedAt = DateTime.UtcNow;

        _unitOfWork.Repository<ActivitySubmission>().Update(s);
        await _unitOfWork.SaveChangesAsync();

        return new EvidenceDto
        {
            Id = s.Id,
            ActivityId = s.ActivityId,
            ActivityTitle = s.Activity.Title,
            UserId = s.UserId,
            UserFullName = s.User.FullName,
            FileUrl = s.FileUrl,
            Note = s.Note,
            Status = s.Status,
            SubmittedAt = s.SubmittedAt
        };
    }

    public async Task<IEnumerable<EvidenceCommentDto>> GetCommentsByEvidenceIdAsync(int evidenceId, int userId)
    {
        // Verify user is either the instructor of the course OR the learner who submitted it
        var submissionExists = await _unitOfWork.Repository<ActivitySubmission>().GetQueryable()
            .Include(s => s.Activity)
            .ThenInclude(a => a.LearningPath)
            .ThenInclude(lp => lp.Class)
            .ThenInclude(c => c.Course)
            .AnyAsync(s => s.Id == evidenceId && 
                (s.Activity.LearningPath.Class.Course.InstructorId == userId || s.UserId == userId));

        if (!submissionExists) return [];

        var comments = await _unitOfWork.Repository<EvidenceComment>().GetQueryable()
            .Include(c => c.User)
            .Where(c => c.SubmissionId == evidenceId)
            .OrderBy(c => c.CreatedAt)
            .ToListAsync();

        return comments.Select(c => new EvidenceCommentDto
        {
            Id = c.Id,
            SubmissionId = c.SubmissionId,
            UserId = c.UserId,
            UserFullName = c.User.FullName,
            UserRole = c.User.Role,
            Content = c.Content,
            CreatedAt = c.CreatedAt
        });
    }

    public async Task<EvidenceCommentDto?> AddCommentToEvidenceAsync(int evidenceId, CreateEvidenceCommentDto dto, int userId)
    {
        // Verify user exists
        var user = await _unitOfWork.Repository<User>().GetByIdAsync(userId);
        if (user == null) return null;

        // Verify evidence exists
        var submission = await _unitOfWork.Repository<ActivitySubmission>().GetByIdAsync(evidenceId);
        if (submission == null) return null;

        var comment = new EvidenceComment
        {
            SubmissionId = evidenceId,
            UserId = userId,
            Content = dto.Content,
            CreatedAt = DateTime.UtcNow
        };

        await _unitOfWork.Repository<EvidenceComment>().AddAsync(comment);
        await _unitOfWork.SaveChangesAsync();

        return new EvidenceCommentDto
        {
            Id = comment.Id,
            SubmissionId = comment.SubmissionId,
            UserId = comment.UserId,
            UserFullName = user.FullName,
            UserRole = user.Role,
            Content = comment.Content,
            CreatedAt = comment.CreatedAt
        };
    }

    public async Task<EvidenceDto?> SubmitEvidenceAsync(CreateEvidenceDto dto, int learnerId)
    {
        var user = await _unitOfWork.Repository<User>().GetByIdAsync(learnerId);
        if (user == null) return null;

        var activity = await _unitOfWork.Repository<Activity>().GetByIdAsync(dto.ActivityId);
        if (activity == null) return null;

        if (activity.Deadline.HasValue && DateTime.UtcNow > activity.Deadline.Value)
        {
            throw new ArgumentException("Đã quá thời hạn nộp bài, hệ thống đã khóa chức năng này.");
        }

        string? fileUrl = null;
        if (dto.File != null && dto.File.Length > 0)
        {
            var uploadsFolder = backend.BLL.Helpers.UploadPaths.Root;
            if (!Directory.Exists(uploadsFolder))
            {
                Directory.CreateDirectory(uploadsFolder);
            }

            var uniqueFileName = Guid.NewGuid().ToString() + "_" + Path.GetFileName(dto.File.FileName);
            var filePath = Path.Combine(uploadsFolder, uniqueFileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await dto.File.CopyToAsync(stream);
            }

            fileUrl = "/uploads/" + uniqueFileName;
        }

        var existingSubmission = await _unitOfWork.Repository<ActivitySubmission>().GetQueryable()
            .FirstOrDefaultAsync(s => s.ActivityId == dto.ActivityId && s.UserId == learnerId);

        ActivitySubmission finalSubmission;

        if (existingSubmission != null)
        {
            if (existingSubmission.Status == backend.DAL.Enums.EvidenceStatus.Approved)
            {
                throw new ArgumentException("Bài nộp đã được duyệt, không thể nộp lại.");
            }

            existingSubmission.FileUrl = fileUrl ?? existingSubmission.FileUrl;
            existingSubmission.Note = dto.Note;
            existingSubmission.Status = backend.DAL.Enums.EvidenceStatus.Pending;
            existingSubmission.SubmittedAt = DateTime.UtcNow;

            _unitOfWork.Repository<ActivitySubmission>().Update(existingSubmission);
            finalSubmission = existingSubmission;
        }
        else
        {
            var submission = new ActivitySubmission
            {
                ActivityId = dto.ActivityId,
                UserId = learnerId,
                FileUrl = fileUrl,
                Note = dto.Note,
                Status = backend.DAL.Enums.EvidenceStatus.Pending,
                SubmittedAt = DateTime.UtcNow
            };
            await _unitOfWork.Repository<ActivitySubmission>().AddAsync(submission);
            finalSubmission = submission;
        }
        await _unitOfWork.SaveChangesAsync();

        return new EvidenceDto
        {
            Id = finalSubmission.Id,
            ActivityId = finalSubmission.ActivityId,
            ActivityTitle = activity.Title,
            UserId = learnerId,
            UserFullName = user.FullName,
            FileUrl = finalSubmission.FileUrl,
            Note = finalSubmission.Note,
            Status = finalSubmission.Status,
            SubmittedAt = finalSubmission.SubmittedAt
        };
    }
}
