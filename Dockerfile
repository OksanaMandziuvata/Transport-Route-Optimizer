FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY src/RouteOptimizer.Api/RouteOptimizer.Api.csproj src/RouteOptimizer.Api/
RUN dotnet restore src/RouteOptimizer.Api/RouteOptimizer.Api.csproj

COPY src/RouteOptimizer.Api/ src/RouteOptimizer.Api/
RUN dotnet publish src/RouteOptimizer.Api/RouteOptimizer.Api.csproj \
    --configuration Release \
    --output /app/publish \
    --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080
ENTRYPOINT ["dotnet", "RouteOptimizer.Api.dll"]
