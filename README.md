<h1 id="header" align="center">
  <!-- Make sure that the image path is always valid, despite however stupid a repo restructure might be. -->
  <img src="https://github.com/NixOS/nixos-artwork/blob/c68a508b95baa0fcd99117f2da2a0f66eb208bbf/logo/nix-snowflake-colours.svg" width="96px" height="96px" />
  <br>
  Nýx
</h1>

<div align="center">
   My over-engineered NixOS flake: Desktops, laptops, servers and everything
   else that can run an OS.<br/>
</div>

<div align="center">
  <br/>
  <a href="#high-level-overview">Overview</a> | <a href="#host-specifications">Hosts</a> | <a href="#credits--special-thanks-to">Credits</a> | <a href="#license">License</a><br/>
  <!-- lmao. I should make this less obvious-->
  <a href="https://www.youtube.com/watch?v=xvFZjo5PgG0">Installation</a>
  <br/>
</div>

<p id="preview" align="center">
  <br/>
  <img src=".github/assets/desktop_preview_wide.png" alt="Desktop Preview" />
  <br/>
  Screenshot last updated <b>2024-03-19</b>
</p>

## High Level Overview

This is a high level overview of this monorepo, containing configurations for
**all** of my machines that are currently running NixOS, or have ran NixOS at
some point in time. You will find below a list of my hosts and their
specifications, accompanied by a somewhat maintained list of features of this
configuration and my design considerations.

### Disclaimer

As I physically cannot stop tinkering with my configuration, nothing in this
repository (including the overview sections) should be considered final. As
such, it is **not recommended to be used as a template (nor is designed to be
one)** but you are welcome to browse the codebase to your liking, you may find
bits that are interesting or/and useful to you.

Do keep in mind that I make no promise of stability or support. If something
breaks, that will be your responsibility. Please do not allow yourself to be
fooled by the sheer amount of documentation effort that has gone into this
project. It is not a public framework, never will be. It will receive changes,
on almost a daily basis and possibly in a half-broken state.

<!-- deno-fmt-ignore-start -->

> [!CAUTION]
> Almost all of the configurations contained within this repository,
> in some shape or form, contain age encrypted secrets - which, to you dear
> reader, means that they **cannot** be built and replicated successfully, at
> least in theory. I invite you to go through the modules and countless lines of
> Nix I have written, but I would strongly advise against attempting to boot any
> of those configurations unless you are me. You should also note that
> this is **not** a community framework.

<!-- deno-fmt-ignore-end -->

Before you proceed, I would like to point you towards the [credits](#credits)
section below where I pay tribute to the individuals who have contributed to
this project, whether through code reference, suggestions, bug reports, or
simply moral support. They have my most sincere thanks.

### Repo Structure

[flake schemas]: https://determinate.systems/posts/flake-schemas
[Home-Manager]: https://github.com/nix-community/home-manager

- [flake.nix](flake.nix) Ground zero of my system configuration. Declaring
  entrypoints
- [docs](docs)The documentation for my flake repository
  - [notes](docs/notes) Notes from tedious or/and under-documented processes I
    have gone through. More or less a blog
  - [cheatsheet](docs/notes/cheatsheet.md) Useful tips that are hard to
    memorize, but easy to write down
- [flake/](flake) Individual parts of my flake, powered by flake-parts
  - [lib](flake/lib) Personal library of functions and utilities
  - [apps](flake/apps) Basic executables for maintenance jobs
  - [checks](flake/checks) Additional checks to build on `nix flake check`
  - [lib](flake/lib) Personal library of functions and utilities
  - [modules](flake/modules) Modules provided by my flake for both internal and
    public use
  - [npins](flake/npins) Additional pinned dependencies, managed via `npins`
  - [pkgs](flake/pkgs) Packages exported by my flake
  - [pre-commit](flake/pre-commit) pre-commit hooks via `git-hooks.nix`
  - [templates](flake/templates) Templates for initializing new flakes. Provides
    some language-specific flakes
  - [args.nix](flake/args.nix) Args that will be shared across, or exposed by
    the flake
  - [deployments.nix](flake/deployments.nix) Host setups for deploy-rs,
    currently a work in progress
  - [fmt.nix](flake/fmt.nix) Various formatting options for `nix fmt` and
    friends
  - [iso-images.nix](flake/iso-images.nix) Configurations for my home-built iso
    images, to be exposed in the flake schema
  - [keys.nix](flake/keys.nix) My public keys to be shared across the flake
  - [shell.nix](flake/shell.nix) Local devShell configurations
- [homes](homes) My personalized [Home-Manager] configurations.
- [hosts](hosts) Per-host configurations that contain machine specific
  instructions and setups
- [modules](modules) Modularized NixOS configurations
  - [core](modules/core) The core module that all systems depend on
    - [common](modules/core/common) Module configurations shared between all
      hosts (except installers)
    - [profiles](modules/core/profiles) Pluggable internal module system, for
      providing overrides based on host declarations (e.g. purpose)
    - [roles](modules/core/roles) A profile-like system that work through
      imports and ship predefined configurations
  - [extra](modules/extra) Extra modules that are rarely imported
    - [shared](modules/extra/shared) Modules that are both shared for outside
      consumption, and imported by the flake itself
    - [exported](modules/extra/exported) Modules that are strictly for outside
      consumption and are not imported by the flake itself
  - [options](modules/options) Definitions of module options used by common
    modules
    - [meta](modules/options/meta) Internal, read-only module that defines host
      capabilities based on other options
    - [device](modules/options/device) Hardware capabilities of the host
    - [documentation](modules/options/docs) Local module system documentation
    - [system](modules/options/system) OS-wide configurations for generic
      software and firmware on system level
    - [theme](modules/options/theme) Active theme configurations ranging from QT
      theme to shell colors
    - [usrEnv](modules/options/usrEnv) userspace exclusive configurations. E.g.
      lockscreen or package sets
- [secrets](secrets) Agenix secrets

### Notable Features

[theme options]: modules/options/theme
[profiles]: modules/core/profiles
[wallpkgs]: https://github.com/notashelf/wallpkgs
[flake-parts]: https://flake.parts
[impermanence]: https://github.com/nix-community/impermanence

- **All-in-one** - Servers, desktops, laptops, virtual machines and anything you
  can think of. Managed in one place.
  - **Sane Defaults** - The modules attempt to bring the most sane defaults,
    while providing per-host toggles for conflicting choices.
  - **Flexible Modules** - Both Home-manager and NixOS modules allow users to
    retrieve NixOS or home-manager configurations from anywhere.
  - **Extensive Configuration** - Most desktop programs are configured out of
    the box and shared across hosts, with override options for per-host
    controls.
  - **Custom extended library** - An extended library for functions that help
    organize my system.
- **Shared Configurations** - Reduces re-used boilerplate code by sharing
  modules and profiles across hosts.
- **Fully Modular** - Utilizes NixOS' module system to avoid hard-coding any of
  the options.
  - **Profiles & Roles** - Provide serialized configuration sets and pluggables
    for easily changing large portions of configurations with less options and
    minimal imports.
  - **Detached Homes** - Home-manager configurations are able to be detached for
    non-NixOS usage.
  - **Modularized Flake Design** - With the help of [flake-parts], the flake is
    fully modular: keeping my `flake.nix` cleaner than ever.
  - **Declarative Themes** - Using my [theme options], [profiles] and
    [wallpkgs]. Everything theming is handled inside the flake.
  - **Tree-wide formatting** - Format files in any language with the help of
    devshells and treefmt-nix modules for flake-parts.
- **Declarative nftables firewall** - Flexible and over-engineered[^1]
  `nftables` table/chain builder abstraction for easy firewall setups.
- **Personal Installation Media** - Personalized ISO images for system
  installation and recovery.
- **Secrets Management** - Manage secrets through Agenix.
- **Opt-in Impermanence** - On-demand ephemeral root using BTRFS rollbacks and
  [impermanence].
- **Encryption Ready** - Supports and actively utilizes full disk encryption.
- **Wayland First** - Leaves Xorg in the past where it belongs. Everything is
  configured around Wayland, with Xorg only as a fallback.

### Rules/Design Considerations

Most of those rules, so to speak, are quite obvious. However they are noted down
as a favor to potential contributors, and to potential observers who wish to
make sense of certain decisions that are made.

<!-- deno-fmt-ignore-start -->

> [!NOTE]
> Host specific design considerations will be in
> [`hosts/README.md`](hosts/README.md)

<!-- deno-fmt-ignore-end -->

- A commit should always be scoped. For example, while modifying a file in
  `hosts/enyo`, the commit would begin with `hosts/enyo:` followed by the
  description of the change.
- **alejandra** is the only Nix formatter that shall be used within this
  repository. nixfmt and nixpkgs-fmt both advertise ugly and confusing diffs,
  which I dislike. Some of alejandra's quirks (e.g. lists) can be avoided with
  minor additions to the code.
- Backwards imports **should** be avoided wherever applicable.
- The repository should remain modular, and enabled options must **never**
  create inconsistencies or incompatibilities between hosts. In case of an
  unavoidable incompatibility, the issue must be documented. If possible,
  trigger conditions for incompatibilities must be avoided via assertions.
- Host-exclusive condition must **always** be placed in the host's own
  directory. Hosts **must** advertise their capabilities and features in
  `hosts/<hostname>/modules`
- `with lib;` **must** be avoided at all costs. Same goes for `with builtins;`
  which follows the same confusing pattern as `with lib;`. In some cases, `with`
  scopes may be accepted but only on the condition that the scope is narrow.
  - While accessing standard library functions, the call to library must be
    explicit. An example to this would be: `inherit (lib.modules) mkIf;` instead
    of repeating `lib.mkIf` or `lib.modules.mkIf` every time it is used.

### Goals/Non-goals

#### Goals

I have a bunch of goals that I wish to accomplish by, and while working on this
repository. Those goals are:

- Provide _everything_ - we would like to provide modules, packages, system and
  home configurations all in one place
- Modularity - we would like to _never_ compromise on modularity, and two hosts
  of different purposes must _never_ conflict.
- Purity - `--impure` flag is a no-go.
- Documentation - anything that has been done should be documented. Best-effort
  not guaranteed.

#### Non-goals

- Full reproducibility - we contain secrets, therefore the setup is not fully
  reproducible.
- Replicability - this configuration does not aim to, and will not serve as a
  framework. I make no guarantees of replicability.
- Support - take a wild guess.
- Stability - see above.

## Host Specifications

| Name         | Description                                                                                       |  Type   |     Arch      |
| :----------- | :------------------------------------------------------------------------------------------------ | :-----: | :-----------: |
| `enyo`       | Day-to-day desktop workstation boasting a full AMD system.                                        | Desktop | x86_64-linux  |
| `prometheus` | HP Pavilion with a a GTX 1050 and i7-7700hq                                                       | Laptop  | x86_64-linux  |
| `epimetheus` | Twin of prometheus, features full disk encryption in addition to everything prometheus provides   | Laptop  | x86_64-linux  |
| `hermes`     | HP Pavilion with a Ryzen 7 7730U, and my main portable workstation. Used on-the-go                | Laptop  | x86_64-linux  |
| `icarus`     | My 2014 Lenovo Yoga Ideapad that acts as a portable server, used for testing hardware limitations | Laptop  | x86_64-linux  |
| `helios`     | Hetzner Cloud VPS for non-critical infrastructure                                                 | Server  | x86_64-linux  |
| `selene`     | Alternative Hetzner Cloud VPS to be used as an aarch64-linux builder                              | Server  | aarch64-linux |
| `atlas`      | Proof of concept server host that is used by my Raspberry Pi 400                                  | Server  | aarch64-linux |
| `artemis`    | VM host for testing basic NixOS concepts. Previously targeted aarch64-linux                       |   VM    | x86_64-linux  |
| `apollon`    | VM host for testing networked services, generally used on servers                                 |   VM    | x86_64-linux  |
| `leto`       | VM host running medium-priority infrastructure inside a virtualized root server                   |   VM    | x86_64-linux  |
| `gaea`       | Custom live media, used as an installer                                                           |   ISO   | x86_64-linux  |
| `erebus`     | Air-gapped virtual machine/live-iso configuration for sensitive jobs                              |   ISO   | x86_64-linux  |

## Credits & Special Thanks to

[atrocious abstractions]: flake/lib/builders.nix

My special thanks go to [fufexan](https://github.com/fufexan) for convincing me
to use NixOS and sticking around to answer my most stupid and deranged
questions, as well as my [atrocious abstractions].

And to [sioodmy](https://github.com/sioodmy) which my configuration is initially
based on. The simplicity of his configuration flake allowed me to take a
foothold in the Nix world.

### Awesome People

I got inspired by, and owe a lot to those folks

[sioodmy](https://github.com/sioodmy) - [fufexan](https://github.com/fufexan) -
[NobbZ](https://github.com/NobbZ) - [ViperML](https://github.com/viperML) -
[spikespaz](https://github.com/spikespaz) -
[hlissner](https://github.com/hlissner) -
[Max Headroom](https://github.com/max-privatevoid)

... and surely there are more, but I tend to forget. Nevertheless, I extend my
thanks to all of those people and any others that I might have forgotten.

### Anti-credits

Pretend I haven't credited those people (but I will, because they are equally
awesome and I appreciate them)

[vaxry](https://github.com/vaxerski) -
[gerg-l (bald frog)](https://github.com/gerg-l) -
[eclairevoyant](https://github.com/eclairevoyant/) -
[FrothyMarrow](https://github.com/frothymarrow) -
[adamcstephens](https://github.com/adamcstephens) -
[nrabulinski](https://github.com/nrabulinski) -
[n3oney](https://github.com/n3oney) -
[Raidenovich](https://github.com/raidenovich) -
[jacekpoz](https://github.com/jacekpoz) -
[Vagahbond](https://github.com/Vagahbond)

### Honorable Mentions

Some of the cool people I have interacted with in the past and believe deserve a
shoutout for their support or companionship. I appreciate you all. :)

[fsnkty](https://github.com/fsnkty) - [lychee](https://github.com/itslychee) -
[germanbread](https://github.com/GermanBread)

## Cool Resources

Resource that helped shape and improve this configuration, or resources that I
strongly recommend that you read in no particular order.

### Interactive Pages

- [A list of Nix library functions and builtins](https://teu5us.github.io/nix-lib.html)
- [Noogle](https://noogle.dev)
- [NixOS package search](https://search.nixos.org/packages)
- [NixOS option search](https://search.nixos.org/options?)
- [Tour of Nix](https://nixcloud.io/tour/?id=introduction/nix)

### Readings

- [Zero to Nix](https://zero-to-nix.com/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)
- [Xe Iaso's blog](https://xeiaso.net/blog)
- [Vinícius Müller's Blog](https://viniciusmuller.github.io) (no longer exists)
- [Viper's Blog](https://ayats.org/)
- [Solène's Blog](https://dataswamp.org/~solene)
- [...my own "blog"?](https://notashelf.github.io/nyx/)

### Software

Software that helped this configuration become what it is, or software I find
interesting

**Linux**

- [Hyprland](https://github.com/hyprwm/Hyprland)
- [ags](https://github.com/aylur/ags)

**Nix/NixOS**

- [nix-super](https://github.com/privatevoid-net/nix-super)
- [Agenix](https://github.com/ryantm/agenix)
- [nh](https://github.com/viperML/nh)

Projects I have made to use in this repository, or otherwise cool software that
are used in this repository that I would like to endorse.

- [nyxpkgs](https://github.com/notashelf/nyxpkgs) - my personal package
  collection
- [nvf](https://github.com/notashelf/nvf) - highly modular Neovim configuration
  framework for Nix/NixOS
- [schizofox](https://github.com/schizofox/schizofox) - hardened Firefox
  configuration for the delusional and the paranoid
- [ndg](https://github.com/feel-co/ndg) - a module documentation framework for
  Nix projects.

Additionally, take a look at my [notes/blog](docs/notes) for my notes on Linux,
and specifically challenging or tedious processes on Nix and NixOS. It is also
available [as a webpage](https://nyx.notashelf.dev)

## License

Unless explicitly stated otherwise, all code under this repository (except for
[anything in docs directory](docs)) is licensed under the [GPLv3](LICENSE), or
should you prefer, under any later version of the GPL released by the FSF.

The notes and documentation available in [docs directory](docs) is licensed
under the [CC BY License](docs/LICENSE).

<!-- deno-fmt-ignore-start -->

> [!NOTE]
> All code here (excluding secrets) are available for your convenience
> and _at my expense_ as I choose to keep my entire system configuration public.
> I believe it is in Nix and NixOS community spirit to learn from and share code
> with other NixOS users. As such if you are directly copying a section of my
> configuration, please include a copyright notice at the top of the file you
> import the code, or as a small comment above the section you have copied.

<!-- deno-fmt-ignore-end -->

It is not in any shape or form enforced, but your kindness and due diligence
would be highly appreciated. Please do not be one of the people who upstream my
commits without any consideration to my time and efforts.

---

<h2 align="center">Preview</h2>

<p id="preview" align="center">
   <img src=".github/assets/desktop_preview.png" width="640" alt="Desktop Preview" />
</p>
<p align="center">
   Screenshot last updated <b>2023-12-09</b>
</p>

<div align="right">
  <a href="#readme">Back to the Top</a>
</div>

[^1]:
    I speak of "over-engineering" not as a flaw, but as a trait that can properly
    describe the time and effort that this repository has taken. After 700+ recorded
    hours and 4000+ commits, that is the only word that can describe this project.
