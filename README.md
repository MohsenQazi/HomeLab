## HomeLab-Platform
To review and enhance my SRE skills in the context of Kubernetes clusters.

### APT Cacher
- Motivation

In a homelab, node provisioning and cluster rebuilds happen frequently — testing upgrades, validating Terraform/Ansible changes, or running disaster-recovery drills. Each rebuild re-fetches the same OS and k8s packages from upstream repositories, increasing external dependency and network egress costs.

**`apt-cacher-ng` is deployed as a pull-through caching proxy** on the hypervisor, sitting between internal VMs and upstream package repositories — the same pattern used by enterprise artifact proxies (Artifactory, Nexus) applied at hypervisor scale.

- Goals

 1. **Reduced blast radius of upstream issues** 
 2. **Improve resilience to upstream/network outages**
 3. **Lower external bandwidth / egress**
 4. **Faster provisioning / lower MTTR**
 5. **Lower operational toil**

- Architecture
```mermaid
flowchart TB

    %% ================= BEFORE =================
    subgraph BEFORE["before"]
        direction LR

        VM1["K8s VMs<br/><span style='color:#1976d2'>apt request</span>"]
        NET1["internet<br/><span style='color:#777'>every request</span>"]
        UP1["upstream<br/><span style='color:#d84315'>debian, k8s repos</span>"]

        VM1 --> NET1 --> UP1
    end

    %% ================= AFTER =================
    subgraph AFTER["after"]
        direction LR

        VM2["K8s VMs<br/><span style='color:#1976d2'>apt request</span>"]
        CACHE_NG["apt-cacher-ng<br/><span style='color:#087f5b'>the cache</span>"]
        NET2["internet<br/><span style='color:#777'>cache miss</span>"]
        UP2["upstream<br/><span style='color:#d84315'>debian & k8s</span>"]

        VM2 --> CACHE_NG --> NET2 --> UP2

        CACHE_NG -. "<span style='font-size:13px'>cache hit → served instantly</span>" .-> VM2
    end

    BEFORE -->|adds a cache layer| AFTER

    %% ================= STYLES ================= 
    style BEFORE fill:#fff,stroke:#bbb,stroke-width:1px,stroke-dasharray:6 5
    style AFTER fill:#fff,stroke:#bbb,stroke-width:1px,stroke-dasharray:6 5

    style VM1 fill:#e8f2ff,stroke:#1976d2,color:#222
    style NET1 fill:#f5f3ee,stroke:#888,color:#222
    style UP1 fill:#fff0eb,stroke:#d84315,color:#222

    style VM2 fill:#e8f2ff,stroke:#1976d2,color:#222
    style CACHE_NG fill:#e5f6ef,stroke:#16866b,color:#222
    style NET2 fill:#f5f3ee,stroke:#888,color:#222
    style UP2 fill:#fff0eb,stroke:#d84315,color:#222

    linkStyle default stroke:#888,stroke-width:2px
```

- Steps

 1. Install `apt-cacher-ng` on hypervisor (I tested 3.7.5);
 2. Modifying apt-cacher-ng configuration `acng.conf`:
	- Allow https requests for repos without http `AllowUserPorts: 80 443` .
	- Publish just on the overlay network `BindAddress: 192.168.122.1` . `192.168.122.1` is IP of the virtual bridge on hypervisor to which the VMs (k8s nodes) are connected; And usually used as GW for the VMs.
	- Make sure of `Remap`s which prevent duplicate repositories with different hostnames.
 3. Client-side changes will be applied for Linux machines via cloud-init and for K8S repos via relevant ansible roles.
	* Also make sure the repos are accessible to the hypervisor.
