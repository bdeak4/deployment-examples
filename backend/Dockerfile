FROM node:18

WORKDIR /app

RUN apt-get install curl cron -y

COPY package*.json ./

RUN yarn

COPY . .

EXPOSE 3000

CMD [ "yarn", "start" ]
