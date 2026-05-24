FROM gradle:7.6.4-jdk8 AS build
WORKDIR /app

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8"

COPY build.gradle settings.gradle gradlew gradlew.bat ./
COPY gradle ./gradle
RUN gradle --no-daemon dependencies

COPY src ./src
RUN gradle --no-daemon bootWar

FROM eclipse-temurin:8-jre
WORKDIR /app

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8"

RUN mkdir -p /usr/local/webTempFiles/road-sos

COPY --from=build /app/build/libs/*.war /app/app.war

EXPOSE 8703

ENTRYPOINT ["java", "-jar", "/app/app.war"]
