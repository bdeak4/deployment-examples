FROM node:18

WORKDIR /app

RUN apt-get update && apt-get install -y curl cron

COPY package*.json ./

RUN yarn

COPY . .

EXPOSE 3000

CMD [ "yarn", "start" ]
