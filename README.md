# Load Balancer

System and Network Administration project: several API instances use one
PostgreSQL database, and Nginx distributes incoming requests between them.

## Team Roles

1. Arsen Latipov - Report.
2. Adeliya Nagimova - Spring Boot API and SQL script.
3. Rolan Muliukin - Deployment and Nginx configuration.
4. Timur Bikmetov - CI/CD pipeline on GitHub Actions.

## Application Overview

- **PostgreSQL**: relational database to store application data.
- **Java Spring Boot API**: application that retrieves data from PostgreSQL and
  returns it to users.
- **Nginx**: reverse proxy and load balancer that distributes requests between
  several API instances.
- **Docker Compose**: starts all services together.
- **GitHub Actions**: CI/CD pipeline for deployment automation.

## Project Steps

1. Create a Java API application that connects to a PostgreSQL database.
2. Configure PostgreSQL setup.
3. Configure Nginx load balancer.
4. Containerize the application with Docker Compose.
5. Store database credentials in a .env file for security.
6. Develop CI/CD pipeline with GitHub Actions for deployment automation.
7. Deploy.

## Technologies

- Java
- Spring Boot
- PostgreSQL
- Nginx
- Docker Compose
- GitHub Actions