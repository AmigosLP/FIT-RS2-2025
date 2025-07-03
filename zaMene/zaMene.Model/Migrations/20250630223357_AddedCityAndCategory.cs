using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace zaMene.Model.Migrations
{
    /// <inheritdoc />
    public partial class AddedCityAndCategory : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "CategoryID",
                table: "Properties",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "CityID",
                table: "Properties",
                type: "int",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "Category",
                columns: table => new
                {
                    CategoryID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Category", x => x.CategoryID);
                });

            migrationBuilder.CreateTable(
                name: "City",
                columns: table => new
                {
                    CityID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_City", x => x.CityID);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Properties_CategoryID",
                table: "Properties",
                column: "CategoryID");

            migrationBuilder.CreateIndex(
                name: "IX_Properties_CityID",
                table: "Properties",
                column: "CityID");

            migrationBuilder.AddForeignKey(
                name: "FK_Properties_Category_CategoryID",
                table: "Properties",
                column: "CategoryID",
                principalTable: "Category",
                principalColumn: "CategoryID");

            migrationBuilder.AddForeignKey(
                name: "FK_Properties_City_CityID",
                table: "Properties",
                column: "CityID",
                principalTable: "City",
                principalColumn: "CityID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Properties_Category_CategoryID",
                table: "Properties");

            migrationBuilder.DropForeignKey(
                name: "FK_Properties_City_CityID",
                table: "Properties");

            migrationBuilder.DropTable(
                name: "Category");

            migrationBuilder.DropTable(
                name: "City");

            migrationBuilder.DropIndex(
                name: "IX_Properties_CategoryID",
                table: "Properties");

            migrationBuilder.DropIndex(
                name: "IX_Properties_CityID",
                table: "Properties");

            migrationBuilder.DropColumn(
                name: "CategoryID",
                table: "Properties");

            migrationBuilder.DropColumn(
                name: "CityID",
                table: "Properties");
        }
    }
}
