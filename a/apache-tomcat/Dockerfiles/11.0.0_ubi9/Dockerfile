FROM registry.access.redhat.com/ubi9/ubi:9.3 as build-tomcat

WORKDIR /tmp

ARG PACKAGE_VERSION=11.0.0-M26

# Install necessary tools and dependencies: git, wget, gcc, and Java 21 JDK (not just JRE)
RUN yum install -y git wget gcc-c++ gcc java-21-openjdk java-21-openjdk-devel java-21-openjdk-headless unzip && \
    export JAVA_HOME=/usr/lib/jvm/java-21-openjdk && \
    export PATH=$PATH:$JAVA_HOME/bin && \
    # Download and install Apache Ant
    wget -c https://mirrors.advancedhosters.com/apache/ant/binaries/apache-ant-1.10.14-bin.zip && \
    unzip apache-ant-*.zip && \
    mv apache-ant-*/ /usr/local/ant && \
    export ANT_HOME="/usr/local/ant" && \
    export PATH="$PATH:/usr/local/ant/bin" && \
    # Clone and build Tomcat
    git clone https://github.com/apache/tomcat.git && \
    cd tomcat && \
    git checkout $PACKAGE_VERSION && \
    ant

# Stage 2: Runtime environment for Tomcat
FROM registry.access.redhat.com/ubi9/ubi-minimal:latest

# Install Java 17 JDK (not just JRE)
RUN microdnf install -y java-17-openjdk java-17-openjdk-devel

# Set JAVA_HOME to the JDK
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk
ENV PATH=$PATH:$JAVA_HOME/bin

# Create directory for Tomcat
RUN mkdir -p /usr/local/tomcat

# Copy built Tomcat from the build-tomcat stage
COPY --from=build-tomcat /tmp/tomcat/output/build /usr/local/tomcat/

# Expose default Tomcat port
EXPOSE 8080

# Set working directory
WORKDIR /usr/local/tomcat

# Default command to run Tomcat
ENTRYPOINT ["/usr/local/tomcat/bin/catalina.sh", "run"]
