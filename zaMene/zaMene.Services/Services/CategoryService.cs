using MapsterMapper;
using zaMene.Model;
using zaMene.Model.Entity;
using zaMene.Model.SearchObjects;
using zaMene.Model.ViewModel;
using zaMene.Model.ViewModels;
using zaMene.Services.Interface;
using zaMene.Services.Interfaces;

namespace zaMene.Services.Service
{
    public class CategoryService : BaseCRUDService<Category, CategorySearchObject, Category, CategoryDto, CategoryUpdateDto>, ICategoryService
    {
        public CategoryService(AppDbContext context, IMapper mapper) : base(context, mapper) { }

        public override IQueryable<Category> AddFilter(CategorySearchObject search, IQueryable<Category> query)
        {
            if (!string.IsNullOrWhiteSpace(search.Name))
            {
                query = query.Where(c => c.Name.ToLower().Contains(search.Name.ToLower()));
            }

            return base.AddFilter(search, query);
        }

        public override void BeforeInsert(CategoryDto request, Category entity)
        {
            base.BeforeInsert(request, entity);
        }

        public override void BeforeUpdate(CategoryUpdateDto request, Category entity)
        {
            base.BeforeUpdate(request, entity);
        }
    }
}
