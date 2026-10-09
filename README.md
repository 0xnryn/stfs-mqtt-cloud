# stfs-mqtt-cloud
command to generate the post quantum password protected age key
```bash
age-keygen -pq | age -p -o key.age
```
command to generate the post quantum age key
```bash
age-keygen -pq
```
command to create or edit the secret
```bash
SOPS_AGE_KEY=$(age -d admin.age) sops secrets/stfs-mqtt-cloud.yaml
```
command to update keys with modified public keys
```bash
SOPS_AGE_KEY=$(age -d admin.age) sops updatekeys secrets/stfs-mqtt-cloud.yaml
```

nix build .#nixosConfigurations.stfs-mqtt-cloud.config.system.build.tarball

docker import result/tarball/*.tar.xz stfs-mqtt-cloud:latest

docker compose up -d

docker logs stfs-mqtt-cloud

docker exec -it stfs-mqtt-cloud /run/current-system/sw/bin/bash

echo "ey..." | base64 -d

