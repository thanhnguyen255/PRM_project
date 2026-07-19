namespace backend.BLL.Helpers;

/// <summary>
/// Đường dẫn lưu file người dùng upload (avatar, tài liệu, minh chứng...).
/// Thư mục được đặt NGOÀI thư mục project để 'dotnet watch' không theo dõi và
/// hot-reload mỗi khi có file mới — vốn gây crash 'HotReloadMSBuildWorkspace line 158'.
/// </summary>
public static class UploadPaths
{
    // Ở runtime, cwd là thư mục project (backend/backend). '..' đưa ra backend/ -> ngoài project.
    public static string Root =>
        Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), "..", "AppData", "uploads"));

    // Đường dẫn request để phục vụ file tĩnh (khớp với AvatarUrl/FileUrl "/uploads/...").
    public const string RequestPath = "/uploads";
}
