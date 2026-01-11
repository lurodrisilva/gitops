   1 # Values Schema Reference
   2 
   3 Complete reference for `base_chart/values.yaml` configuration.
   4 
   5 ## Global Configuration
   6 
   7 ```yaml
   8 global:
   9   control_plane:
  10     namespace: control-plane-system      # Namespace for ArgoCD Applications
  11     project: addons-project              # ArgoCD project name
  12     repo: https://github.com/lurodrisilva/gitops  # This repository URL
  13     deployment:
  14       limit: 5                           # Maximum retry attempts
  15       backoff:
  16         duration: 240s                   # Initial backoff duration
  17         factor: 2                        # Backoff multiplier
  18         maxDuration: 10m                 # Maximum backoff duration
  19 ```
  20 
  21 ### Fields
  22 
  23 - **namespace**: Namespace where ArgoCD Application CRDs are created
  24 - **project**: ArgoCD project for RBAC and policies
  25 - **repo**: Git repository URL for source
  26 - **deployment.limit**: Number of sync retries before giving up
  27 - **deployment.backoff**: Exponential backoff configuration for retries
  28 
  29 ## Addon Configuration Pattern
  30 
  31 Each addon follows this pattern:
  32 
  33 ```yaml
  34 addon_name:
  35   addon_name: <string>    # Required: Directory name in addon_charts/
  36   enabled: <boolean>      # Required: Enable/disable the addon
  37   namespace: <string>     # Required: Target namespace for deployment
  38 ```
  39 
  40 ### Fields
  41 
  42 - **addon_name**: Must match the directory name in `addon_charts/`
  43 - **enabled**: `true` to deploy, `false` to skip
  44 - **namespace**: Kubernetes namespace where addon is deployed
  45 
  46 ## Complete Addon List
  47 
  48 ### Crossplane Resources
  49 
  50 ```yaml
  51 resources:
  52   addon_name: resources
  53   enabled: false
  54   namespace: resources-system
  55 ```
  56 
  57 Manages Crossplane-based Azure resources.
  58 
  59 ### Crossplane Providers
  60 
  61 ```yaml
  62 providers:
  63   addon_name: providers
  64   enabled: false
  65   namespace: resources-system
  66 ```
  67 
  68 Installs Crossplane providers (Azure, AWS, GCP).
  69 
  70 ### Provider Configuration
  71 
  72 ```yaml
  73 providers_config:
  74   addon_name: providers-config
  75   enabled: false
  76   namespace: resources-system
  77 ```
  78 
  79 Configures authentication for Crossplane providers.
  80 
  81 ### Backup Solutions
  82 
  83 ```yaml
  84 backup:
  85   addon_name: backup
  86   enabled: false
  87   namespace: backup-system
  88 ```
  89 
  90 Backup and disaster recovery (not yet configured).
  91 
  92 ### Sample Addon
  93 
  94 ```yaml
  95 sample:
  96   addon_name: sample
  97   enabled: false
  98   namespace: backup-system
  99 ```
 100 
 101 Example addon for testing purposes.
 102 
 103 ### Karpenter
 104 
 105 ```yaml
 106 karpenter:
 107   addon_name: karpenter
 108   enabled: false
 109   namespace: karpenter
 110 ```
 111 
 112 Kubernetes cluster autoscaler (currently deployed via Terraform).
 113 
 114 ### Metrics Server
 115 
 116 ```yaml
 117 metrics_server:
 118   addon_name: metrics-server
 119   enabled: false
 120   namespace: control-plane-system
 121 ```
 122 
 123 Core resource metrics API for HPA and kubectl top.
 124 
 125 ### Kube State Metrics
 126 
 127 ```yaml
 128 kube_state_metrics:
 129   addon_name: kube-state-metrics
 130   enabled: false
 131   namespace: control-plane-system
 132 ```
 133 
 134 Kubernetes object state metrics for monitoring.
 135 
 136 ### Node Problem Detector
 137 
 138 ```yaml
 139 node_problem_detector:
 140   addon_name: node-problem-detector
 141   enabled: false
 142   namespace: control-plane-system
 143 ```
 144 
 145 Detects and reports node-level issues.
 146 
 147 ### Cert Manager
 148 
 149 ```yaml
 150 cert_manager:
 151   addon_name: cert-manager
 152   enabled: true
 153   namespace: control-plane-system
 154 ```
 155 
 156 TLS certificate management and automation.
 157 
 158 ### OpenTelemetry Operator
 159 
 160 ```yaml
 161 opentelemetry_operator:
 162   addon_name: opentelemetry-operator
 163   enabled: false
 164   namespace: control-plane-system
 165 ```
 166 
 167 Manages OpenTelemetry collectors and instrumentation.
 168 
 169 ### OpenTelemetry Collector
 170 
 171 ```yaml
 172 opentelemetry_collector:
 173   addon_name: opentelemetry-collector
 174   enabled: false
 175   namespace: control-plane-system
 176 ```
 177 
 178 Collects and exports telemetry data.
 179 
 180 ### Datadog Operator
 181 
 182 ```yaml
 183 datadog_operator:
 184   addon_name: datadog-operator
 185   enabled: false
 186   namespace: control-plane-system
 187 ```
 188 
 189 Datadog monitoring integration.
 190 
 191 ### Reloader
 192 
 193 ```yaml
 194 reloader:
 195   addon_name: reloader
 196   enabled: true
 197   namespace: control-plane-system
 198 ```
 199 
 200 Auto-restarts pods when ConfigMaps/Secrets change.
 201 
 202 ### Cluster Secret
 203 
 204 ```yaml
 205 cluster_secret:
 206   addon_name: cluster-secret
 207   enabled: false
 208   namespace: control-plane-system
 209 ```
 210 
 211 Replicates secrets across namespaces.
 212 
 213 ### Kubecost
 214 
 215 ```yaml
 216 kube_cost:
 217   addon_name: kubecost
 218   enabled: false
 219   namespace: control-plane-system
 220 ```
 221 
 222 Kubernetes cost monitoring and optimization.
 223 
 224 ### Observability Stack
 225 
 226 ```yaml
 227 observability:
 228   addon_name: observability
 229   enabled: false
 230   namespace: control-plane-system
 231 ```
 232 
 233 Complete monitoring stack (Prometheus, Grafana, Loki).
 234 
 235 ### CloudNative PostgreSQL
 236 
 237 ```yaml
 238 cloudnative_pg:
 239   addon_name: cloudnative-pg
 240   enabled: true
 241   namespace: resources-system
 242 ```
 243 
 244 PostgreSQL operator for Kubernetes.
 245 
 246 ## Example Configuration
 247 
 248 ### Minimal (Default)
 249 
 250 ```yaml
 251 global:
 252   control_plane:
 253     namespace: control-plane-system
 254     project: addons-project
 255     repo: https://github.com/lurodrisilva/gitops
 256     deployment:
 257       limit: 5
 258       backoff:
 259         duration: 240s
 260         factor: 2
 261         maxDuration: 10m
 262 
 263 cert_manager:
 264   addon_name: cert-manager
 265   enabled: true
 266   namespace: control-plane-system
 267 
 268 reloader:
 269   addon_name: reloader
 270   enabled: true
 271   namespace: control-plane-system
 272 
 273 cloudnative_pg:
 274   addon_name: cloudnative-pg
 275   enabled: true
 276   namespace: resources-system
 277 ```
 278 
 279 ### Full Observability
 280 
 281 ```yaml
 282 metrics_server:
 283   addon_name: metrics-server
 284   enabled: true
 285   namespace: control-plane-system
 286 
 287 kube_state_metrics:
 288   addon_name: kube-state-metrics
 289   enabled: true
 290   namespace: control-plane-system
 291 
 292 observability:
 293   addon_name: observability
 294   enabled: true
 295   namespace: control-plane-system
 296 ```
 297 
 298 ## Validation
 299 
 300 ### Required Fields
 301 
 302 Every addon must have:
 303 - `addon_name` (string, matches directory)
 304 - `enabled` (boolean)
 305 - `namespace` (string, valid Kubernetes namespace)
 306 
 307 ### Naming Conventions
 308 
 309 - Addon names use `snake_case` in values.yaml
 310 - Directory names use `kebab-case` in addon_charts/
 311 - Example: `cert_manager` in values → `cert-manager` directory
 312 
 313 ## Best Practices
 314 
 315 1. **Start minimal** - Only enable what you need
 316 2. **One at a time** - Enable addons incrementally
 317 3. **Monitor resources** - Check cluster capacity before enabling
 318 4. **Use comments** - Document why addons are enabled/disabled
 319 5. **Version control** - Track all changes in Git
 320 
 321 ## Troubleshooting
 322 
 323 ### Addon Not Deploying
 324 
 325 Check values.yaml syntax:
 326 
 327 ```bash
 328 # Validate YAML
 329 yamllint base_chart/values.yaml
 330 
 331 # Test Helm template rendering
 332 helm template base_chart/
 333 ```
 334 
 335 ### Name Mismatch
 336 
 337 Ensure `addon_name` matches directory:
 338 
 339 ```bash
 340 # List addon directories
 341 ls addon_charts/
 342 
 343 # Check values.yaml
 344 grep "addon_name:" base_chart/values.yaml
 345 ```
 346 
 347 ## Related Documentation
 348 
 349 - [Addon Reference](addon-list.md)
 350 - [Enabling Addons](../guides/enabling-addons.md)
 351 - [Adding Addons](../guides/adding-addons.md)
