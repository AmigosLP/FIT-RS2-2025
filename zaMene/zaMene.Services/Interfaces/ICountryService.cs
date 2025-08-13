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
    public interface ICountryService : ICRUDService<Country, CountrySearchObject, CountryDto, CountryUpdateDto>
    {
    }
}
