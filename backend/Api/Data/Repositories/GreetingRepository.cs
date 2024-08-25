namespace Api.Data.Repositories;

public class GreetingRepository
(
    DatabaseContext databaseContext
)
{
    private string _greeting = string.Empty;

    private const string GetFirstGreetingRecord = "SELECT greeting FROM greetings LIMIT 1;";

    public string GetGreeting()
    {
        if (_greeting != string.Empty) return _greeting;

        using var connection = databaseContext.CreateConnection();

        using var cmd = new MySqlCommand(GetFirstGreetingRecord, connection);

        using var reader = cmd.ExecuteReader();

        reader.Read();

        _greeting = reader.GetString(0);

        return _greeting;
    }
}