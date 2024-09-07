#!/bin/bash

apt-get update
apt-get install -y wget unzip

wget https://releases.hashicorp.com/vault/${vault_version}/vault_${vault_version}_linux_amd64.zip
unzip vault_${vault_version}_linux_amd64.zip
mv vault /usr/local/bin/

mkdir -p /opt/vault/data

cat <<EOF > /opt/vault/config.hcl
storage "raft" {
  path    = "/opt/vault/data"

  retry_join {
    leader_api_addr = "${leader_api_addr}"
  }
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

api_addr = "${api_addr}"
cluster_addr = "${cluster_addr}"
disable_mlock = true
ui = true
EOF

useradd --system --home /opt/vault --shell /bin/false vault

cat <<EOF > /etc/systemd/system/vault.service
[Unit]
Description=HashiCorp Vault - A tool for managing secrets
Documentation=https://www.vaultproject.io/docs/
After=network-online.target
Wants=network-online.target

[Service]
User=vault
Group=vault
ExecStart=/usr/local/bin/vault server -config=/opt/vault/config.hcl
ExecReload=/bin/kill --signal HUP \$MAINPID
LimitNOFILE=65536
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

chown vault:vault -R /opt/vault

systemctl daemon-reload
systemctl enable vault
systemctl start vault
