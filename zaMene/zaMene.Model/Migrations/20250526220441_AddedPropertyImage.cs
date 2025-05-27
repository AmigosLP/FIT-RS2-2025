using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace zaMene.Model.Migrations
{
    /// <inheritdoc />
    public partial class AddedPropertyImage : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_PropertyImage_Properties_PropertyID",
                table: "PropertyImage");

            migrationBuilder.DropPrimaryKey(
                name: "PK_PropertyImage",
                table: "PropertyImage");

            migrationBuilder.RenameTable(
                name: "PropertyImage",
                newName: "PropertyImages");

            migrationBuilder.RenameIndex(
                name: "IX_PropertyImage_PropertyID",
                table: "PropertyImages",
                newName: "IX_PropertyImages_PropertyID");

            migrationBuilder.AddPrimaryKey(
                name: "PK_PropertyImages",
                table: "PropertyImages",
                column: "PropertyImageID");

            migrationBuilder.AddForeignKey(
                name: "FK_PropertyImages_Properties_PropertyID",
                table: "PropertyImages",
                column: "PropertyID",
                principalTable: "Properties",
                principalColumn: "PropertyID",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_PropertyImages_Properties_PropertyID",
                table: "PropertyImages");

            migrationBuilder.DropPrimaryKey(
                name: "PK_PropertyImages",
                table: "PropertyImages");

            migrationBuilder.RenameTable(
                name: "PropertyImages",
                newName: "PropertyImage");

            migrationBuilder.RenameIndex(
                name: "IX_PropertyImages_PropertyID",
                table: "PropertyImage",
                newName: "IX_PropertyImage_PropertyID");

            migrationBuilder.AddPrimaryKey(
                name: "PK_PropertyImage",
                table: "PropertyImage",
                column: "PropertyImageID");

            migrationBuilder.AddForeignKey(
                name: "FK_PropertyImage_Properties_PropertyID",
                table: "PropertyImage",
                column: "PropertyID",
                principalTable: "Properties",
                principalColumn: "PropertyID",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
