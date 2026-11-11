# Оптимізатор транспортних маршрутів

Вебзастосунок для пошуку найкоротшого замкнутого маршруту між заданими точками (задача комівояжера).

## Блок 1: каркас і балансування

Поточний блок створює ASP.NET Core API, PostgreSQL і два екземпляри API за Nginx. Nginx розподіляє запити між `api1` та `api2`; endpoint діагностики повертає назву екземпляра, який обробив запит.

### Запуск через Docker Compose

Потрібен Docker Desktop із Docker Compose:

```powershell
docker compose up --build
```

Перевірка API та балансування:

```powershell
Invoke-RestMethod http://localhost:8080/health
1..10 | ForEach-Object { Invoke-RestMethod http://localhost:8080/api/system/instance }
```

Відповіді другого запиту повинні містити обидва ідентифікатори (`api1` та `api2`). PostgreSQL доступний локально на порту `5432`; дані зберігаються у Docker volume `postgres_data`. Пароль у Compose є лише значенням для локальної розробки. Перед розгортанням потрібно задати `POSTGRES_PASSWORD` через середовище або секрети платформи.

Зупинити стенд:

```powershell
docker compose down
```

### Локальний запуск API без Docker

```powershell
dotnet run --project src\RouteOptimizer.Api
```

## Наступні блоки

1. Реєстрація та авторизація користувачів, модель даних і підключення до PostgreSQL.
2. Черга задач, обмеження розміру задачі, точний розрахунок маршруту, прогрес і скасування.
3. React-клієнт: вхід, створення задач, статуси та історія.
4. Перевірки, HTTPS-конфігурація та інструкції розгортання.
