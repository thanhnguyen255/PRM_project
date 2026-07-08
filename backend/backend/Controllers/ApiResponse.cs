namespace backend.Controllers;

/// <summary>
/// Cấu trúc response chuẩn cho tất cả API endpoints.
/// </summary>
public class ApiResponse<T>
{
    public bool Success { get; set; }
    public T? Data { get; set; }
    public string? Message { get; set; }
}

/// <summary>
/// Static factory để tạo ApiResponse nhanh.
/// </summary>
public static class ApiResponse
{
    public static ApiResponse<T> Success<T>(T data, string? message = null)
        => new() { Success = true, Data = data, Message = message };

    public static ApiResponse<object?> Fail(string message)
        => new() { Success = false, Data = null, Message = message };
}
