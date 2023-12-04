NAMESPACE="default"
kubectl get deployments -o name -n $NAMESPACE | xargs -I {} kubectl rollout status {} -n $NAMESPACE 
kubectl get jobs -o name -n $NAMESPACE | xargs -I {} kubectl wait --for=condition=complete {} -n $NAMESPACE
gh workflow list --repo $GH_OWNER/$GH_REPO
