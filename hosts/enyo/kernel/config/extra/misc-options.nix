{lib, ...}: let
  inherit (lib.kernel) yes no freeform;
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.modules) mkForce;
in {
  boot.kernelPatches = [
    {
      name = "misc";
      patch = null;
      extraStructuredConfig = mapAttrs (_: mkForce) {
        # https://github.com/CachyOS/linux-cachyos/blob/master/linux-cachyos-bore/config cachyos config for reference.
        # https://github.com/CachyOS/linux-cachyos/blob/master/linux-cachyos-hardened/config cachyos hardened.
        # https://github.com/xanmod/linux/blob/6.9/CONFIGS/xanmod/gcc/config_x86-64-v3 xanmod git kernel config.

        ### Misc
        # Specify the maximum amount of allowable watchdog skew in microseconds before reporting the clocksource to be unstable.
        # 125 in nixos xanmod. Xanmod git set it at 100. Cachyos doing same.
        # Conficted about this one.
        CLOCKSOURCE_WATCHDOG_MAX_SKEW_US = "100";

        MEMORY_HOTPLUG_DEFAULT_ONLINE = yes; #https://cateee.net/lkddb/web-lkddb/MEMORY_HOTPLUG_DEFAULT_ONLINE.html. Enabled in cachy + xanmod git.
        ANON_VMA_NAME = yes; # https://cateee.net/lkddb/web-lkddb/ANON_VMA_NAME.html For debuging purposes looks like. Enabled in cachy and xanmod git
        IOMMU_MM_DATA = yes; # not much information about this one. Probably related to emulation AMD-Vi + INTEL-VT. Enabled in cachyos hardened and xanmod git

        # what is this? It was set to 6 in my case. CachyOS using 5. Xanmod set at 10.
        NODES_SHIFT = "10";

        # Define the padding in terabytes added to the existing physical memory size during kernel memory randomization. It is useful for memory hotplug support but reduces the entropy available for address randomization.
        # If unsure, leave at the default value.
        RANDOMIZE_MEMORY_PHYSICAL_PADDING = "0xa"; #Conflicted about this one. In xanmod github it's 0xa ( default value I believe ), in nixos xanmod it's 0x1. CachyOS hardening and normal version also use "0xa"

        # Network
        # Have no clue about network stuff.
        XFRM_STATISTICS = yes;
        # IPV6 stuff
        IPV6_SIT_6RD = yes; #support for rapid deployment.
        IPV6_IOAM6_LWTUNNEL = yes; # IOAM (In-situ Operations, Administration, and Maintenance).
        # IPV4
        IP_FIB_TRIE_STATS = yes; # https://cateee.net/lkddb/web-lkddb/IP_FIB_TRIE_STATS.html
        NET_IPGRE_BROADCAST = yes; # no clue what it is.
        TCP_AO = yes; # network/security. TCP auth option. https://www.phoronix.com/news/TCP-AO-Linux-Kernel-Updated  Specs:https://datatracker.ietf.org/doc/html/rfc5925

        # RCU Debugging
        # RCU_CPU_STALL_TIMEOUT = "60"; #xanmod github and cachyos use 60
        # RCU_CPU_STALL_CPUTIME = yes; # enabled in xanmod github. Cachyos and nix xanmod disable this.

        # Linear Address Masking (LAM): modifies the checking that is applied to 64-bit linear addresses, allowing software to use of the untranslated address bits for metadata.
        # The capability can be used for efficient address sanitizers (ASAN) implementation and for optimizations in JITs.
        ADDRESS_MASKING = yes;

        ## General architecture-dependent options
        ARCH_HAS_CPU_PASID = yes; #enabled in xanmod git + cachyos. Also enabled in hardened kernel.
        # https://www.phoronix.com/news/AMD-IOMMU-SVA-Nears probably related.

        # KVM
        # Some parts of KVM enabled as module, some parts ( like below ) don't even added in kernel config at all?
        KVM_GENERIC_MEMORY_ATTRIBUTES = yes; # In linux kernel since version 6.8. Enabled in xanmod github. Can't even find this option in cachyos kernels?
        KVM_PRIVATE_MEM = yes; # same as above https://www.kernelconfig.io/CONFIG_KVM_PRIVATE_MEM?q=KVM_PRIVATE_MEM&kernelversion=6.9.7&arch=x86
        KVM_GENERIC_PRIVATE_MEM = yes; # same as above
        KVM_SW_PROTECTED_VM = yes; # same as above
        # KVM_XEN = yes; # if xen required.
        KVM_MAX_NR_VCPUS = "4096"; # cachyos set this at 1024, like NixOS kernel. Xanmod github use 4096, because CONFIG_MAXSMP=y also enabled in xanmod github.
        # https://lore.kernel.org/lkml/ZN6w2SxyZMKKxtb%2F@google.com/T/

        ##
        # This allows you to specify the maximum number of CPUs which this
        # kernel will support. If CPUMASK_OFFSTACK is enabled, the maximum
        # supported value is 8192, otherwise the maximum value is 512. The
        # minimum value which makes sense is 2.

        # This is purely to save memory: each supported CPU adds about 8KB
        # to the kernel image.
        # CPUMASK_OFFSTACK = yes;
        # NR_CPUS = "";
      };
    }
  ];
}
