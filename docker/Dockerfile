# Start with the Dart image
FROM google/dart:2.7.2

# Set a working directory
WORKDIR /app

# Copy the entire project
COPY . .

# Install all dependencies
RUN pub get
RUN pub get --offline

# set default environment variables
ENV EMAIL_SERVICE ""
ENV EMAIL_SERVICE_HOST ""
ENV EMAIL_SERVICE_PORT ""
ENV EMAIL_SSL "true"
ENV EMAIL_DABLED "false"
ENV EMAIL_USER ""
ENV EMAIL_PASS ""
ENV EMAIL_FROM ""
ENV CLIENT_NAME ""
ENV CLIENT_URL ""
ENV SERVER_URL ""
ENV EMAIL_SIGNATURE ""

EXPOSE 8080

# Specify the command for running the service
CMD []
ENTRYPOINT ["/usr/bin/dart", "./bin/run.dart"]