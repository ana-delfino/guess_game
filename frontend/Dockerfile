# ---------- Etapa 1: build do React (Node 18) ----------
ARG NODE_VERSION=18.17.0
ARG NGINX_VERSION=1.28-alpine
FROM node:${NODE_VERSION}-alpine AS build

WORKDIR /app
# O Cypress é devDependency: não baixar o binário dele no build
ENV CYPRESS_INSTALL_BINARY=0

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
# O frontend chama ${REACT_APP_BACKEND_URL}/create e ${REACT_APP_BACKEND_URL}/guess/<id>.
# Usamos o caminho relativo /api, que o próprio NGINX encaminha ao backend:
# o navegador fala com uma única origem (sem host fixo e sem problemas de CORS).
ARG REACT_APP_BACKEND_URL=/api
ENV REACT_APP_BACKEND_URL=${REACT_APP_BACKEND_URL}
RUN npm run build

# ---------- Etapa 2: NGINX servindo o build + proxy reverso ----------
FROM nginx:${NGINX_VERSION}

COPY --from=build /app/build /usr/share/nginx/html
# A configuração de proxy reverso / balanceamento (nginx/default.conf) é montada
# pelo docker-compose em /etc/nginx/conf.d/default.conf, sobrescrevendo a padrão.
# Assim ela pode ser ajustada sem rebuild da imagem.

EXPOSE 80
