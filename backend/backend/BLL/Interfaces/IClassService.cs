using backend.BLL.DTOs.Class;

namespace backend.BLL.Interfaces;

public interface IClassService
{
    Task<List<ClassDto>> GetMyClassesAsync(int userId);
    Task<ClassDto> GetClassByIdAsync(int classId, int userId);
    Task<List<ClassMemberDto>> GetMembersAsync(int classId);
}
