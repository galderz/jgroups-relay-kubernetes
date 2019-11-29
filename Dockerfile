FROM openjdk:11

COPY target/jgroups-relay-kubernetes-1.0-SNAPSHOT.jar /demo.jar

COPY target/dependency/jgroups-4.1.6.Final.jar /lib/jgroups-4.1.6.Final.jar

CMD ["java", "-jar", "/demo.jar"]
