# 📂 scripts/ — Acervo de scripts reais

Esta pasta guarda **scripts de infraestrutura de verdade**, usados em produção e em aula pelo Prof. Daniel Santos. Eles servem a dois propósitos:

1. **Estudo de caso** — exemplos de Bash "de guerra", com centenas de linhas, tratamento de erro, logging e idempotência. Ótimos para ler *depois* do [Módulo 07](../modulos/07-scripts-robustos/).
2. **Reaproveitamento** — automações prontas para adaptar.

> ⚠️ **Leia antes de executar.** Estes scripts **alteram profundamente** o sistema (particionam DNS, reconfiguram rede, criam domínio Active Directory, instalam serviços). **Nunca** rode num computador pessoal ou servidor de produção sem ler. Use uma VM descartável com snapshot. São material avançado, não exercícios.

## Categorias

| Pasta | O que é |
|---|---|
| [`samba-ad/`](samba-ad/) | Provisiona um Controlador de Domínio **Samba Active Directory** com DHCP, OUs, usuários, grupos e script de logon. Duas variantes de DNS. |
| [`auditoria-rede/`](auditoria-rede/) | Script de **auditoria de segurança** de rede local e web (nmap, nikto, enum4linux…). Uso exclusivamente acadêmico e autorizado. |

---

## 🔎 Curadoria de versões (samba-ad)

Os scripts de Samba AD existiam em **18 arquivos** com nomes como `..._v27 - Copia (2).sh`. Depois de analisá-los um a um (backend de DNS, sistema-alvo, completude e avisos do ShellCheck), a conclusão foi:

- Havia **duas linhagens**:
  - uma linha **Ubuntu 24.04**, com ~14 versões iterativas (v20→v27), a maioria ainda **sem o provisionamento completo** do domínio — trabalho em evolução;
  - uma linha **Debian 13**, mais recente e **a mais completa**, com exatamente **os dois backends de DNS**.
- Por isso foram eleitos **2 finalistas** (linha Debian 13), um por backend:

| Finalista | Backend DNS | Quando escolher |
|---|---|---|
| [`samba-ad/samba-ad_dns-interno_debian13.sh`](samba-ad/samba-ad_dns-interno_debian13.sh) | **DNS interno do Samba** (`SAMBA_INTERNAL`) | Setup mais simples; domínio pequeno; não precisa de recursos avançados de DNS |
| [`samba-ad/samba-ad_bind9-dlz_debian13.sh`](samba-ad/samba-ad_bind9-dlz_debian13.sh) | **BIND9_DLZ** | Precisa de zonas DNS avançadas, views, integração com outros servidores DNS, split-horizon |

> 💡 **DNS interno vs. BIND9_DLZ** é a decisão clássica ao montar um Samba AD. O DNS interno "só funciona" e basta para a maioria. O BIND9_DLZ dá todo o poder do BIND (zonas, views, encaminhadores sofisticados) lendo os dados direto do diretório do Samba — ao custo de mais configuração.

### E o resto?

Todos os demais arquivos foram para [`samba-ad/_a-revisar-exclusao/`](samba-ad/_a-revisar-exclusao/). **Nada foi apagado** — ficam ali para você conferir com calma e então decidir a exclusão. Veja o [inventário comentado](samba-ad/_a-revisar-exclusao/README.md) de cada um.

<sub>© 2026 Prof. Daniel Santos · Scripts sob PolyForm Noncommercial (não comercial) · Veja o aviso de uso acima.</sub>
