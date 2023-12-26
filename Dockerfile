# Use an official Ubuntu 20.04 LTS image as a parent image
FROM ubuntu:20.04

# Install nginx
RUN apt-get update && \
    apt-get install -y nginx 
##    && \
##    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /var/www/html

# Copy the index.html file from the current directory to the container
COPY index.html .

# Expose port 80
EXPOSE 80

# CMD to start nginx in the foreground (executable form)
CMD ["nginx", "-g", "daemon off;"]

