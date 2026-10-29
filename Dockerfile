FROM node:22-alpine
WORKDIR /app
COPY package.json ./
COPY server.js index.html app.js styles.css ./
COPY src ./src
ENV NODE_ENV=production PORT=4173
EXPOSE 4173
USER node
CMD ["npm", "start"]
