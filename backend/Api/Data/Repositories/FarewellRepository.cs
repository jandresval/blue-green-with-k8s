namespace Api.Data.Repositories;

public class FarewellRepository 
(
    DatabaseContext databaseContext
)
{
    private string _farewell = string.Empty;
    
    private const string GetFirstFarewellRecord = "SELECT farewell FROM farewells LIMIT 1;";

    public string GetFarewell()
    {
        if (_farewell != string.Empty) return _farewell;

        using var connection = databaseContext.CreateConnection();
        
        using var command = new MySqlCommand(GetFirstFarewellRecord, connection);

        using var reader = command.ExecuteReader();
        if (reader.Read())
        {
            _farewell = reader.GetString("farewell");
        }
        return _farewell;
    }
}