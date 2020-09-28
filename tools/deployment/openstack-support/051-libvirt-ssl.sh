#!/bin/bash

#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
set -xe

: ${OSH_INFRA_EXTRA_HELM_ARGS_LIBVIRT:="$(./tools/deployment/common/get-values-overrides.sh libvirt)"}

# NOTE(Alex): Use static certs and key for test
cat <<EOF | kubectl apply -f-
apiVersion: v1
kind: Secret
metadata:
  name: libvirt-tls-client
  namespace: openstack
type: Opaque
stringData:
  cacert.pem: |
    -----BEGIN CERTIFICATE-----
    MIID9TCCAl2gAwIBAgIMX2ExnQ//mYG6bVAaMA0GCSqGSIb3DQEBCwUAMBYxFDAS
    BgNVBAMTC2xpYnZpcnQub3JnMB4XDTIwMDkxNTIxMjY1M1oXDTIxMDkxNTIxMjY1
    M1owFjEUMBIGA1UEAxMLbGlidmlydC5vcmcwggGiMA0GCSqGSIb3DQEBAQUAA4IB
    jwAwggGKAoIBgQDaRyGiqmztvL3NHeYGzgwx1Dpg1194Qk1Ak79lowQz9aIARLDG
    yTjj14ToPLC392eWyosCsEQ1dDXx5rKOiEtSJgN18vdAPywsej1wb+f3H3EAslZu
    uOXAiXTBp0ex/EoWqmVmG/JpwP74Rf16WVnTAc1xGABnDwsSIs8gigKI8ha+TdiT
    uFqLNLpJuRXKnI0srBpUrkfhjJmikx9aP99wik+Y6I/iDiUKuDPvjtI4wqlwBqWc
    +WDh2Zx/ot3UGwHS7jUAiZaodAjO40OniQCevwYlbCppj3e7C+3fYSGJ4L/RBUVS
    +HaTyyos/Mz+2gIyNY9y2qi7YCMC1Q0h31o5Cr1G+B9BtQonOGXWq2FuCvCj4KOY
    vpdvnHt6RCvtUkW4rinvqzx9GIiu3E8cFPrMTXH9hgkRvRsKz+X8dGXBstPMNcmT
    N/DQ3Udtg75OlKixNhzxhYn845AhQ0HIZp4SZSsLZRP/KUYtIUhmgIwR84o6Jhb5
    Rlf/zhVTauAD+6kCAwEAAaNDMEEwDwYDVR0TAQH/BAUwAwEB/zAPBgNVHQ8BAf8E
    BQMDBwQAMB0GA1UdDgQWBBRqB1vUFPzNJVgSrh2R2WnIvO+T6zANBgkqhkiG9w0B
    AQsFAAOCAYEAl4FDGkogq8eRwBE4QIwSlcjeUFTKc142PN3ZiVsx/QHwaZQwo+N4
    JNflN15+GPasm/yNs7hYlowNcb6GC93k2NRaZ66jXQ3Yp1T2fSIvs2vKMj362eXK
    hcfjG//t4HUrNqivTcpwg+klDXV/w0K0/cFVnwWaGjvfRU6lx8/fBGmag30t0UQq
    UgCuPclV53JCArdGhoRZcxvAgql+uWxdyvsdmdFvaCe0D3n15nRMuFhFkrDIxyjI
    JHBu+Z32yn6zTTkZPoPpPvSFQiXCzppdKLvGs/vbMi6qKty6wMZcpZtzTaKNHxUr
    n0+/BeMDuQT7IYGl29Ds6LzFnnYhN4Ckh+R8nCml9+JicQPQNL1TC0u1ZlrQdSIc
    kqpLCxb4OGp2u5eYxMaXKHWpl5LJoJbe9Rvyr5yV+zx46FH0o0qz8Rvka32hSiDG
    FpNX6DoAEk3zVSYdFB5xTQ6h0BK1dMMbHPVzuXaYa0N2yjEWvBfjcVygn2164Rkj
    6ZwFOKGDbhUL
    -----END CERTIFICATE----
  clientcert.pem: |
    -----BEGIN CERTIFICATE-----
    MIIEazCCAtOgAwIBAgIMX2E0dSC5i+cK7sDUMA0GCSqGSIb3DQEBCwUAMBYxFDAS
    BgNVBAMTC2xpYnZpcnQub3JnMB4XDTIwMDkxNTIxMzkwMVoXDTIxMDkxNTIxMzkw
    MVowWTEOMAwGA1UEAxMFaG9zdDIxFDASBgNVBAoTC2xpYnZpcnQub3JnMREwDwYD
    VQQHEwhNb250cmVhbDERMA8GA1UECBMITW9udHJlYWwxCzAJBgNVBAYTAkNBMIIB
    ojANBgkqhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEA2tZ4SWNtyNadoHjMBgRJp2wq
    zHn1u5p6bgDDnr82aXyQWuNvuicwvrZfCOtPQ47oaALUP8UCoJo1Ym38DAL+yBNl
    msbbpepOV41BfyZCIzEIzq6eIdEB8fjbNYvisJKXUcfpaO/l0tU/NhTwXJ8m+cro
    Wh2vRO5V4hw+ULey5qNPvKP4MlSf8FZ7MmFeY0yludjVBnjnx+Swiq/gXMgb576c
    OOVBFywjsaBI4J1+SUF9vAp/X7qUXMLWEPXQGMMDfQb1dq5IrA1dIqgYg3vEPjT4
    uLm/p7ZYCcDZuB1DdwPYqZjoQBi/DwBLdEV9Nhy4C0WB6hbOQ3sStcnr8Jvv5OJu
    77Bh9i55sjjSRmhNCV5110v4JkJfADqvFWw1oyoCpccoFmOnxv27Xq6NIEiCQRgC
    qdtcyk6GlqqkZPGGXHH9Z0RUo55GnF7LGmVuZhUP3zlxZAeOcd5lIKCBjGRtZXxr
    DkaaIpoPCIPGNjpaCXQLJvCmF1OZmDXN2O3HC4qJAgMBAAGjdjB0MAwGA1UdEwEB
    /wQCMAAwEwYDVR0lBAwwCgYIKwYBBQUHAwIwDwYDVR0PAQH/BAUDAwegADAdBgNV
    HQ4EFgQUTFvg8/AISJddhIxdN1Qq8Z6+KCUwHwYDVR0jBBgwFoAUagdb1BT8zSVY
    Eq4dkdlpyLzvk+swDQYJKoZIhvcNAQELBQADggGBALZYn9Mu67xyPKojI5PKETD0
    kLCamToW7k+p/LvpAJkqGDs8OabHXfzCCRl5cy6i1qcyvoyTL3hhXQNnlVe9j+G8
    TqEYDUupKQm2L6GGuKudQ/TbvCMGfhPYgYGSfoyml8kuXKEGw/hSQW+LlsLjriu0
    U6oPJ3P9t5gwnGuf82XXpdvBWbzVbJKC9lDtrk4YPMVNwHYtZGh4lMOBmYPAzRMV
    vy+oDGpUHVslgRAuR6ElQ3hCDzSM85wSOAnf6Jdk40OSNEHklXlWaorBJsQSfhNH
    uQNyoDJVWUoTaAoOkBifTcwkztNnsCW9/zjeTPzy82k+FXEP+kqRKl7Z6by9MHaq
    v7cN61i2+FXSCHlcFzv7kRub5PBg67xLOUyzS9mkyyuZmiGhSlxLxMh+iksZyiGQ
    F0S0jE+5Zv0OuFcwJCA7z8OziSbGVq+Hc6ERe1/0dtoxNqDs4q0voMunqgIJ0sex
    0LGjdLdnU1+SFYPnKGJEDKdfYjbAHo3XIX3n8Yz18g==
    -----END CERTIFICATE-----
  clientkey.pem: |
    -----BEGIN RSA PRIVATE KEY-----
    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
    -----END RSA PRIVATE KEY-----
EOF


cat <<EOF | kubectl apply -f-
apiVersion: v1
kind: Secret
metadata:
  name: libvirt-tls-server
  namespace: openstack
type: Opaque
stringData:
  cacert.pem: |
    -----BEGIN CERTIFICATE-----
    MIID9TCCAl2gAwIBAgIMX2ExnQ//mYG6bVAaMA0GCSqGSIb3DQEBCwUAMBYxFDAS
    BgNVBAMTC2xpYnZpcnQub3JnMB4XDTIwMDkxNTIxMjY1M1oXDTIxMDkxNTIxMjY1
    M1owFjEUMBIGA1UEAxMLbGlidmlydC5vcmcwggGiMA0GCSqGSIb3DQEBAQUAA4IB
    jwAwggGKAoIBgQDaRyGiqmztvL3NHeYGzgwx1Dpg1194Qk1Ak79lowQz9aIARLDG
    yTjj14ToPLC392eWyosCsEQ1dDXx5rKOiEtSJgN18vdAPywsej1wb+f3H3EAslZu
    uOXAiXTBp0ex/EoWqmVmG/JpwP74Rf16WVnTAc1xGABnDwsSIs8gigKI8ha+TdiT
    uFqLNLpJuRXKnI0srBpUrkfhjJmikx9aP99wik+Y6I/iDiUKuDPvjtI4wqlwBqWc
    +WDh2Zx/ot3UGwHS7jUAiZaodAjO40OniQCevwYlbCppj3e7C+3fYSGJ4L/RBUVS
    +HaTyyos/Mz+2gIyNY9y2qi7YCMC1Q0h31o5Cr1G+B9BtQonOGXWq2FuCvCj4KOY
    vpdvnHt6RCvtUkW4rinvqzx9GIiu3E8cFPrMTXH9hgkRvRsKz+X8dGXBstPMNcmT
    N/DQ3Udtg75OlKixNhzxhYn845AhQ0HIZp4SZSsLZRP/KUYtIUhmgIwR84o6Jhb5
    Rlf/zhVTauAD+6kCAwEAAaNDMEEwDwYDVR0TAQH/BAUwAwEB/zAPBgNVHQ8BAf8E
    BQMDBwQAMB0GA1UdDgQWBBRqB1vUFPzNJVgSrh2R2WnIvO+T6zANBgkqhkiG9w0B
    AQsFAAOCAYEAl4FDGkogq8eRwBE4QIwSlcjeUFTKc142PN3ZiVsx/QHwaZQwo+N4
    JNflN15+GPasm/yNs7hYlowNcb6GC93k2NRaZ66jXQ3Yp1T2fSIvs2vKMj362eXK
    hcfjG//t4HUrNqivTcpwg+klDXV/w0K0/cFVnwWaGjvfRU6lx8/fBGmag30t0UQq
    UgCuPclV53JCArdGhoRZcxvAgql+uWxdyvsdmdFvaCe0D3n15nRMuFhFkrDIxyjI
    JHBu+Z32yn6zTTkZPoPpPvSFQiXCzppdKLvGs/vbMi6qKty6wMZcpZtzTaKNHxUr
    n0+/BeMDuQT7IYGl29Ds6LzFnnYhN4Ckh+R8nCml9+JicQPQNL1TC0u1ZlrQdSIc
    kqpLCxb4OGp2u5eYxMaXKHWpl5LJoJbe9Rvyr5yV+zx46FH0o0qz8Rvka32hSiDG
    FpNX6DoAEk3zVSYdFB5xTQ6h0BK1dMMbHPVzuXaYa0N2yjEWvBfjcVygn2164Rkj
    6ZwFOKGDbhUL
    -----END CERTIFICATE----
  servercert.pem: |
    -----BEGIN CERTIFICATE-----
    MIIEOTCCAqGgAwIBAgIMX2Eywwri9B/TrC1DMA0GCSqGSIb3DQEBCwUAMBYxFDAS
    BgNVBAMTC2xpYnZpcnQub3JnMB4XDTIwMDkxNTIxMzE0N1oXDTIxMDkxNTIxMzE0
    N1owJzEPMA0GA1UEAxMGc2VydmVyMRQwEgYDVQQKEwtsaWJ2aXJ0Lm9yZzCCAaIw
    DQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGBAObsdrSsGTxY7j0BmS11wWVv0zZY
    YHfYA7OFRCfyEuetqU8KYW2AbuMrJJ3B89ymefCboK755vJ63IfXEYDk3m0NEDtb
    AMXPrKjKoo4+FnIyU+xa65M3BvnbquZMFLrP0BqQspjngXZWDq3GFbVTMqT2TeWt
    oeWAeZU99vFwn1I9aT3UPLnnY+lO+URedTzEb5BHHaQmIMMiH6uNNFFY8O3Y4L54
    Th5xkrO+Xl0N+lnz7pbWQSacvheGbTdu1n8CSGIwDPUzJiOWffqnLx3ATjUkY20w
    ZtU6HoySpeQu7XcjeztZOfX8A9iaC327gMj9uUTqMuVPyII0+4S7sfHGv7SKBDUt
    cIeZ7eyrT26Kr+XEFsRJNHtgGEPA2MMzUJ5MwAAIXCm2RV46EGbtkGRlQYDu/mp4
    iP2irXx5O4HuiE51YF+uhQvNMO0T5J+EvqXVXro1YHmjUgywyCfLSvYnGF/DuPW8
    hMb/jX8rccup+jE0mtBq9STEs5b96GT+cQhXEwIDAQABo3YwdDAMBgNVHRMBAf8E
    AjAAMBMGA1UdJQQMMAoGCCsGAQUFBwMBMA8GA1UdDwEB/wQFAwMHoAAwHQYDVR0O
    BBYEFEoGTjAI7woGizDIO6XOMURtvlQ3MB8GA1UdIwQYMBaAFGoHW9QU/M0lWBKu
    HZHZaci875PrMA0GCSqGSIb3DQEBCwUAA4IBgQB9Vu3Awii5Adb0PtluVYNmLZvv
    yLxCMDAdko6PDKXwxZ4pqL6BkyQtt51uxfgGugiFz8Im3Sq5aNAw4NhG3nK5qS/W
    /KwC3jd8OkbM4RwKGlxTM9CbShOvemj+LJmH+dbYvMwxJrahSOw7DhJfIUq2mEjc
    LrN+ygngadJOoiSQ067+qWh8yywQteYgqDInfaGneXcU65aoTZYOXIEKouqfHTZK
    TfWP9WSx/VmnlqTmiXLa7PYGwslgoIIID5tmqPqn8W2z6xSnZDwdUR2yvFtCucaE
    wgsbxdKxNrcYnfK6ZSmXZpptSHO/5HivRxoC7kK5Tzde0g01u9r8FQIYmZi7EoYP
    KZXgZSF3QbTAPC6Ltz7dXGIPc919My27nx5xNz74pTcMIx/wYwtn7l4HMZDJK01s
    KgkgAoyDqDaDMOpZaFkzHA/+UgYj/WMiL1h5j7yiidQmfUAxVU+BH1wqA1AzQkc9
    Pjd4NkUQZY/TpRhcwkjHm9B4LwKGD8L5c6S3gi8=
    -----END CERTIFICATE-----
  serverkey.pem: |
    -----BEGIN RSA PRIVATE KEY-----
    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
    -----END RSA PRIVATE KEY-----
EOF

#NOTE: Lint and package chart
make libvirt

#NOTE: Deploy command
helm upgrade --install libvirt ./libvirt \
  --namespace=openstack \
  --set network.backend="null" \
  ${OSH_INFRA_EXTRA_HELM_ARGS} \
  ${OSH_INFRA_EXTRA_HELM_ARGS_LIBVIRT}

#NOTE: Please be aware that a network backend might affect
#The loadability of this, as some need to be asynchronously
#loaded. See also:
#https://github.com/openstack/openstack-helm-infra/blob/b69584bd658ae5cb6744e499975f9c5a505774e5/libvirt/values.yaml#L151-L172
if [[ "${WAIT_FOR_PODS:=True}" == "True" ]]; then
    ./tools/deployment/common/wait-for-pods.sh openstack
fi

#NOTE: Validate Deployment info
helm status libvirt
