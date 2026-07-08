using backend.BLL.DTOs.Class;

namespace backend.BLL.Interfaces;

public interface IClassService
{
    Task<List<ClassDto>> GetMyClassesAsync(int userId);
    Task<ClassDto> GetClassByIdAsync(int classId, int userId);
    Task<List<ClassMemberDto>> GetMembersAsync(int classId);
    Task<IEnumerable<ClassDto>> GetClassesByCourseAsync(int courseId, int instructorId);
    Task<ClassDto> CreateClassAsync(CreateClassDto dto, int instructorId);
    Task<bool> AddMemberToClassAsync(int classId, AddClassMemberDto dto, int instructorId);
    Task<bool> RemoveMemberFromClassAsync(int classId, int userId, int instructorId);
}
