using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace zaMene.Model.Migrations
{
    /// <inheritdoc />
    public partial class AddedCountry : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "CountryID",
                table: "Properties",
                type: "int",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "Country",
                columns: table => new
                {
                    CountryID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Country", x => x.CountryID);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Properties_CountryID",
                table: "Properties",
                column: "CountryID");

            migrationBuilder.AddForeignKey(
                name: "FK_Properties_Country_CountryID",
                table: "Properties",
                column: "CountryID",
                principalTable: "Country",
                principalColumn: "CountryID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Properties_Country_CountryID",
                table: "Properties");

            migrationBuilder.DropTable(
                name: "Country");

            migrationBuilder.DropIndex(
                name: "IX_Properties_CountryID",
                table: "Properties");

            migrationBuilder.DropColumn(
                name: "CountryID",
                table: "Properties");
        }
    }
}
