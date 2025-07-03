using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace zaMene.Model.Migrations
{
    /// <inheritdoc />
    public partial class AddedUpdateAt : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAt",
                table: "Notification",
                type: "datetime2",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "UpdatedAt",
                table: "Notification");
        }
    }
}
