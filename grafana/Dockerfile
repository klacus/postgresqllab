FROM grafana/grafana-oss:13.0.1

# Grafana runs as UID 472 by default.
# Connection parameters and admin credentials are provided at runtime via
# environment variables. No credentials are hardcoded in this image.
#
# Provisioning files (dashboards, datasources) are mounted at runtime via
# docker-compose volumes into /etc/grafana/provisioning.

EXPOSE 3000
