const string myAllowSpecificOrigins = "_myAllowSpecificOrigins";

var environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT");

var settingsFile = environment == "Production" ? "appsettings.json" : "appsettings.Development.json";

var config = new ConfigurationBuilder()
             .SetBasePath(Directory.GetCurrentDirectory())
             .AddJsonFile(settingsFile, optional: false, reloadOnChange: true)
             .AddEnvironmentVariables()
             .Build();

var appSettings = config.Get<AppSettings>();

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddCors(options =>
    {
        options.AddPolicy(name: myAllowSpecificOrigins,
            policy =>
            {
                policy.AllowAnyOrigin()
                      .AllowAnyMethod()
                      .AllowAnyHeader();
            }
        );
    }
);

builder.Services.AddSingleton<DatabaseContext>(_ => new DatabaseContext(appSettings!));

builder.Services.AddScoped<GreetingRepository>();
builder.Services.AddScoped<FarewellRepository>();

var app = builder.Build();

app.UseCors(myAllowSpecificOrigins);

app.MapGet("/greeting", (GreetingRepository greetingRepository) =>
    Results.Json(greetingRepository.GetGreeting())
).RequireCors(myAllowSpecificOrigins);

app.MapGet("/farewell", (FarewellRepository farewellRepository) =>
    Results.Json(farewellRepository.GetFarewell())
).RequireCors(myAllowSpecificOrigins);

app.MapGet("/", () =>  Results.Json("Hello World!"));

app.Run();