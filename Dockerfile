# Use the official Deno image as a parent image
FROM denoland/deno:alpine

# Set the working directory in the container
WORKDIR /app

# Copy the application code
COPY . .

# Ensure the data directory exists
#RUN mkdir -p /app/data

# Expose the port the app runs on
EXPOSE 3000

# Cache the dependencies as a layer
RUN deno task build

# Start the application using deno task
CMD ["sh", "-c", "deno task production"]