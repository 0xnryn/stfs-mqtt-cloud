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
cloudflared.exe service install eyJhIjoiMWNiMWU3NWUxNWViNGViYzA0YWI4ZTg3Y2I3ZTY1ZTAiLCJ0IjoiNzZlM2I3NmMtMTllZi00ZDNmLWJlZWYtZjQ0MWVlM2FjZTYxIiwicyI6Ik5HSXdPV1ZqWXpRdFltWTRZeTAwT1RSakxUaGtaV0V0TTJKaU1UTmhPV05tWkRReSJ9