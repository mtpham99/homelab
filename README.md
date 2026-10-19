# homelab

My homelab repository.

> [!NOTE]
> work in progress...

## Hardware

### Nodes

| Node    | CPU       | RAM                       | Disks                                           | NICs                                                                                               |
| ------- | --------- | ------------------------- | ----------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| `hci01` | i9-12900H | 96 GB SO-DIMM DDR5 (2×48) | WD SN850 1 TB M.2 <br>Samsung PM9A3 3.84 TB U.2 | Intel X710 2× 10G SFP+ <br>Intel I226-LM 2.5G (AMT)<br>Intel I226-V 2.5G <br>MediaTek MT7922 Wi-Fi |
| `hci02` | i9-12900H | 48 GB SO-DIMM DDR5 (1×48) | WD SN850 1 TB M.2 <br>Samsung PM9A3 3.84 TB U.2 | Intel X710 2× 10G SFP+ <br>Intel I226-LM 2.5G (AMT)<br>Intel I226-V 2.5G <br>MediaTek MT7922 Wi-Fi |
| `hci03` | i9-13900H | 48 GB SO-DIMM DDR5 (1×48) | WD SN850 1 TB M.2 <br>Samsung PM9A3 3.84 TB U.2 | Intel X710 2× 10G SFP+ <br>Intel I226-LM 2.5G (AMT)<br>Intel I226-V 2.5G <br>Intel AX210 Wi-Fi     |

### Network

| Device  | Model                    | Ports                     |
| ------- | ------------------------ | ------------------------- |
| `rtr01` | MikroTik hAP ax3         | 1× 2.5G · 4× 1G · Wi-Fi 6 |
| `sw01`  | MikroTik CRS309-1G-8S+IN | 8× 10G SFP+ · 1× 1G       |
| `fs105` | Netgear FS105            | 5× 100M                   |

## Resources

### Hardware

- [Minisforum MS-01](https://www.minisforum.com/products/minisforum-ms-01) — [ServeTheHome review](https://www.servethehome.com/minisforum-ms-01-review-the-10gbe-with-pcie-slot-mini-pc-intel/)
- [MikroTik hAP ax³](https://mikrotik.com/product/hap_ax3) — [manual](https://manual.mikrotik.com/hardware/hap-ax-3/) · [block diagram](https://cdn.mikrotik.com/web-assets/product_files/C53UiG5HPaxD2HPaxD_240530.png)
- [MikroTik CRS309-1G-8S+IN](https://mikrotik.com/product/crs309_1g_8s_in) — [manual](https://manual.mikrotik.com/hardware/crs309-1g-8s-plus-in/) · [block diagram](https://cdn.mikrotik.com/web-assets/product_files/CRS309-1G-8S_220900.png)
- [Netgear FS105](https://www.netgear.com/support/product/fs105)

### Nix / NixOS / Nixpkgs

**Documentation**

- [Nix language manual](https://nix.dev/manual/nix)
- [NixOS Wiki](https://wiki.nixos.org/wiki/NixOS_Wiki) — [NixOS manual](https://nixos.org/manual/nixos/unstable/) — [options search](https://search.nixos.org/options?channel=unstable)
- [Nixpkgs](https://github.com/NixOS/nixpkgs) — [manual](https://nixos.org/manual/nixpkgs/unstable/) — [package search](https://search.nixos.org/packages?channel=unstable)

**Modules & Community Projects**

- [disko](https://github.com/nix-community/disko) — declarative disk partitioning
- [nixos-anywhere](https://github.com/nix-community/nixos-anywhere) — installation over ssh
- [nixos-facter](https://github.com/nix-community/nixos-facter) — hardware detection and configuration

### Secrets Management

- [SOPS](https://github.com/getsops/sops) — [Terraform provider](https://github.com/carlpett/terraform-provider-sops) · [Ansible collection](https://docs.ansible.com/ansible/latest/collections/community/sops/index.html)
- [sops-nix](https://github.com/Mic92/sops-nix)

### Networking

- [RouterOS](https://manual.mikrotik.com/docs/introduction/) — [Terraform provider](https://github.com/terraform-routeros/terraform-provider-routeros) · [Ansible collection](https://docs.ansible.com/ansible/latest/collections/community/routeros/index.html)

### Platform & Infrastructure as Code

- [Incus](https://linuxcontainers.org/incus/docs/main/) — [Terraform provider](https://search.opentofu.org/provider/lxc/incus/latest)
- [OpenTofu](https://opentofu.org/docs/)
- [Ansible](https://docs.ansible.com/projects/ansible/latest/index.html)
- [cloud-init](https://docs.cloud-init.io/en/latest/index.html)

### Tooling & CI/CD

- [Codeberg CI](https://codeberg.org/actions/meta)
- [Forgejo Actions](https://forgejo.org/docs/latest/user/actions/overview/)
- [Betterleaks](https://github.com/betterleaks/betterleaks) — secrets scanning
- [treefmt](https://github.com/numtide/treefmt) — code formatting multiplexer
- [pre-commit](https://github.com/pre-commit/pre-commit) — pre-commit hooks management framework
