# My time tracker BI

Проект по ELT данных для анализа активностей пользователей на рабочем столе компьютера. 

Составные части систменой архитектуры проекта:
Airbyte - используется для загрузки данных из базы данных серверного приложения сборщика активностей в DWH, а так-же для запуска трансформации с помощью данного dbt проекта.
Postgres - как СУБД для DWH проекта и системной базы данных для Metabse
CubeJS - для создания сементического слоя для аналитики ключевых метрик
Metabase - для построения витрин bi
Docker + Docker Compose - для создания среды работы решения с помощью развертывания контейнеров для работы вышеперечисленных систем.

## Установка Airbyte

Релизы https://github.com/airbytehq/airbyte/releases

Для данного решения была использована версия 0.50.37, так как последняя версия из-за неизвестной ошибки не смогла загрузить схему данных источника.

Установка в Docker Compose https://docs.airbyte.com/deploying-airbyte/docker-compose

## Установка других систем окружения

 Оставшиеся системы устанавливаются в Docker Compose и сконфигурированы в [Docker containers](./docker-compose.yml).


## Конфигурирвоание Airbyte pipeline для загрузки данных в DWH

![Схема таблиц источника данных](./docs/source_data_schema.png)
