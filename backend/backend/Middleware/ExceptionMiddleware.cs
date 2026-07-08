using backend.Controllers;
using System.Text.Json;

namespace backend.Middleware;

public class ExceptionMiddleware(RequestDelegate next)
{
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await next(context);
        }
        catch (UnauthorizedAccessException ex)
        {
            await WriteResponse(context, 401, ex.Message);
        }
        catch (InvalidOperationException ex) when (ex.Message.Contains("đã được sử dụng"))
        {
            await WriteResponse(context, 409, ex.Message);
        }
        catch (KeyNotFoundException ex)
        {
            await WriteResponse(context, 404, ex.Message);
        }
        catch (ArgumentException ex)
        {
            await WriteResponse(context, 400, ex.Message);
        }
        catch (Exception ex)
        {
            await WriteResponse(context, 500, "Đã có lỗi xảy ra. Vui lòng thử lại sau.");
            Console.Error.WriteLine($"[Exception] {ex.GetType().Name}: {ex.Message}\n{ex.StackTrace}");
        }
    }

    private static async Task WriteResponse(HttpContext context, int statusCode, string message)
    {
        context.Response.StatusCode = statusCode;
        context.Response.ContentType = "application/json";
        var body = ApiResponse.Fail(message);
        await context.Response.WriteAsJsonAsync(body);
    }
}
