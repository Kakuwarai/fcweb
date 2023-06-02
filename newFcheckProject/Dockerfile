# Use the official Flutter Docker image as the base image
FROM cirrusci/flutter

 

# Set the working directory inside the container
WORKDIR /app

 

# Copy the pubspec.yaml and pubspec.lock files to the container
COPY pubspec.* ./

 

# Run Flutter pub get to fetch the dependencies
RUN flutter pub get

 

# Copy the entire project directory to the container
COPY . .

 

# Build the Flutter web application
RUN flutter build web