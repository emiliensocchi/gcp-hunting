
# Scanning public IPs assigned to Compute instances

Series of commands used to nmap-scan a set of public IPs associated with Compute instances.

## Scan with nmap

```shell
nmap -vv -iL targets.list -oA scan-all-hosts -T4 --min-rate 500 --max-retries 2 -p- -Pn -sV -sC -O
```

## Get an overview of the ports that have been analyzed (in  any state)

```shell
docker run -d --name webmap -h webmap -p 8000:8000 -v <PATH_TO_NMAP_DIR>:/opt/xml reborntc/webmap
```

## Filter out the greppable nmap output for IPs with specific open ports

### Note: do it based on the result from the last step

```shell
cat scan-all-hosts.gnmap | awk '/<PORT_NUMBER>\/open/{print $2}'
```

### Example

```shell
cat scan-all-hosts.gnmap | awk '/22\/open/{print $2}'
```
