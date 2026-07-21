To automate provisioning of a production-ready k8s cluster.

## Key Features & Architecture

* **Automated Bootstrap Sequence:** Deployment of control plane and worker nodes using `kubeadm`.
* **eBPF-driven CNI:** Cilium integration as `kube-proxy` replacement; for high-performance networking and observability (Hubble enabled).
* **Container Runtime Setup:** Containerd configuration with `systemd` cgroup driver alignment.
* **Declarative Package Management:** Helm chart deployment integrated natively into the provisioning workflow.
* **Decoupled Architecture:** Modular role structure separating runtime, control plane initialization, CNI installation, and node joining.
