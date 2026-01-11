   1 # Addon Reference
   2 
   3 Complete reference for all available addons in the platform.
   4 
   5 ## Currently Enabled Addons
   6 
   7 ### cert-manager
   8 
   9 **Purpose**: Automates TLS certificate management  
  10 **Namespace**: control-plane-system  
  11 **Version**: v1.16.2  
  12 **Upstream**: https://charts.jetstack.io
  13 
  14 Features:
  15 - Automatic certificate issuance and renewal
  16 - Support for Let's Encrypt, Vault, and other issuers
  17 - CRD-based certificate management
  18 
  19 Configuration:
  20 ```yaml
  21 cert-manager:
  22   replicaCount: 2
  23   crds:
  24     enabled: true
  25 ```
  26 
  27 ### reloader
  28 
  29 **Purpose**: Auto-restarts pods when ConfigMaps/Secrets change  
  30 **Namespace**: control-plane-system  
  31 **Upstream**: https://stakater.github.io/Reloader/
  32 
  33 Features:
  34 - Watches ConfigMaps and Secrets
  35 - Triggers rolling restarts automatically
  36 - Annotation-based configuration
  37 
  38 ### cloudnative-pg
  39 
  40 **Purpose**: PostgreSQL operator for Kubernetes  
  41 **Namespace**: resources-system  
  42 **Upstream**: https://cloudnative-pg.io
  43 
  44 Features:
  45 - High-availability PostgreSQL clusters
  46 - Automated backups and recovery
  47 - Connection pooling with PgBouncer
  48 
  49 ## Available Addons (Disabled)
  50 
  51 ### resources
  52 
  53 **Purpose**: Crossplane managed Azure resources  
  54 **Namespace**: resources-system  
  55 **Status**: Disabled
  56 
  57 Deploys Crossplane custom resources for Azure infrastructure.
  58 
  59 ### providers
  60 
  61 **Purpose**: Crossplane provider installations  
  62 **Namespace**: resources-system  
  63 **Status**: Disabled
  64 
  65 Installs Crossplane providers (Azure, AWS, GCP).
  66 
  67 ### providers-config
  68 
  69 **Purpose**: Crossplane provider configurations  
  70 **Namespace**: resources-system  
  71 **Status**: Disabled
  72 
  73 Configures authentication and settings for Crossplane providers.
  74 
  75 ### karpenter
  76 
  77 **Purpose**: Kubernetes cluster autoscaler  
  78 **Namespace**: karpenter  
  79 **Status**: Disabled  
  80 **Note**: Currently deployed via Terraform
  81 
  82 Advanced node autoscaling with custom scheduling.
  83 
  84 ### metrics-server
  85 
  86 **Purpose**: Core resource metrics API  
  87 **Namespace**: control-plane-system  
  88 **Status**: Disabled
  89 
  90 Provides CPU/memory metrics for horizontal pod autoscaling.
  91 
  92 Enable for:
  93 - `kubectl top nodes/pods`
  94 - Horizontal Pod Autoscaler (HPA)
  95 - Vertical Pod Autoscaler (VPA)
  96 
  97 ### kube-state-metrics
  98 
  99 **Purpose**: Kubernetes object state metrics  
 100 **Namespace**: control-plane-system  
 101 **Status**: Disabled
 102 
 103 Exposes metrics about Kubernetes objects (deployments, pods, nodes).
 104 
 105 ### node-problem-detector
 106 
 107 **Purpose**: Node health monitoring  
 108 **Namespace**: control-plane-system  
 109 **Status**: Disabled
 110 
 111 Detects and reports node issues (disk pressure, network issues, etc.).
 112 
 113 ### opentelemetry-operator
 114 
 115 **Purpose**: OpenTelemetry operator for instrumentation  
 116 **Namespace**: control-plane-system  
 117 **Status**: Disabled
 118 
 119 Manages OpenTelemetry collectors and instrumentation.
 120 
 121 ### opentelemetry-collector
 122 
 123 **Purpose**: Telemetry data collection and export  
 124 **Namespace**: control-plane-system  
 125 **Status**: Disabled
 126 
 127 Collects traces, metrics, and logs for observability platforms.
 128 
 129 ### datadog-operator
 130 
 131 **Purpose**: Datadog monitoring integration  
 132 **Namespace**: control-plane-system  
 133 **Status**: Disabled
 134 
 135 Datadog Agent deployment and configuration.
 136 
 137 ### cluster-secret
 138 
 139 **Purpose**: Secret replication across namespaces  
 140 **Namespace**: control-plane-system  
 141 **Status**: Disabled
 142 
 143 Replicates secrets to multiple namespaces.
 144 
 145 ### kubecost
 146 
 147 **Purpose**: Kubernetes cost monitoring and optimization  
 148 **Namespace**: control-plane-system  
 149 **Status**: Disabled
 150 
 151 Tracks resource costs and provides optimization recommendations.
 152 
 153 ### observability
 154 
 155 **Purpose**: Complete monitoring stack (Prometheus, Grafana, Loki)  
 156 **Namespace**: control-plane-system  
 157 **Status**: Disabled
 158 
 159 Full observability platform including:
 160 - Prometheus for metrics
 161 - Grafana for visualization
 162 - Loki for logs
 163 - Alertmanager for alerts
 164 
 165 ### backup
 166 
 167 **Purpose**: Backup solutions  
 168 **Namespace**: backup-system  
 169 **Status**: Disabled  
 170 **Note**: Not yet configured
 171 
 172 Backup and disaster recovery solutions.
 173 
 174 ## Addon Dependencies
 175 
 176 Some addons depend on others. Enable in order:
 177 
 178 1. **metrics-server** → Required for HPA
 179 2. **cert-manager** → Required for TLS certificates
 180 3. **kube-state-metrics** → Required for full metrics
 181 4. **observability** → Requires metrics-server and kube-state-metrics
 182 
 183 ## Resource Requirements
 184 
 185 Estimated resource usage when enabled:
 186 
 187 | Addon | CPU Request | Memory Request | Storage |
 188 |-------|-------------|----------------|---------|
 189 | cert-manager | 100m | 100Mi | - |
 190 | reloader | 10m | 32Mi | - |
 191 | cloudnative-pg | 100m | 100Mi | - |
 192 | metrics-server | 100m | 200Mi | - |
 193 | kube-state-metrics | 10m | 32Mi | - |
 194 | observability | 2000m | 4Gi | 50Gi |
 195 | kubecost | 500m | 1Gi | 10Gi |
 196 
 197 ## Sync Waves
 198 
 199 Addons are deployed in order based on sync wave:
 200 
 201 | Wave | Addons |
 202 |------|--------|
 203 | 0 | resources, providers |
 204 | 1-5 | karpenter, metrics-server |
 205 | 9 | cert-manager |
 206 | 10 | reloader |
 207 | 14 | cloudnative-pg |
 208 
 209 ## Adding Custom Addons
 210 
 211 See [Adding Addons Guide](../guides/adding-addons.md) for instructions.
 212 
 213 ## Related Documentation
 214 
 215 - [Enabling Addons](../guides/enabling-addons.md)
 216 - [Values Schema](values-schema.md)
 217 - [GitOps Workflow](../architecture/gitops-workflow.md)
