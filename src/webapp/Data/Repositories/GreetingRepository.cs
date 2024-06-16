namespace webapp.Data.Repositories;

public class GreetingRepository
(
    DatabaseContext databaseContext
)
{
    private MySqlConnection Connection { get; } = databaseContext.Connection;

    private string _greeting = string.Empty;

    private const string GetFirstGreetingRecord = "SELECT greeting FROM greetings LIMIT 1;";

    public string GetGreeting()
    {
        if (_greeting != string.Empty) return _greeting;

        using var cmd = new MySqlCommand(GetFirstGreetingRecord, Connection);

        using var reader = cmd.ExecuteReader();

        reader.Read();

        _greeting = reader.GetString(0);

        return _greeting;
    }
}