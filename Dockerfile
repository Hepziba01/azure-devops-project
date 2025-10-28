# Use the official lightweight Nginx image
FROM nginx:1.25-alpine

# Remove the default Nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy your static website files (index.html, assets, etc.)
# from your project's root to the Nginx web directory
COPY . /usr/share/nginx/html

# Expose port 80 (Nginx's default port)
EXPOSE 80