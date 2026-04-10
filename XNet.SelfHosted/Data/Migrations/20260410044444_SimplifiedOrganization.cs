using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace XNet.SelfHosted.Migrations
{
    /// <inheritdoc />
    public partial class SimplifiedOrganization : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "TaxId",
                table: "Organizations");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "TaxId",
                table: "Organizations",
                type: "TEXT",
                nullable: true);
        }
    }
}
