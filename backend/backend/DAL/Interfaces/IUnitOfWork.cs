namespace backend.DAL.Interfaces;

public interface IUnitOfWork : IDisposable
{
    Task<int> SaveChangesAsync();
}
