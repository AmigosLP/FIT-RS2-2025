﻿using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace zaMene.Model.Migrations
{
    /// <inheritdoc />
    public partial class AddedNotificationTitle : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Title",
                table: "Notification",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Title",
                table: "Notification");
        }
    }
}
