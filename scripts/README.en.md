# 📂 scripts/ — Collection of real scripts

**🌍 Idioma / Language:** [Português](README.md) · **English**

This folder holds **real infrastructure scripts**, used in production and in class by Prof. Daniel Santos. They serve two purposes:

1. **Case studies** — "battle-tested" Bash examples, with hundreds of lines, error handling, logging, and idempotency. Great to read *after* [Module 07](../modulos/07-scripts-robustos/README.en.md).
2. **Reuse** — ready-made automations to adapt.

> ⚠️ **Read before running.** These scripts **deeply change** the system (they partition DNS, reconfigure the network, create an Active Directory domain, install services). **Never** run them on a personal computer or production server without reading. Use a disposable VM with a snapshot. They're advanced material, not exercises.

## Categories

| Folder | What it is |
|---|---|
| [`samba-ad/`](samba-ad/) | Provisions a **Samba Active Directory** Domain Controller with DHCP, OUs, users, groups, and a logon script. Two DNS variants. |
| [`auditoria-rede/`](auditoria-rede/) | A local-network and web **security audit** script (nmap, nikto, enum4linux…). Strictly academic and authorized use only. |

---

## 🔎 Version curation (samba-ad)

The Samba AD scripts existed as **18 files** with names like `..._v27 - Copia (2).sh`. After analyzing them one by one (DNS backend, target system, completeness, and ShellCheck warnings), the conclusion was:

- There were **two lineages**:
  - an **Ubuntu 24.04** line, with ~14 iterative versions (v20→v27), most still **without the full** domain provisioning — work in progress;
  - a **Debian 13** line, more recent and **the most complete**, with exactly **the two DNS backends**.
- So **2 finalists** were chosen (the Debian 13 line), one per backend:

| Finalist | DNS backend | When to choose |
|---|---|---|
| [`samba-ad/samba-ad_dns-interno_debian13.sh`](samba-ad/samba-ad_dns-interno_debian13.sh) | **Samba internal DNS** (`SAMBA_INTERNAL`) | Simpler setup; small domain; no advanced DNS features needed |
| [`samba-ad/samba-ad_bind9-dlz_debian13.sh`](samba-ad/samba-ad_bind9-dlz_debian13.sh) | **BIND9_DLZ** | You need advanced DNS zones, views, integration with other DNS servers, split-horizon |

> 💡 **Internal DNS vs. BIND9_DLZ** is the classic decision when setting up a Samba AD. The internal DNS "just works" and is enough for most. BIND9_DLZ gives you all of BIND's power (zones, views, sophisticated forwarders) reading the data straight from the Samba directory — at the cost of more configuration.

### And the rest?

All the other files went to [`samba-ad/_a-revisar-exclusao/`](samba-ad/_a-revisar-exclusao/README.en.md). **Nothing was deleted** — they're there for you to review at your leisure and then decide on removal. See the [commented inventory](samba-ad/_a-revisar-exclusao/README.en.md) of each one.

<sub>© 2026 Prof. Daniel Santos and translators · Scripts under PolyForm Noncommercial (noncommercial) · See the usage notice above.</sub>
