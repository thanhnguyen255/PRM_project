namespace backend.DAL.Interfaces;

public interface IGenericRepository<T> where T : class
{
    IQueryable<T> GetQueryable();
    Task<IEnumerable<T>> GetAllAsync();
    Task<T?> GetByIdAsync(int id);
    Task AddAsync(T entity);
    void Update(T entity);
    void Delete(T entity);
}
