#!/bin/bash

# ===========================
# Configurações iniciais
# ===========================
APP_NAME="app-cicd-dio"             # Nome da aplicação
IMAGE_TAG="1.0"                      # Tag da imagem
DOCKER_USERNAME="seu_usuario"        # Seu usuário Docker Hub
DOCKER_REPO="${DOCKER_USERNAME}/${APP_NAME}"  
K8S_DEPLOYMENT_NAME="app-cicd-dio-deployment"
K8S_NAMESPACE="default"              # Namespace do Kubernetes
DOCKERFILE_PATH="./Dockerfile"       # Caminho para o Dockerfile

# ===========================
# Construção da imagem Docker
# ===========================
echo "Construindo imagem Docker..."
docker build -t ${DOCKER_REPO}:${IMAGE_TAG} -f ${DOCKERFILE_PATH} .

if [ $? -ne 0 ]; then
    echo "Erro ao construir a imagem Docker!"
    exit 1
fi

# ===========================
# Login no Docker Hub
# ===========================
echo "Fazendo login no Docker Hub..."
docker login -u ${DOCKER_USERNAME}

if [ $? -ne 0 ]; then
    echo "Erro no login do Docker Hub!"
    exit 1
fi

# ===========================
# Push da imagem Docker
# ===========================
echo "Enviando imagem para o Docker Hub..."
docker push ${DOCKER_REPO}:${IMAGE_TAG}

if [ $? -ne 0 ]; then
    echo "Erro ao enviar a imagem para o Docker Hub!"
    exit 1
fi

# ===========================
# Atualizando Deployment no Kubernetes
# ===========================
echo "Atualizando deployment no Kubernetes..."
kubectl set image deployment/${K8S_DEPLOYMENT_NAME} ${APP_NAME}=${DOCKER_REPO}:${IMAGE_TAG} -n ${K8S_NAMESPACE}

if [ $? -ne 0 ]; then
    echo "Erro ao atualizar o deployment no Kubernetes!"
    exit 1
fi

# ===========================
# Status do deployment
# ===========================
echo "Aguardando rollout do deployment..."
kubectl rollout status deployment/${K8S_DEPLOYMENT_NAME} -n ${K8S_NAMESPACE}

echo "Deploy realizado com sucesso!"
