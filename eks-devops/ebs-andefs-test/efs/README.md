The EFS CSI driver supports dynamic and static provisioning. Currently dynamic provisioning creates an access point for each PersistentVolume.
This mean an AWS EFS file system has to be created manually on AWS first and should be provided as an input to the StorageClass parameter. For static provisioning,
AWS EFS file system needs to be created manually on AWS first.
After that it can be mounted inside a container as a volume using the driver.

aws efs describe-file-systems

# note the EFS ID and put it in the storageclass

# example storage class below

kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
name: efs-sc
provisioner: efs.csi.aws.com
parameters:
provisioningMode: efs-ap
fileSystemId: fs-020ed00876a82a430
directoryPerms: "700"
gidRangeStart: "1000" # optional
gidRangeEnd: "2000" # optional
basePath: "/dynamic_provisioning" # optional
subPathPattern: "${.PVC.namespace}/${.PVC.name}" # optional
ensureUniqueDirectory: "true" # optional
reuseAccessPoint: "false" # optional
