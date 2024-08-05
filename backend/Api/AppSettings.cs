namespace Api;

public class AppSettings
{
    public Logging Logging { get; set; } = null!;
    public Database Database { get; set; } = null!;
}

public class Logging
{
    public LogLevel LogLevel { get; set; } = null!;
}

public class LogLevel
{
    public string Default { get; set; } = null!;
    public string Microsoft_AspNetCore { get; set; } = null!;
}

public class Database
{
    public string ConnectionString { get; set; } = null!;
}