using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace backend.Migrations
{
    /// <inheritdoc />
    public partial class AddActivityIdToReviewSession : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "ActivityId",
                table: "ReviewSessions",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateIndex(
                name: "IX_ReviewSessions_ActivityId",
                table: "ReviewSessions",
                column: "ActivityId");

            migrationBuilder.AddForeignKey(
                name: "FK_ReviewSessions_Activities_ActivityId",
                table: "ReviewSessions",
                column: "ActivityId",
                principalTable: "Activities",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ReviewSessions_Activities_ActivityId",
                table: "ReviewSessions");

            migrationBuilder.DropIndex(
                name: "IX_ReviewSessions_ActivityId",
                table: "ReviewSessions");

            migrationBuilder.DropColumn(
                name: "ActivityId",
                table: "ReviewSessions");
        }
    }
}
