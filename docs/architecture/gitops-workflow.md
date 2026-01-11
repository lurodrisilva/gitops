   1 # GitOps Workflow
   2 
   3 This document explains the GitOps workflow used in this repository.
   4 
   5 ## Overview
   6 
   7 This repository implements the **App-of-Apps pattern** with ArgoCD:
   8 
   9 1. Infrastructure deploys ArgoCD (via 01-aks-tf)
  10 2. ArgoCD watches this repository's `base_chart/`
  11 3. `base_chart` creates ArgoCD Applications for each enabled addon
  12 4. Each Application deploys its addon from `addon_charts/`
  13 
  14 ## Architecture Diagram
  15 
  16 ```
  17 ┌─────────────────────────────────────────────────────────┐
  18 │ Git Repository (https://github.com/lurodrisilva/gitops)│
  19 │                                                          │
  20 │  base_chart/                                            │
  21 │  ├── values.yaml (addon enabled flags)                 │
  22 │  └── templates/ (ArgoCD Application CRDs)              │
  23 │                                                          │
  24 │  addon_charts/                                          │
  25 │  ├── cert-manager/                                      │
  26 │  ├── reloader/                                          │
  27 │  └── ...                                                │
  28 └─────────────────────────────────────────────────────────┘
  29                         ↓  (git pull)
  30 ┌─────────────────────────────────────────────────────────┐
  31 │                      ArgoCD                              │
  32 │                                                          │
  33 │  Gitops Application (deployed by Terraform)             │
  34 │  • Monitors: base_chart/                                │
  35 │  • Auto-sync: enabled                                   │
  36 │  • Prune: enabled                                       │
  37 └─────────────────────────────────────────────────────────┘
  38                         ↓  (creates)
  39 ┌─────────────────────────────────────────────────────────┐
  40 │           ArgoCD Applications (one per addon)            │
  41 │                                                          │
  42 │  For each addon where enabled: true in values.yaml     │
  43 │  • cert-manager Application                             │
  44 │  • reloader Application                                 │
  45 │  • cloudnative-pg Application                           │
  46 └─────────────────────────────────────────────────────────┘
  47                         ↓  (deploys)
  48 ┌─────────────────────────────────────────────────────────┐
  49 │            Kubernetes Resources (addons)                 │
  50 │                                                          │
  51 │  • Deployments, Services, ConfigMaps, etc.             │
  52 │  • Each addon in its designated namespace               │
  53 └─────────────────────────────────────────────────────────┘
  54 ```
  55 
  56 ## Workflow Steps
  57 
  58 ### 1. Change Request
  59 
  60 Developer modifies `base_chart/values.yaml`:
  61 
  62 ```yaml
  63 metrics_server:
  64   enabled: true  # Changed from false
  65 ```
  66 
  67 ### 2. Commit and Push
  68 
  69 ```bash
  70 git add base_chart/values.yaml
  71 git commit -m "Enable metrics-server"
  72 git push
  73 ```
  74 
  75 ### 3. ArgoCD Detection
  76 
  77 ArgoCD polls the repository (~3 minutes):
  78 - Detects change in base_chart/
  79 - Compares desired state (Git) vs current state (cluster)
  80 - Identifies drift
  81 
  82 ### 4. Automatic Sync
  83 
  84 ArgoCD automatically syncs (due to `automated: true`):
  85 - Renders base_chart Helm template
  86 - Creates new Application CRD for metrics-server
  87 - Applies to cluster
  88 
  89 ### 5. Addon Deployment
  90 
  91 The new Application:
  92 - Points to addon_charts/metrics-server/
  93 - Resolves Helm dependencies
  94 - Deploys resources to control-plane-system namespace
  95 
  96 ### 6. Continuous Monitoring
  97 
  98 ArgoCD continuously:
  99 - Monitors Git for changes
 100 - Monitors cluster for drift
 101 - Self-heals if resources are modified or deleted
 102 - Prunes resources no longer in Git
 103 
 104 ## Key Concepts
 105 
 106 ### App-of-Apps Pattern
 107 
 108 The `base_chart` is a "parent" application that creates "child" applications:
 109 
 110 ```
 111 Gitops App (parent)
 112   ├── cert-manager App (child)
 113   ├── reloader App (child)
 114   └── metrics-server App (child)
 115 ```
 116 
 117 Benefits:
 118 - Single source of truth (values.yaml)
 119 - Atomic addon management
 120 - Organized structure
 121 - Easy to add/remove addons
 122 
 123 ### Sync Policies
 124 
 125 #### Automated Sync
 126 
 127 ```yaml
 128 syncPolicy:
 129   automated:
 130     prune: true      # Delete resources not in Git
 131     selfHeal: true   # Revert manual changes
 132 ```
 133 
 134 - Changes in Git automatically applied
 135 - Manual cluster changes are reverted
 136 - Deleted resources are pruned
 137 
 138 #### Sync Waves
 139 
 140 Templates use sync waves for ordering:
 141 
 142 ```yaml
 143 annotations:
 144   argocd.argoproj.io/sync-wave: "9"
 145 ```
 146 
 147 Lower numbers deploy first. Example order:
 148 - Wave 0: Crossplane resources
 149 - Wave 9: cert-manager
 150 - Wave 10: reloader
 151 - Wave 14: cloudnative-pg
 152 
 153 ### Prune Behavior
 154 
 155 When an addon is disabled:
 156 1. Application CRD removed from cluster
 157 2. ArgoCD deletes associated resources
 158 3. Namespace may remain (depends on policy)
 159 
 160 ## GitOps Principles
 161 
 162 This repository follows GitOps principles:
 163 
 164 1. **Declarative**: Desired state in Git
 165 2. **Versioned**: All changes in Git history
 166 3. **Automated**: ArgoCD applies changes
 167 4. **Auditable**: Git log shows all changes
 168 5. **Self-healing**: Drift automatically corrected
 169 
 170 ## Comparison: Manual vs GitOps
 171 
 172 ### Manual Deployment
 173 
 174 ```bash
 175 # Traditional approach
 176 helm install metrics-server metrics-server/metrics-server \
 177   --namespace control-plane-system \
 178   --values custom-values.yaml
 179 ```
 180 
 181 Problems:
 182 - ❌ No audit trail
 183 - ❌ Manual process
 184 - ❌ Drift undetected
 185 - ❌ No rollback
 186 - ❌ Per-cluster configuration
 187 
 188 ### GitOps Deployment
 189 
 190 ```bash
 191 # GitOps approach
 192 git commit -m "Enable metrics-server"
 193 git push
 194 ```
 195 
 196 Benefits:
 197 - ✅ Complete audit trail
 198 - ✅ Automated deployment
 199 - ✅ Drift detected and corrected
 200 - ✅ Easy rollback (git revert)
 201 - ✅ Same config for all clusters
 202 
 203 ## Rollback Procedure
 204 
 205 To rollback a change:
 206 
 207 ```bash
 208 # Find the commit to revert
 209 git log --oneline
 210 
 211 # Revert the change
 212 git revert <commit-hash>
 213 
 214 # Push
 215 git push
 216 ```
 217 
 218 ArgoCD will automatically sync the reverted state.
 219 
 220 ## Best Practices
 221 
 222 1. **Small changes** - One addon per commit
 223 2. **Meaningful commits** - Clear messages
 224 3. **Test first** - Use dev environment
 225 4. **Monitor sync** - Watch ArgoCD UI
 226 5. **Use branches** - Feature branches for large changes
 227 6. **Review PRs** - Peer review before merging
 228 7. **Tag releases** - Version important states
 229 
 230 ## Troubleshooting
 231 
 232 ### Sync Not Happening
 233 
 234 ```bash
 235 # Check ArgoCD is running
 236 kubectl get pods -n devops-system
 237 
 238 # Check application status
 239 kubectl get application gitops -n control-plane-system
 240 
 241 # Force refresh
 242 kubectl patch application gitops -n control-plane-system \
 243   --type merge -p '{"operation":{"initiatedBy":{"username":"admin"}},"metadata":{"annotations":{"argocd.argoproj.io/refresh":"hard"}}}'
 244 ```
 245 
 246 ### Drift Detected But Not Healing
 247 
 248 Check sync policy:
 249 
 250 ```bash
 251 kubectl get application cert-manager -n control-plane-system \
 252   -o jsonpath='{.spec.syncPolicy.automated}' | jq
 253 ```
 254 
 255 Should show `{"prune":true,"selfHeal":true}`.
 256 
 257 ## Related Documentation
 258 
 259 - [Quickstart Guide](../setup/quickstart.md)
 260 - [Enabling Addons](../guides/enabling-addons.md)
 261 - [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
