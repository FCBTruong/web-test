# Use the official Node.js image as a base
FROM node:14

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy the package.json and package-lock.json files to the working directory
COPY package*.json ./

# Install the dependencies
RUN npm install

# Copy the rest of the application code to the working directory
COPY . .

# Expose the port the app runs on (if applicable)
EXPOSE 3000

# Define the command to run your app or tests
CMD ["npm", "start"]
