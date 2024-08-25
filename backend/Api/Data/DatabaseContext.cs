namespace Api.Data;

public class DatabaseContext
(
    AppSettings appSettings
)
{
    private readonly string _connectionString = appSettings.Database.ConnectionString;

    public MySqlConnection CreateConnection()
    {
        var connection = new MySqlConnection(_connectionString);
        connection.Open();
        return connection;
    }
}