.PHONY: install argo-workflows
install-argo:
	@echo "Installing Argo Workflows..."
	kubectl create ns argo-events
	helm upgrade --install wf ./helm/argo-workflows/ -n argo --create-namespace -f ./helm/argo-workflows/argo-values.yaml
  kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/stable/manifests/install.yaml
  kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/stable/examples/eventbus/native.yaml
  

  # Install MinIO
.PHONY: install-minio
install-minio:
	helm upgrade --install argo-artifacts ./helm/argo-minio/ -f ./helm/argo-minio/minio-values.yaml -n minio --create-namespace
	kubectl apply -f kubernetes/minio-route.yaml
	# mc alias set minio-k8s http://minio.$(DOMAIN) $(MINIO_USER) $(MINIO_PASSWORD)
	# mc mb minio-k8s/argo-artifacts
