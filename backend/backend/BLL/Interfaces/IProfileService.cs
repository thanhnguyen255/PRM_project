using backend.BLL.DTOs.User;

namespace backend.BLL.Interfaces;

public interface IProfileService
{
    Task<UserDto> GetProfileAsync(int userId);
    Task<UserDto> UpdateProfileAsync(int userId, UpdateProfileDto dto);
}
