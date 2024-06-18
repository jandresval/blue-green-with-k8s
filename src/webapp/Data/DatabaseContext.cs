namespace webapp.Data;

public class DatabaseContext
{
    public MySqlConnection Connection { get; }

    public DatabaseContext(AppSettings appSettings)
    {
        Connection = new MySqlConnection(appSettings.Database.ConnectionString);
        Connection.Open();
    }
}