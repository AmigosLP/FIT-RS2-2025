using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using zaMene.Model.Entity;
using zaMene.Model.SearchObjects;
using zaMene.Model.ViewModels;
using zaMene.Services.Interface;

namespace zaMene.Services.Interfaces
{
    public interface IFavoriteService : ICRUDService<Favorite, FavoriteSearchObject, FavoriteDto, FavoriteUpdateDto>
    {
        IEnumerable<Favorite> Search(FavoriteSearchObject search);
    }
}
