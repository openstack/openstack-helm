{{/*
Copyright 2017 The Openstack-Helm Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>Keystone WebSSO redirect</title>
  </head>
  <body>
     <form id="sso" name="sso" action="$host" method="post">
       Please wait...
       <br/>
       <input type="hidden" name="token" id="token" value="$token"/>
       <noscript>
         <input type="submit" name="submit_no_javascript" id="submit_no_javascript"
            value="If your JavaScript is disabled, please click to continue"/>
       </noscript>
     </form>
     <script type="text/javascript">
       window.onload = function() {
         document.forms['sso'].submit();
       }
     </script>
  </body>
</html>
