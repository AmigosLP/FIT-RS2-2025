using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace zaMene.Model.Migrations
{
    /// <inheritdoc />
    public partial class AddedNotificationUserAndCascadeDelete : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Properties_Users_AgentID",
                table: "Properties");

            migrationBuilder.DropForeignKey(
                name: "FK_Reservations_Properties_PropertyID",
                table: "Reservations");

            migrationBuilder.DropForeignKey(
                name: "FK_Reservations_Users_UserID",
                table: "Reservations");

            migrationBuilder.DropForeignKey(
                name: "FK_Reviews_Users_UserID",
                table: "Reviews");

            migrationBuilder.DropTable(
                name: "IdentityUserLogin<int>");

            migrationBuilder.DropTable(
                name: "IdentityUserRole<int>");

            migrationBuilder.DropTable(
                name: "IdentityUserToken<int>");

            migrationBuilder.RenameColumn(
                name: "UserId",
                table: "Notification",
                newName: "UserID");

            migrationBuilder.CreateIndex(
                name: "IX_Notification_UserID",
                table: "Notification",
                column: "UserID");

            migrationBuilder.AddForeignKey(
                name: "FK_Notification_Users_UserID",
                table: "Notification",
                column: "UserID",
                principalTable: "Users",
                principalColumn: "UserID",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Properties_Users_AgentID",
                table: "Properties",
                column: "AgentID",
                principalTable: "Users",
                principalColumn: "UserID");

            migrationBuilder.AddForeignKey(
                name: "FK_Reservations_Properties_PropertyID",
                table: "Reservations",
                column: "PropertyID",
                principalTable: "Properties",
                principalColumn: "PropertyID",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Reservations_Users_UserID",
                table: "Reservations",
                column: "UserID",
                principalTable: "Users",
                principalColumn: "UserID",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Reviews_Users_UserID",
                table: "Reviews",
                column: "UserID",
                principalTable: "Users",
                principalColumn: "UserID",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Notification_Users_UserID",
                table: "Notification");

            migrationBuilder.DropForeignKey(
                name: "FK_Properties_Users_AgentID",
                table: "Properties");

            migrationBuilder.DropForeignKey(
                name: "FK_Reservations_Properties_PropertyID",
                table: "Reservations");

            migrationBuilder.DropForeignKey(
                name: "FK_Reservations_Users_UserID",
                table: "Reservations");

            migrationBuilder.DropForeignKey(
                name: "FK_Reviews_Users_UserID",
                table: "Reviews");

            migrationBuilder.DropIndex(
                name: "IX_Notification_UserID",
                table: "Notification");

            migrationBuilder.RenameColumn(
                name: "UserID",
                table: "Notification",
                newName: "UserId");

            migrationBuilder.CreateTable(
                name: "IdentityUserLogin<int>",
                columns: table => new
                {
                    LoginProvider = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    ProviderKey = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    ProviderDisplayName = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    UserId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_IdentityUserLogin<int>", x => new { x.LoginProvider, x.ProviderKey });
                });

            migrationBuilder.CreateTable(
                name: "IdentityUserRole<int>",
                columns: table => new
                {
                    UserId = table.Column<int>(type: "int", nullable: false),
                    RoleId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_IdentityUserRole<int>", x => new { x.UserId, x.RoleId });
                });

            migrationBuilder.CreateTable(
                name: "IdentityUserToken<int>",
                columns: table => new
                {
                    UserId = table.Column<int>(type: "int", nullable: false),
                    LoginProvider = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Value = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_IdentityUserToken<int>", x => new { x.UserId, x.LoginProvider, x.Name });
                });

            migrationBuilder.AddForeignKey(
                name: "FK_Properties_Users_AgentID",
                table: "Properties",
                column: "AgentID",
                principalTable: "Users",
                principalColumn: "UserID",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Reservations_Properties_PropertyID",
                table: "Reservations",
                column: "PropertyID",
                principalTable: "Properties",
                principalColumn: "PropertyID",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Reservations_Users_UserID",
                table: "Reservations",
                column: "UserID",
                principalTable: "Users",
                principalColumn: "UserID",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Reviews_Users_UserID",
                table: "Reviews",
                column: "UserID",
                principalTable: "Users",
                principalColumn: "UserID",
                onDelete: ReferentialAction.Restrict);
        }
    }
}
