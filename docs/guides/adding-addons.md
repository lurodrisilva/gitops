   1 # Adding New Addons
   2 
   3 This guide shows you how to add custom addons to the platform.
   4 
   5 ## Prerequisites
   6 
   7 - Understanding of Helm charts
   8 - Access to push to the repository
   9 - Addon Helm chart or ability to create one
  10 
  11 ## Steps to Add a New Addon
  12 
  13 ### 1. Create Addon Chart Directory
  14 
  15 ```bash
  16 mkdir -p addon_charts/my-addon
  17 cd addon_charts/my-addon
  18 ```
  19 
  20 ### 2. Create Chart.yaml
  21 
  22 ```yaml
  23 apiVersion: v2
  24 name: my-addon
  25 description: My custom addon for the platform
  26 type: application
  27 version: 0.1.0
  28 appVersion: "1.0.0"
  29 
  30 # Add upstream chart as dependency
  31 dependencies:
  32   - name: upstream-chart-name
  33     version: 1.2.3
  34     repository: https://charts.example.com
  35 ```
  36 
  37 ### 3. Create values.yaml
  38 
  39 Add custom configuration overrides:
  40 
  41 ```yaml
  42 # Override upstream chart values
  43 upstream-chart-name:
  44   replicaCount: 2
  45   resources:
  46     limits:
  47       cpu: 200m
  48       memory: 256Mi
  49     requests:
  50       cpu: 100m
  51       memory: 128Mi
  52 ```
  53 
  54 ### 4. Create ArgoCD Application Template
  55 
  56 Create `base_chart/templates/XX-my-addon.yaml` (where XX is sync wave number):
  57 
  58 ```yaml
  59 ---
  60 {{- if (.Values.my_addon.enabled) }}
  61 apiVersion: argoproj.io/v1alpha1
  62 kind: Application
  63 metadata:
  64   name: {{ .Values.my_addon.addon_name }}
  65   namespace: {{ .Values.global.control_plane.namespace }}
  66   annotations:
  67     argocd.argoproj.io/sync-wave: "15"  # Adjust as needed
  68   finalizers:
  69     - resources-finalizer.argocd.argoproj.io
  70 spec:
  71   project: {{ .Values.global.control_plane.project }}
  72   source:
  73     repoURL: {{ .Values.global.control_plane.repo }}
  74     targetRevision: HEAD
  75     path: {{ printf "addon_charts/%s" .Values.my_addon.addon_name }}
  76     helm:
  77       valueFiles:
  78         - values.yaml
  79   destination:
  80     server: https://kubernetes.default.svc
  81     namespace: {{ .Values.my_addon.namespace }}
  82   syncPolicy:
  83     automated:
  84       prune: true
  85       selfHeal: true
  86     syncOptions:
  87       - CreateNamespace=true
  88       - Validate=false
  89       - Prune=true
  90     {{- with .Values.global.control_plane.deployment }}
  91     retry:
  92       limit: {{ .limit }}
  93       backoff:
  94         duration: {{ .backoff.duration }}
  95         factor: {{ .backoff.factor }}
  96         maxDuration: {{ .backoff.maxDuration }}
  97     {{- end }}
  98 {{- end }}
  99 ```
 100 
 101 ### 5. Add Configuration to base_chart/values.yaml
 102 
 103 ```yaml
 104 my_addon:
 105   addon_name: my-addon
 106   enabled: false              # Start disabled
 107   namespace: my-addon-system
 108 ```
 109 
 110 ### 6. Test Locally
 111 
 112 ```bash
 113 # Lint the base chart
 114 helm lint base_chart/
 115 
 116 # Template and check output
 117 helm template base_chart/ --values base_chart/values.yaml | grep -A 50 my-addon
 118 
 119 # Update dependencies
 120 helm dependency update addon_charts/my-addon/
 121 ```
 122 
 123 ### 7. Commit and Push
 124 
 125 ```bash
 126 git add addon_charts/my-addon/ base_chart/
 127 git commit -m "Add my-addon platform addon"
 128 git push
 129 ```
 130 
 131 ### 8. Enable and Test
 132 
 133 Edit `base_chart/values.yaml` to enable:
 134 
 135 ```yaml
 136 my_addon:
 137   enabled: true
 138 ```
 139 
 140 Commit, push, and monitor deployment.
 141 
 142 ## Sync Wave Numbers
 143 
 144 Organize addons with sync waves for proper ordering:
 145 
 146 - 0-5: Infrastructure (resources, providers)
 147 - 5-10: Core services (metrics, monitoring)
 148 - 10-15: Platform services (cert-manager, reloader)
 149 - 15+: Application services
 150 
 151 ## Best Practices
 152 
 153 1. **Use dependencies** - Reference upstream charts when possible
 154 2. **Minimal values** - Only override what's necessary
 155 3. **Resource limits** - Always set requests and limits
 156 4. **Namespaces** - Use dedicated namespaces for isolation
 157 5. **Testing** - Test locally before committing
 158 6. **Documentation** - Add README in addon_charts/my-addon/
 159 7. **Versioning** - Pin dependency versions in Chart.yaml
 160 
 161 ## Example: Adding Prometheus
 162 
 163 See `addon_charts/observability/` for a complete example of a complex addon.
 164 
 165 ## Troubleshooting
 166 
 167 ### Dependency Download Fails
 168 
 169 ```bash
 170 # Update dependencies manually
 171 helm dependency update addon_charts/my-addon/
 172 
 173 # Check Chart.lock file is created
 174 ls addon_charts/my-addon/Chart.lock
 175 ```
 176 
 177 ### Template Rendering Issues
 178 
 179 ```bash
 180 # Test template rendering
 181 helm template my-addon addon_charts/my-addon/
 182 
 183 # Check for YAML syntax
 184 yamllint addon_charts/my-addon/values.yaml
 185 ```
 186 
 187 ## Related Documentation
 188 
 189 - [Enabling Addons](enabling-addons.md)
 190 - [Values Schema](../reference/values-schema.md)
 191 - [Addon Reference](../reference/addon-list.md)
