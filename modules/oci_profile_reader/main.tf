locals {
  cflines      = split("\n", file(pathexpand("~/.oci/config")))
  ocipf        = [for line in local.cflines : flatten(regexall("\\[([\\w]+)\\]", line))]
  ociln        = compact([for i in range(length(local.ocipf)) : length(local.ocipf[i]) > 0 ? i : ""])
  ocilns       = { for i in range(length(local.ociln)) : element(local.ocipf, local.ociln[i])[0] => slice(local.cflines, local.ociln[i] + 1, length(local.ociln) > i + 1 ? local.ociln[i + 1] : length(local.cflines)) }
  oci_profiles = { for k, v in local.ocilns : k => { for line in compact(v) : flatten(regexall("(\\w+)=(.+)$", line))[0] => flatten(regexall("(\\w+)=(.+)$", line))[1] } }
}
