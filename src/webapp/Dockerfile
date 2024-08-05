FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["webapp.csproj", "./"]
RUN dotnet restore "./webapp.csproj"
COPY . .
RUN dotnet build "webapp.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "webapp.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "webapp.dll"]