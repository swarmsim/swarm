#provider "aws" {
#  region = "us-east-1"
#}
provider "cloudflare" {}

terraform {
  backend "s3" {
    bucket = "terraform-backend.swarmsim.com"
    key    = "swarmsim.com"
    region = "us-east-1"
  }
}

# To import:
#
# * copy zone id from https://dash.cloudflare.com/fed1bc67ffb2f62c6deaa5c7f8f9eb93/swarmsim.com
#   here, it's 2526e11...
#
# * sh -c '. ~/.cloudflare.env && curl https://api.cloudflare.com/client/v4/zones/2526e11f0b20a0e69b0fcfb1e5a21d21/dns_records -H "X-Auth-Email: $CLOUDFLARE_EMAIL"  -H "X-Auth-Key: $CLOUDFLARE_TOKEN" -H "Content-Type: application/json"' > import_dns_records
#
# * for each dns record, replace `cloudflare_record.XXXXXX` and `.name=="XXXXXXXXX"`:
#   sh -c 'set -a && . ~/.cloudflare.env && set +a && terraform import cloudflare_record.preprod_swarmsim_com swarmsim.com/`cat import_dns_records | jq -r \'.result | .[] | select(.name=="preprod.swarmsim.com") | .id\'`'
resource "cloudflare_record" "www_swarmsim_com" {
  domain  = "swarmsim.com"
  name    = "www"
  type    = "CNAME"
  value   = "swarmsim-dotcom.github.io"
  proxied = true
}

resource "cloudflare_record" "coffee_swarmsim_com" {
  domain  = "swarmsim.com"
  name    = "coffee"
  type    = "CNAME"
  value   = "swarmsim-coffee.github.io"
  proxied = true
}

resource "cloudflare_record" "preprod_swarmsim_com" {
  domain  = "swarmsim.com"
  name    = "preprod"
  type    = "CNAME"
  value   = "swarmsim-preprod.github.io"
  proxied = true
}

resource "cloudflare_record" "beta_swarmsim_com" {
  domain  = "swarmsim.com"
  name    = "beta"
  type    = "CNAME"
  value   = "swarmsim-publictest.github.io"
  proxied = true
}

resource "cloudflare_record" "staging_swarmsim_com" {
  domain  = "swarmsim.com"
  name    = "staging"
  type    = "CNAME"
  value   = "swarmsim-staging.github.io"
  proxied = true
}

# root ips from https://help.github.com/articles/setting-up-an-apex-domain/
# TODO: change this to a CNAME, since cloudflare supports root cnames (cname flattening).
resource "cloudflare_record" "swarmsim_com_A01" {
  domain  = "swarmsim.com"
  name    = "swarmsim.com"
  type    = "A"
  value   = "192.30.252.153"
  proxied = true
}

resource "cloudflare_record" "swarmsim_com_A02" {
  domain  = "swarmsim.com"
  name    = "swarmsim.com"
  type    = "A"
  value   = "192.30.252.154"
  proxied = true
}

# Site verification.
resource "cloudflare_record" "verify_keybase" {
  domain = "swarmsim.com"
  name   = "swarmsim.com"
  type   = "TXT"
  value  = "keybase-site-verification=6395O2FZ_laPKmseNXoS6K8_EH6ksLiSbZgHRTmB-HI"
}

resource "cloudflare_record" "verify_google" {
  domain = "swarmsim.com"
  name   = "swarmsim.com"
  type   = "TXT"
  value  = "google-site-verification=huueYzqrM57YM5ogbWfTfrgxMPOtLuwIBf6l82rGrjE"
}

# Nameservers
resource "cloudflare_record" "ns1" {
  domain = "swarmsim.com"
  name   = "ns.phx3.nearlyfreespeech.net"
  type   = "NS"
  value  = "ns.phx1.nearlyfreespeech.net"
}

resource "cloudflare_record" "ns2" {
  domain = "swarmsim.com"
  name   = "ns.phx5.nearlyfreespeech.net"
  type   = "NS"
  value  = "ns.phx1.nearlyfreespeech.net"
}

# mail.
resource "cloudflare_record" "mail_swarmsim_com" {
  domain = "swarmsim.com"
  name   = "mail"
  type   = "CNAME"
  value  = "ghs.google.com"
}

resource "cloudflare_record" "swarmsim_com_mx_1" {
  domain   = "swarmsim.com"
  name     = "swarmsim.com"
  type     = "MX"
  value    = "alt1.aspmx.l.google.com"
  priority = "5"
}

resource "cloudflare_record" "swarmsim_com_mx_2" {
  domain   = "swarmsim.com"
  name     = "swarmsim.com"
  type     = "MX"
  value    = "alt2.aspmx.l.google.com"
  priority = "5"
}

resource "cloudflare_record" "swarmsim_com_mx_3" {
  domain   = "swarmsim.com"
  name     = "swarmsim.com"
  type     = "MX"
  value    = "alt3.aspmx.l.google.com"
  priority = "10"
}

resource "cloudflare_record" "swarmsim_com_mx_4" {
  domain   = "swarmsim.com"
  name     = "swarmsim.com"
  type     = "MX"
  value    = "alt4.aspmx.l.google.com"
  priority = "10"
}

resource "cloudflare_record" "swarmsim_com_mx_5" {
  domain   = "swarmsim.com"
  name     = "swarmsim.com"
  type     = "MX"
  value    = "aspmx.l.google.com"
  priority = "1"
}

resource "cloudflare_record" "swarmsim_com_spf" {
  domain = "swarmsim.com"
  name   = "swarmsim.com"
  type   = "TXT"
  value  = "v=spf1 include:_spf.google.com ~all"
}

resource "cloudflare_record" "swarmsim_com_dkim" {
  domain = "swarmsim.com"
  name   = "google._domainkey"
  type   = "TXT"
  value  = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAgsAWn+X5jNHTPO6UayRLqFsSmzF5WmSh1Ov0bIUAu9JubTLcoUtX2a4yvdHj7PEGwGJ+ZpM7ja2f/emHY3yrBGDr3CrlM4DLOuwKmW0LrL8499FChnsgx7s3JhI5ln3+zgen+e0y7l6bM/bu40oiIkoxCSTyesoZ1aSO3bi4sOv7cxOcpvMgDHDHPQwt5dMlxYq4dmu/fco6RCl7EFhtUmCkpXLgDBigBCmTclKcXYOpLxxzd8npc83aLg+VPVWS0CfnahWgby1RcpFQ8H5ihtE/FGX+TNoxClVgy23v+lvkmIj9wszRi/msPL6hdVRSFp2O4kfETYPIw805mb+uGQIDAQAB"
}
