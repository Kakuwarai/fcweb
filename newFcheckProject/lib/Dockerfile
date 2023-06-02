# Use the official Flutter base image
FROM cirrusci/flutter:stable

# Set the working directory inside the container
WORKDIR /app

# Copy the pubspec files to the container
COPY pubspec.* /app/

# Run the flutter pub get command to fetch the dependencies
RUN flutter pub get

# Copy the rest of the project files to the container
COPY . /app/

# Build the Flutter app
RUN flutter build apk