using backend.BLL.DTOs.Notification;

namespace backend.BLL.Interfaces;

public interface INotificationService
{
    Task<NotificationListDto> GetListAsync(int userId, int page, int pageSize);
    Task<int> GetUnreadCountAsync(int userId);
    Task MarkReadAsync(int notificationId, int userId);
    Task MarkAllReadAsync(int userId);
}
