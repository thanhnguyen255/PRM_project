# 🔐 Hướng Dẫn Từng Bước — Xây Dựng Authentication Từ Đầu

> **Dự án**: Flipped Classroom App  
> **Tech**: ASP.NET Core 8 (3-Layer) · Flutter (MVVM + Provider)  
> **Server**: `DESKTOP-KN8VR1N` · SQL Server (sa/123)  
> **Tổng thời gian**: ~3–4 giờ nếu làm theo từng bước

---

# PHẦN A — BACKEND (ASP.NET Core)

---

## Bước 1: Tạo Solution + Cài NuGet

### 1.1 Tạo project

```bash
# Tạo folder
mkdir backend
cd backend

# Tạo Web API project
dotnet new webapi -n backend
dotnet new sln -n PRM393
dotnet sln add backend/backend.csproj
```

### 1.2 Cài NuGet packages

```bash
cd backend
dotnet add package Microsoft.EntityFrameworkCore.SqlServer --version 8.0.0
dotnet add package Microsoft.EntityFrameworkCore.Design --version 8.0.0
dotnet add package Microsoft.EntityFrameworkCore.Tools --version 8.0.0
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer --version 8.0.0
dotnet add package BCrypt.Net-Next --version 4.0.3
dotnet add package Swashbuckle.AspNetCore --version 6.6.2
```

### 1.3 Kiểm tra `backend.csproj` có đúng:

```xml
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="BCrypt.Net-Next" Version="4.0.3" />
    <PackageReference Include="Microsoft.AspNetCore.Authentication.JwtBearer" Version="8.0.0" />
    <PackageReference Include="Microsoft.EntityFrameworkCore.SqlServer" Version="8.0.0" />
    <PackageReference Include="Microsoft.EntityFrameworkCore.Design" Version="8.0.0" />
    <PackageReference Include="Microsoft.EntityFrameworkCore.Tools" Version="8.0.0" />
    <PackageReference Include="Swashbuckle.AspNetCore" Version="6.6.2" />
  </ItemGroup>
</Project>
```

> ✅ **Checkpoint**: `dotnet build` không lỗi.

---

## Bước 2: Cấu hình `appsettings.json`

Mở file `appsettings.json`, **xóa hết** nội dung cũ, thay bằng:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=DESKTOP-KN8VR1N;Database=FlippedClassroomDB;User Id=sa;Password=123;TrustServerCertificate=True;"
  },
  "Jwt": {
    "Key": "FlippedClassroomSecretKey2026_MustBe32CharsMinimum!",
    "Issuer": "FlippedClassroomAPI",
    "Audience": "FlippedClassroomApp",
    "ExpiresInMinutes": "60"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Giải thích**:
- `ConnectionStrings` → kết nối SQL Server trên máy `DESKTOP-KN8VR1N`, user `sa`, pass `123`
- `Jwt:Key` → secret key dùng để sign JWT token (≥ 32 ký tự)
- `Jwt:ExpiresInMinutes` → token hết hạn sau 60 phút

---

## Bước 3: Tạo thư mục cấu trúc 3-Layer

```
backend/
├── DAL/
│   ├── Models/
│   ├── Enums/
│   ├── Interfaces/
│   └── Repositories/
├── BLL/
│   ├── DTOs/Auth/
│   ├── Helpers/
│   ├── Interfaces/
│   └── Services/
├── Controllers/
└── Middleware/
```

Tạo các folder (trong Visual Studio: chuột phải → Add → New Folder):

```
DAL/Models
DAL/Enums
DAL/Interfaces
DAL/Repositories
BLL/DTOs/Auth
BLL/Helpers
BLL/Interfaces
BLL/Services
Middleware
```

---

## Bước 4: Tạo DAL — Entity + Enum + DbContext

### 4.1 Tạo file `DAL/Enums/UserRole.cs`

```csharp
namespace backend.DAL.Enums;

public enum UserRole
{
    Learner = 0,
    Instructor = 1
}
```

**Tại sao**: Enum giúp phân biệt role người dùng, dùng int trong DB (0, 1).

---

### 4.2 Tạo file `DAL/Models/User.cs`

```csharp
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using backend.DAL.Enums;

namespace backend.DAL.Models;

[Table("Users")]
public class User
{
    [Key]
    public int Id { get; set; }

    [Required]
    [MaxLength(255)]
    public string Email { get; set; } = string.Empty;

    [Required]
    [MaxLength(500)]
    public string PasswordHash { get; set; } = string.Empty;

    [Required]
    [MaxLength(100)]
    public string FullName { get; set; } = string.Empty;

    [MaxLength(500)]
    public string? AvatarUrl { get; set; }

    [Required]
    public UserRole Role { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
```

**Giải thích từng field**:
| Field | Mục đích |
|-------|---------|
| `Id` | Primary key, tự tăng |
| `Email` | Duy nhất, dùng đăng nhập |
| `PasswordHash` | BCrypt hash, KHÔNG lưu mật khẩu gốc |
| `FullName` | Tên hiển thị |
| `AvatarUrl` | Link ảnh đại diện (nullable) |
| `Role` | 0=Learner, 1=Instructor |
| `CreatedAt` | Ngày tạo tài khoản |

---

### 4.3 Tạo file `DAL/AppDbContext.cs`

```csharp
using backend.DAL.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.DAL;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<User> Users { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Email phải unique
        modelBuilder.Entity<User>(entity =>
        {
            entity.HasIndex(u => u.Email).IsUnique();
            entity.Property(u => u.Email).HasMaxLength(255).IsRequired();
            entity.Property(u => u.PasswordHash).HasMaxLength(500).IsRequired();
            entity.Property(u => u.FullName).HasMaxLength(100).IsRequired();
            entity.Property(u => u.AvatarUrl).HasMaxLength(500);
        });
    }
}
```

**Giải thích**:
- `DbSet<User>` → EF Core sẽ tạo bảng `Users` trong DB
- `HasIndex(u => u.Email).IsUnique()` → không cho 2 user cùng email
- Dùng **primary constructor** (C# 12): `AppDbContext(DbContextOptions<AppDbContext> options)`

---

## Bước 5: Migration — Tạo bảng trong SQL Server

### 5.1 Trước tiên, cấu hình DbContext trong `Program.cs` (tạm thời)

Mở `Program.cs`, thêm vào đầu file (sau `var builder = ...`):

```csharp
using backend.DAL;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Database
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.MapControllers();
app.Run();
```

### 5.2 Chạy Migration

```bash
cd backend

# Tạo migration
dotnet ef migrations add InitialCreate

# Áp dụng vào database (tạo DB + bảng Users)
dotnet ef database update
```

### 5.3 Kiểm tra

Mở **SQL Server Management Studio (SSMS)**:
1. Connect tới `DESKTOP-KN8VR1N`
2. Tìm database `FlippedClassroomDB`
3. Mở `Tables` → thấy bảng `Users` với đúng các cột

> ✅ **Checkpoint**: Bảng `Users` tồn tại trong SQL Server, có index unique trên `Email`.

---

## Bước 6: Tạo BLL — Helpers (JWT + Password)

### 6.1 Tạo file `BLL/Helpers/PasswordHelper.cs`

```csharp
namespace backend.BLL.Helpers;

public static class PasswordHelper
{
    public static string Hash(string password)
    {
        return BCrypt.Net.BCrypt.HashPassword(password);
    }

    public static bool Verify(string password, string hash)
    {
        return BCrypt.Net.BCrypt.Verify(password, hash);
    }
}
```

**Giải thích**:
- `Hash()` → biến "123456" thành "$2a$10$xQk..." (không thể đảo ngược)
- `Verify()` → so sánh password gốc với hash → true/false
- **Tại sao BCrypt**: Tự thêm salt, chống rainbow table attack

---

### 6.2 Tạo file `BLL/Helpers/JwtHelper.cs`

```csharp
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using backend.DAL.Models;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;

namespace backend.BLL.Helpers;

public class JwtHelper
{
    private readonly IConfiguration _config;

    public JwtHelper(IConfiguration config)
    {
        _config = config;
    }

    public string GenerateToken(User user)
    {
        // 1. Tạo signing key từ secret
        var key = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(_config["Jwt:Key"]!));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        // 2. Đặt claims (thông tin trong token)
        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Email, user.Email),
            new Claim(ClaimTypes.Name, user.FullName),
            new Claim(ClaimTypes.Role, user.Role.ToString())
        };

        // 3. Đọc thời gian hết hạn
        var expires = int.TryParse(_config["Jwt:ExpiresInMinutes"], out int minutes)
            ? minutes : 60;

        // 4. Tạo JWT token
        var token = new JwtSecurityToken(
            issuer: _config["Jwt:Issuer"],
            audience: _config["Jwt:Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(expires),
            signingCredentials: creds
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
```

**Giải thích từng bước**:
1. `SymmetricSecurityKey` → dùng cùng 1 key để sign và verify (đối xứng)
2. `Claims` → thông tin nhúng trong token: userId, email, role
3. Token hết hạn sau 60 phút (đọc từ config)
4. Trả về chuỗi `eyJhbGciOi...` — Flutter lưu chuỗi này

---

## Bước 7: Tạo BLL — DTOs

### 7.1 Tạo file `BLL/DTOs/Auth/LoginRequestDto.cs`

```csharp
using System.ComponentModel.DataAnnotations;

namespace backend.BLL.DTOs.Auth;

public class LoginRequestDto
{
    [Required(ErrorMessage = "Vui lòng nhập email.")]
    [EmailAddress(ErrorMessage = "Vui lòng nhập email hợp lệ.")]
    public string Email { get; set; } = string.Empty;

    [Required(ErrorMessage = "Vui lòng nhập mật khẩu.")]
    public string Password { get; set; } = string.Empty;
}
```

### 7.2 Tạo file `BLL/DTOs/Auth/RegisterRequestDto.cs`

```csharp
using System.ComponentModel.DataAnnotations;

namespace backend.BLL.DTOs.Auth;

public class RegisterRequestDto
{
    [Required(ErrorMessage = "Vui lòng nhập họ và tên.")]
    [MaxLength(100)]
    public string FullName { get; set; } = string.Empty;

    [Required(ErrorMessage = "Vui lòng nhập email hợp lệ.")]
    [EmailAddress(ErrorMessage = "Vui lòng nhập email hợp lệ.")]
    public string Email { get; set; } = string.Empty;

    [Required(ErrorMessage = "Vui lòng nhập mật khẩu.")]
    [MinLength(6, ErrorMessage = "Mật khẩu phải có ít nhất 6 ký tự.")]
    public string Password { get; set; } = string.Empty;
}
```

### 7.3 Tạo file `BLL/DTOs/Auth/LoginResponseDto.cs`

```csharp
namespace backend.BLL.DTOs.Auth;

public class LoginResponseDto
{
    public string Token { get; set; } = string.Empty;
    public int UserId { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty;   // "Learner" hoặc "Instructor"
    public string? AvatarUrl { get; set; }
}
```

### 7.4 Tạo file `BLL/DTOs/Auth/ForgotPasswordDto.cs`

```csharp
using System.ComponentModel.DataAnnotations;

namespace backend.BLL.DTOs.Auth;

public class ForgotPasswordDto
{
    [Required(ErrorMessage = "Vui lòng nhập email.")]
    [EmailAddress(ErrorMessage = "Vui lòng nhập email hợp lệ.")]
    public string Email { get; set; } = string.Empty;
}
```

**Tại sao cần DTO**: Tách biệt data truyền qua API vs Entity trong DB. Không bao giờ trả `PasswordHash` cho client.

---

## Bước 8: Tạo BLL — Interface + Service

### 8.1 Tạo file `BLL/Interfaces/IAuthService.cs`

```csharp
using backend.BLL.DTOs.Auth;

namespace backend.BLL.Interfaces;

public interface IAuthService
{
    Task<LoginResponseDto> LoginAsync(LoginRequestDto dto);
    Task<LoginResponseDto> RegisterAsync(RegisterRequestDto dto);
    Task ForgotPasswordAsync(string email);
}
```

### 8.2 Tạo file `BLL/Services/AuthService.cs`

```csharp
using backend.BLL.DTOs.Auth;
using backend.BLL.Helpers;
using backend.BLL.Interfaces;
using backend.DAL;
using backend.DAL.Enums;
using backend.DAL.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.BLL.Services;

public class AuthService : IAuthService
{
    private readonly AppDbContext _db;
    private readonly JwtHelper _jwt;

    public AuthService(AppDbContext db, JwtHelper jwt)
    {
        _db = db;
        _jwt = jwt;
    }

    // ── LOGIN ────────────────────────────────────────────────────────────────
    public async Task<LoginResponseDto> LoginAsync(LoginRequestDto dto)
    {
        // Bước 1: Tìm user theo email (normalize lowercase)
        var user = await _db.Users
            .FirstOrDefaultAsync(u => u.Email == dto.Email.ToLower().Trim());

        // Bước 2: Không tìm thấy hoặc sai password → 401
        if (user == null || !PasswordHelper.Verify(dto.Password, user.PasswordHash))
            throw new UnauthorizedAccessException("Email hoặc mật khẩu không đúng.");

        // Bước 3: Tạo JWT token và trả về
        return BuildResponse(user);
    }

    // ── REGISTER ─────────────────────────────────────────────────────────────
    public async Task<LoginResponseDto> RegisterAsync(RegisterRequestDto dto)
    {
        // Bước 1: Kiểm tra email đã tồn tại chưa
        if (await _db.Users.AnyAsync(u => u.Email == dto.Email.ToLower().Trim()))
            throw new InvalidOperationException("Email này đã được sử dụng.");

        // Bước 2: Tạo user mới
        var user = new User
        {
            Email = dto.Email.ToLower().Trim(),
            PasswordHash = PasswordHelper.Hash(dto.Password),
            FullName = dto.FullName.Trim(),
            Role = UserRole.Learner,      // Mặc định là Learner
            CreatedAt = DateTime.UtcNow
        };

        // Bước 3: Lưu vào DB
        _db.Users.Add(user);
        await _db.SaveChangesAsync();

        // Bước 4: Tạo token và trả về (tự động login sau register)
        return BuildResponse(user);
    }

    // ── FORGOT PASSWORD ──────────────────────────────────────────────────────
    public async Task ForgotPasswordAsync(string email)
    {
        var exists = await _db.Users.AnyAsync(u => u.Email == email.ToLower().Trim());
        if (!exists)
            throw new KeyNotFoundException("Email không tồn tại trong hệ thống.");

        // v1: Chỉ log, không gửi email thật
        Console.WriteLine($"[ForgotPassword] User {email} requested reset at {DateTime.UtcNow:u}");
    }

    // ── HELPER ───────────────────────────────────────────────────────────────
    private LoginResponseDto BuildResponse(User user)
    {
        return new LoginResponseDto
        {
            Token = _jwt.GenerateToken(user),
            UserId = user.Id,
            FullName = user.FullName,
            Role = user.Role.ToString(),
            AvatarUrl = user.AvatarUrl
        };
    }
}
```

**Luồng chi tiết**:
```
Login: email → tìm DB → verify BCrypt → tạo JWT → trả token
Register: email → check trùng → hash password → lưu DB → tạo JWT → trả token
ForgotPassword: email → check tồn tại → log (v1 không gửi email thật)
```

---

## Bước 9: Tạo API Layer — Response Wrapper + Middleware

### 9.1 Tạo file `Controllers/ApiResponse.cs`

```csharp
namespace backend.Controllers;

/// <summary>Response wrapper chuẩn cho mọi API.</summary>
public class ApiResponse<T>
{
    public bool Success { get; set; }
    public T? Data { get; set; }
    public string? Message { get; set; }
}

public static class ApiResponse
{
    public static ApiResponse<T> Success<T>(T data, string? message = null)
        => new() { Success = true, Data = data, Message = message };

    public static ApiResponse<object?> Fail(string message)
        => new() { Success = false, Data = null, Message = message };
}
```

**Mọi API đều trả format này**:
```json
{ "success": true/false, "data": {...}, "message": "..." }
```

### 9.2 Tạo file `Controllers/BaseController.cs`

```csharp
using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
public abstract class BaseController : ControllerBase
{
    /// <summary>Lấy userId từ JWT token.</summary>
    protected int GetCurrentUserId()
    {
        var claim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (claim == null)
            throw new UnauthorizedAccessException("Token không hợp lệ.");
        return int.Parse(claim);
    }

    /// <summary>Lấy role từ JWT token.</summary>
    protected string GetCurrentUserRole()
    {
        return User.FindFirstValue(ClaimTypes.Role) ?? string.Empty;
    }
}
```

**Tại sao cần BaseController**: Mọi controller sau này kế thừa, dùng chung `GetCurrentUserId()` để biết ai đang gọi API.

### 9.3 Tạo file `Middleware/ExceptionMiddleware.cs`

```csharp
using backend.Controllers;

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
```

**Giải thích**: Thay vì try-catch trong mỗi controller, middleware bắt TẤT CẢ exception → trả JSON chuẩn:
- `UnauthorizedAccessException` → **401** 
- `InvalidOperationException("đã được sử dụng")` → **409** 
- `KeyNotFoundException` → **404**
- Lỗi khác → **500**

---

## Bước 10: Tạo AuthController

### 10.1 Tạo file `Controllers/AuthController.cs`

```csharp
using backend.BLL.DTOs.Auth;
using backend.BLL.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[Route("api/auth")]
public class AuthController : BaseController
{
    private readonly IAuthService _auth;

    public AuthController(IAuthService auth)
    {
        _auth = auth;
    }

    /// <summary>POST /api/auth/login</summary>
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequestDto dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(ApiResponse.Fail("Dữ liệu không hợp lệ."));

        var result = await _auth.LoginAsync(dto);
        return Ok(ApiResponse.Success(result));
    }

    /// <summary>POST /api/auth/register</summary>
    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterRequestDto dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(ApiResponse.Fail("Dữ liệu không hợp lệ."));

        var result = await _auth.RegisterAsync(dto);
        return StatusCode(201, ApiResponse.Success(result));
    }

    /// <summary>POST /api/auth/forgot-password</summary>
    [HttpPost("forgot-password")]
    public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordDto dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(ApiResponse.Fail("Dữ liệu không hợp lệ."));

        await _auth.ForgotPasswordAsync(dto.Email);
        return Ok(ApiResponse.Success<object?>(null, "Nếu email tồn tại, link reset đã được gửi."));
    }
}
```

---

## Bước 11: Hoàn thiện `Program.cs`

**Xóa hết** nội dung `Program.cs`, thay bằng:

```csharp
using System.Text;
using backend.BLL.Helpers;
using backend.BLL.Interfaces;
using backend.BLL.Services;
using backend.DAL;
using backend.Middleware;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// ── 1. Database ─────────────────────────────────────────────────────────
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// ── 2. JWT Authentication ───────────────────────────────────────────────
var jwtKey = builder.Configuration["Jwt:Key"]!;
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
            ClockSkew = TimeSpan.Zero   // Token hết hạn chính xác, không đợi thêm
        };
    });

builder.Services.AddAuthorization();

// ── 3. CORS (cho Flutter app gọi API) ───────────────────────────────────
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
        policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader());
});

// ── 4. Dependency Injection ─────────────────────────────────────────────
builder.Services.AddScoped<JwtHelper>();
builder.Services.AddScoped<IAuthService, AuthService>();

// ── 5. Controllers + Swagger ────────────────────────────────────────────
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "Flipped Classroom API", Version = "v1" });

    // Cho phép test JWT trong Swagger UI
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Nhập: Bearer {token}"
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" }
            },
            Array.Empty<string>()
        }
    });
});

var app = builder.Build();

// ── 6. Middleware Pipeline ──────────────────────────────────────────────
app.UseMiddleware<ExceptionMiddleware>();   // Bắt lỗi toàn cục

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowAll");
app.UseAuthentication();   // PHẢI trước UseAuthorization
app.UseAuthorization();
app.MapControllers();

app.Run();
```

---

## Bước 12: Chạy + Test Backend

### 12.1 Chạy

```bash
cd backend
dotnet run
```

Truy cập: `http://localhost:5111/swagger`

### 12.2 Test bằng Swagger / Postman

**Test 1 — Register**:
```
POST /api/auth/register
Body: { "fullName": "Nguyen Van A", "email": "test@test.com", "password": "123456" }
→ Expect: 201, có token
```

**Test 2 — Login**:
```
POST /api/auth/login
Body: { "email": "test@test.com", "password": "123456" }
→ Expect: 200, có token + userId + role="Learner"
```

**Test 3 — Login sai pass**:
```
POST /api/auth/login
Body: { "email": "test@test.com", "password": "wrong" }
→ Expect: 401, "Email hoặc mật khẩu không đúng."
```

**Test 4 — Register email trùng**:
```
POST /api/auth/register
Body: { "fullName": "B", "email": "test@test.com", "password": "123456" }
→ Expect: 409, "Email này đã được sử dụng."
```

> ✅ **Checkpoint**: 4 test case pass → Backend Auth hoàn thành!

---

# PHẦN B — FRONTEND (Flutter)

---

## Bước 13: Setup Flutter Project + Packages

### 13.1 Tạo project (nếu chưa có)

```bash
flutter create frontend
cd frontend
```

### 13.2 Cài packages

```bash
flutter pub add provider dio shared_preferences go_router
```

### 13.3 Kiểm tra `pubspec.yaml` có:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.5+1
  dio: ^5.9.2
  shared_preferences: ^2.5.5
```

---

## Bước 14: Tạo Config Files

### 14.1 Tạo file `lib/config/api_config.dart`

```dart
class ApiConfig {
  ApiConfig._();

  // Base URL — đổi IP khi chạy trên device thật
  static const String baseUrl = 'http://DESKTOP-KN8VR1N:5111/api';

  // Auth endpoints
  static const String login    = '/auth/login';
  static const String register = '/auth/register';
}
```

### 14.2 Tạo file `lib/config/app_colors.dart`

```dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary       = Color(0xFF4F46E5);
  static const Color primaryLight  = Color(0xFFEEF2FF);
  static const Color secondary     = Color(0xFF06B6D4);

  static const Color success       = Color(0xFF10B981);
  static const Color error         = Color(0xFFEF4444);

  static const Color textPrimary   = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textHint      = Color(0xFF94A3B8);

  static const Color background    = Color(0xFFF8FAFC);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color border        = Color(0xFFE2E8F0);
}
```

---

## Bước 15: Tạo Model

### 15.1 Tạo file `lib/models/auth_response.dart`

```dart
class AuthResponse {
  final String token;
  final int userId;
  final String fullName;
  final String role;
  final String? avatarUrl;

  const AuthResponse({
    required this.token,
    required this.userId,
    required this.fullName,
    required this.role,
    this.avatarUrl,
  });

  /// Parse JSON từ API response (trường "data")
  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    token:     json['token'] as String,
    userId:    json['userId'] as int,
    fullName:  json['fullName'] as String,
    role:      json['role'] as String,
    avatarUrl: json['avatarUrl'] as String?,
  );
}
```

---

## Bước 16: Tạo ApiService (Dio + JWT Interceptor)

### 16.1 Tạo file `lib/services/api_service.dart`

```dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  // Singleton pattern — chỉ 1 instance duy nhất
  ApiService._();
  static final ApiService instance = ApiService._();

  late final Dio _dio;
  bool _initialized = false;

  void init() {
    if (_initialized) return;
    _initialized = true;

    // Bước 1: Tạo Dio với base URL + timeout
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    // Bước 2: Interceptor tự động đính JWT token vào mỗi request
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        // Token hết hạn → xóa local data
        if (e.response?.statusCode == 401) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
        }
        handler.next(e);
      },
    ));
  }

  Dio get dio {
    if (!_initialized) init();
    return _dio;
  }

  // ── Helper: đọc error message từ server ─────────────────────────────
  String errorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) return data['message'] as String;
    return 'Không thể kết nối. Kiểm tra lại mạng.';
  }
}
```

---

## Bước 17: Tạo AuthService

### 17.1 Tạo file `lib/services/auth_service.dart`

```dart
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/auth_response.dart';
import 'api_service.dart';

class AuthService {
  final _api = ApiService.instance;

  // ── LOGIN ──────────────────────────────────────────────────────────────
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final res = await _api.dio.post(ApiConfig.login, data: {
      'email': email.trim(),
      'password': password,
    });
    final auth = AuthResponse.fromJson(res.data['data']);
    await _saveSession(auth);
    return auth;
  }

  // ── REGISTER ───────────────────────────────────────────────────────────
  Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final res = await _api.dio.post(ApiConfig.register, data: {
      'fullName': fullName.trim(),
      'email': email.trim(),
      'password': password,
    });
    final auth = AuthResponse.fromJson(res.data['data']);
    await _saveSession(auth);
    return auth;
  }

  // ── LOGOUT ─────────────────────────────────────────────────────────────
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ── CHECK SESSION ──────────────────────────────────────────────────────
  Future<({String? token, String? role})> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      token: prefs.getString('token'),
      role:  prefs.getString('role'),
    );
  }

  // ── LƯU SESSION ───────────────────────────────────────────────────────
  Future<void> _saveSession(AuthResponse auth) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token',    auth.token);
    await prefs.setInt('userId',      auth.userId);
    await prefs.setString('fullName', auth.fullName);
    await prefs.setString('role',     auth.role);
    if (auth.avatarUrl != null) {
      await prefs.setString('avatarUrl', auth.avatarUrl!);
    }
  }
}
```

---

## Bước 18: Tạo AuthViewModel

### 18.1 Tạo file `lib/viewmodels/auth_viewmodel.dart`

```dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final _auth = AuthService();

  bool _isLoading = false;
  String? _error;

  bool    get isLoading => _isLoading;
  String? get error     => _error;

  // ── LOGIN ──────────────────────────────────────────────────────────────
  /// Trả về role ("Learner" / "Instructor") nếu thành công, null nếu thất bại
  Future<String?> login(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      final result = await _auth.login(email: email, password: password);
      _setLoading(false);
      return result.role;
    } on DioException catch (e) {
      _error = ApiService.instance.errorMessage(e);
      _setLoading(false);
      return null;
    }
  }

  // ── REGISTER ───────────────────────────────────────────────────────────
  Future<String?> register(String fullName, String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      final result = await _auth.register(
        fullName: fullName, email: email, password: password,
      );
      _setLoading(false);
      return result.role;
    } on DioException catch (e) {
      _error = ApiService.instance.errorMessage(e);
      _setLoading(false);
      return null;
    }
  }

  // ── LOGOUT ─────────────────────────────────────────────────────────────
  Future<void> logout() => _auth.logout();

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
```

---

## Bước 19: Tạo 4 Màn Hình Auth

### 19.1 Tạo file `lib/screens/auth/splash_screen.dart`

```dart
import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Delay 2 giây để hiển thị logo
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Kiểm tra token đã lưu
    final session = await AuthService().getSession();
    if (!mounted) return;

    if (session.token == null) {
      Navigator.pushReplacementNamed(context, '/login');
    } else if (session.role == 'Instructor') {
      Navigator.pushReplacementNamed(context, '/instructor/dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_rounded, size: 80, color: Colors.white),
            SizedBox(height: 24),
            Text('Flipped Classroom',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 8),
            Text('Học tập hiệu quả hơn',
              style: TextStyle(fontSize: 15, color: Colors.white70)),
            SizedBox(height: 48),
            SizedBox(width: 160, child: LinearProgressIndicator(
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            )),
          ],
        ),
      ),
    ),
  );
}
```

---

### 19.2 Tạo file `lib/screens/auth/login_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure    = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final vm   = context.read<AuthViewModel>();
    final role = await vm.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;

    if (role != null) {
      // Login thành công → route theo role
      if (role == 'Instructor') {
        Navigator.pushReplacementNamed(context, '/instructor/dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else if (vm.error != null) {
      // Hiện lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.error!), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                const Text('Xin chào 👋',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text('Đăng nhập để tiếp tục',
                  style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                const SizedBox(height: 40),

                // Email field
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'email@example.com',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email';
                    if (!v.contains('@')) return 'Email không hợp lệ';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    hintText: '••••••••',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) =>
                    (v == null || v.isEmpty) ? 'Vui lòng nhập mật khẩu' : null,
                ),
                const SizedBox(height: 12),

                // Quên mật khẩu
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                    child: const Text('Quên mật khẩu?'),
                  ),
                ),
                const SizedBox(height: 8),

                // Nút Đăng nhập
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: vm.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: vm.isLoading
                      ? const SizedBox(width: 24, height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('ĐĂNG NHẬP', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 32),

                // Link đăng ký
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Chưa có tài khoản?'),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      child: const Text('Đăng ký ngay',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

### 19.3 Tạo file `lib/screens/auth/register_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final vm   = context.read<AuthViewModel>();
    final role = await vm.register(
      _nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (role != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (vm.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.error!), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Tạo tài khoản')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Họ và tên *', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ tên' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email *', border: OutlineInputBorder()),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email';
                if (!v.contains('@')) return 'Email không hợp lệ';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passCtrl, obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu *', border: OutlineInputBorder()),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
                if (v.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmCtrl, obscureText: true,
              decoration: const InputDecoration(labelText: 'Xác nhận mật khẩu *', border: OutlineInputBorder()),
              validator: (v) {
                if (v != _passCtrl.text) return 'Mật khẩu không khớp';
                return null;
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: vm.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: vm.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('TẠO TÀI KHOẢN', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('Đã có tài khoản?'),
              TextButton(onPressed: () => Navigator.pop(context),
                child: const Text('Đăng nhập')),
            ]),
          ]),
        ),
      ),
    );
  }
}
```

---

### 19.4 Tạo file `lib/screens/auth/forgot_password_screen.dart`

```dart
import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Quên mật khẩu')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const Text('Nhập email để nhận hướng dẫn đặt lại mật khẩu.',
            style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          TextFormField(
            controller: emailCtrl,
            decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã gửi hướng dẫn đến email của bạn.')));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('GỬI'),
            ),
          ),
        ]),
      ),
    );
  }
}
```

---

## Bước 20: Tạo `main.dart` (Entry Point + Routes)

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ApiService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: MaterialApp(
        title: 'Flipped Classroom',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF4F46E5),
          useMaterial3: true,
        ),
        initialRoute: '/splash',
        routes: {
          '/splash':          (_) => const SplashScreen(),
          '/login':           (_) => const LoginScreen(),
          '/register':        (_) => const RegisterScreen(),
          '/forgot-password': (_) => const ForgotPasswordScreen(),
          // TODO: thêm routes cho Home, Instructor Dashboard
          '/home':                  (_) => const Scaffold(body: Center(child: Text('Home — Learner'))),
          '/instructor/dashboard':  (_) => const Scaffold(body: Center(child: Text('Dashboard — Instructor'))),
        },
      ),
    );
  }
}
```

---

## Bước 21: Chạy + Test Flutter

```bash
cd frontend
flutter run -d windows   # hoặc -d chrome, -d emulator
```

### Test thủ công:

| # | Hành động | Kết quả mong đợi |
|---|----------|------------------|
| 1 | Mở app lần đầu | Splash 2s → Login |
| 2 | Login `learner@test.com / 123456` | Chuyển tới "Home — Learner" |
| 3 | Tắt app → mở lại | Splash → tự vào Home (auto-login) |
| 4 | Login `instructor@test.com / 123456` | Chuyển tới "Dashboard — Instructor" |
| 5 | Nhập sai password | SnackBar đỏ "Email hoặc mật khẩu không đúng." |
| 6 | Register email mới | Tự động vào Home |
| 7 | Register email đã có | SnackBar "Email này đã được sử dụng." |
| 8 | Loading khi bấm nút | Spinner hiện, nút bị disable |

> ✅ **DONE!** Authentication hoàn thành cả Backend lẫn Frontend!

---

## 📝 Tóm Tắt Thứ Tự Tạo File

```
 1. appsettings.json          ← config DB + JWT
 2. DAL/Enums/UserRole.cs     ← enum Learner/Instructor
 3. DAL/Models/User.cs        ← entity User
 4. DAL/AppDbContext.cs        ← DbContext + unique email
 5. Migration                  ← dotnet ef migrations add + update
 6. BLL/Helpers/PasswordHelper ← BCrypt hash/verify
 7. BLL/Helpers/JwtHelper      ← tạo JWT token
 8. BLL/DTOs/Auth/4 files      ← request/response DTOs
 9. BLL/Interfaces/IAuthService← interface
10. BLL/Services/AuthService   ← business logic
11. Controllers/ApiResponse    ← response wrapper
12. Controllers/BaseController ← helper GetCurrentUserId
13. Middleware/ExceptionMiddleware ← bắt lỗi toàn cục
14. Controllers/AuthController ← 3 endpoints
15. Program.cs                 ← DI + JWT + Swagger + CORS
     ─── TEST BACKEND ───
16. config/api_config.dart     ← base URL + endpoints
17. config/app_colors.dart     ← design tokens
18. models/auth_response.dart  ← parse JSON
19. services/api_service.dart  ← Dio + JWT interceptor
20. services/auth_service.dart ← gọi API auth
21. viewmodels/auth_viewmodel  ← state management
22. screens/auth/splash        ← auto-login check
23. screens/auth/login         ← form đăng nhập
24. screens/auth/register      ← form đăng ký
25. screens/auth/forgot_pass   ← quên mật khẩu
26. main.dart                  ← entry + routes + providers
     ─── TEST FLUTTER ───
```
