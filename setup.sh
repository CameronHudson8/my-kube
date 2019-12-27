#!/bin/sh

# Exit if any command fails
set -e

echo "LOGGING IN"
ACCOUNT_EMAIL="cameronhudson8@gmail.com"
gcloud auth login $ACCOUNT_EMAIL

echo "CHECKING PROJECT EXISTENCE"
PROJECT_ID="cameronhudson8-my-kube"
PROJECT_NAME="my-kube"
if gcloud projects list | grep -q $PROJECT_ID 
then
    echo "PROJECT ALREADY EXISTS"
else
    echo "CREATING PROJECT"
    gcloud projects create $PROJECT_ID --name $PROJECT_NAME
fi

echo "ATTACHING BILLING ACCOUNT"
gcloud components install alpha -q > /dev/null
BILLING_ACCOUNT_ID=$(gcloud alpha billing accounts list | awk 'NR == 2 { print $1 }')
gcloud alpha billing projects link $PROJECT_ID --billing-account $BILLING_ACCOUNT_ID > /dev/null

echo "ENABLING NECESSARY APIS"
gcloud --project=$PROJECT_ID services enable compute.googleapis.com
gcloud --project=$PROJECT_ID services enable container.googleapis.com
gcloud --project=$PROJECT_ID services enable containerregistry.googleapis.com
gcloud --project=$PROJECT_ID services enable iam.googleapis.com
gcloud --project=$PROJECT_ID services enable iamcredentials.googleapis.com
gcloud --project=$PROJECT_ID services enable pubsub.googleapis.com

CLUSTER_NAME="my-cluster"
ZONE_NAME="us-west1-c"
NUM_NODES="2"
USE_PREEMPTIBLE="true"
MACHINE_TYPE_NAME="g1-small"
echo "CHECKING CLUSTER EXISTENCE"
if gcloud container clusters list | grep $CLUSTER_NAME -q
then
    echo "CLUSTER ALREADY EXISTS"
else
    echo "CREATING CLUSTER"
    gcloud --project=$PROJECT_ID container clusters create $CLUSTER_NAME \
        --no-enable-basic-auth \
        --no-issue-client-certificate \
        --enable-ip-alias \
        --metadata disable-legacy-endpoints=true \
        --zone=$ZONE_NAME \
        --num-nodes=$NUM_NODES \
        $( (( $USE_PREEMPTIBLE == true )) && printf %s '--preemptible' ) \
        --machine-type=$MACHINE_TYPE_NAME \
        -q
    gcloud --project=$PROJECT_ID config set compute/zone $ZONE_NAME -q
fi

echo "CHECKING TILLER EXISTENCE"
if kubectl -n kube-system get pods | grep tiller -q
then
    echo "TILLER ALREADY INSTALLED"
else
    echo "INSTALLING TILLER"
    kubectl create serviceaccount --namespace kube-system tiller
    kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
    helm init --service-account tiller
fi

echo "CHECKING INGRESS EXISTENCE"
if kubectl -n ingress get pods | grep nginx -q
then
    echo "INGRESS ALREADY INSTALLED"
else
    echo "INSTALLING NGINX INGRESS"
    helm install \
      --namespace ingress \
      --name nginx-ingress \
      stable/nginx-ingress \
      --set rbac.create=true \
      --set controller.publishService.enabled=true \
      --set controller.replicaCount=2
fi
