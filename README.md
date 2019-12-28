# my-kube
An infrastructure-as-code definition for a Kubernetes cluster.

## Instructions

Edit `setup.sh` to your liking. It will create a new GCP Project containing a Kubernetes cluster based on the parameters provided.
Then, run it.
```
./setup.sh
```

To delete *the entire project*, run
```
./teardown.sh
```

**TODO:**
* Install a Jenkins deployment that child projects can use to deploy themselves.
* Automate the granting of permissions for GKE to pull images on initial setup.
* Install monitoring.
