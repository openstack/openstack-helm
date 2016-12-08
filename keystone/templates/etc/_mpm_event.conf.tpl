<IfModule mpm_event_module>
  ServerLimit         1024
  StartServers        32
  MinSpareThreads     32
  MaxSpareThreads     256
  ThreadsPerChild     25
  MaxRequestsPerChild 128
  ThreadLimit         720
</IfModule>