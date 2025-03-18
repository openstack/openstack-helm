{{/*
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
   http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

# Appends annotations for configuring prometheus scrape endpoints via
# annotations. The required annotations are:
# * `prometheus.io/scrape`: Only scrape services that have a value of `true`
# * `prometheus.io/scheme`: If the metrics endpoint is secured then you will need
# to set this to `https` & most likely set the `tls_config` of the scrape config.
# * `prometheus.io/path`: If the metrics path is not `/metrics` override this.
# * `prometheus.io/port`: If the metrics are exposed on a different port to the
# service then set this appropriately.

{{- define "helm-toolkit.snippets.prometheus_service_annotations" -}}
{{- $config := index . 0 -}}
{{- if $config.scrape }}
prometheus.io/scrape: {{ $config.scrape | quote }}
{{- end }}
{{- if $config.scheme }}
prometheus.io/scheme: {{ $config.scheme | quote }}
{{- end }}
{{- if $config.path }}
prometheus.io/path: {{ $config.path | quote }}
{{- end }}
{{- if $config.port }}
prometheus.io/port: {{ $config.port | quote }}
{{- end }}
{{- end -}}
