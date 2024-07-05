FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["src/webapp/webapp.csproj", "src/webapp/"]
RUN dotnet restore "src/webapp/webapp.csproj"
COPY . .
WORKDIR "/src/src/webapp"
RUN dotnet build "webapp.csproj" -c Release -o /app/build

# Publish the application
FROM build AS publish
RUN dotnet publish "webapp.csproj" -c Release -o /app/publish

# Build final image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "webapp.dll"]