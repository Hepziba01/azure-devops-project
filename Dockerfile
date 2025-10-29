# Use the official lightweight Nginx image
FROM nginx:1.25-alpine

# Remove the default Nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy the contents of the local 'public/' folder to the Nginx web root.
COPY public/ /usr/share/nginx/html 
# Note: The trailing slash on 'public/' is important, though Docker usually handles it.
# The core fix is ensuring 'public' is the source directory.

# Expose port 80 (Nginx's default port)
EXPOSE 80