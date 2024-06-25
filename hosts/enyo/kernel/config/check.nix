{lib, ...}: let
  inherit (lib.kernel) no unset;
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.modules) mkForce;
in {
  boot.kernelPatches = [
    {
      name = "x86_64-v3";
      patch = null;
      extraStructuredConfig = mapAttrs (_: mkForce) {
        #Security.
        # Reason to enable it: https://lore.kernel.org/lkml/20180109180429.1115005-1-ast@kernel.org/
        # In short: "To make attacker job harder introduce BPF_JIT_ALWAYS_ON config
        # option that removes interpreter from the kernel in favor of JIT-only mode.
        # So far eBPF JIT is supported by:
        # x64, arm64, arm32, sparc64, s390, powerpc64, mips64"

        # It was enabled in xanmod git kernel, but disabled in nixos xanmod.
        # Wine use BPF. Need to check if this affect performance somehow.
        BPF_JIT_ALWAYS_ON = yes;

        #Performance/Security
        #If set, pressure stall information tracking will be disabled per default but can be enabled through passing psi=1 on the kernel commandline during boot.
        #This feature adds some code to the task wakeup and sleep paths of the scheduler. The overhead is too low to affect common scheduling-intense workloads in practice (such as webservers, memcache),
        #but it does show up in artificial scheduler stress tests, such as hackbench.
        #If you are paranoid and not sure what the kernel will be used for, say Y.
        #Say N if unsure.
        # nixos xanmod default was: CONFIG_PSI=y
        PSI_DEFAULT_DISABLED = yes;

        #Security. Debug
        #Linear Address Masking (LAM) modifies the checking that is applied to 64-bit linear addresses, allowing software to use of the untranslated address bits for metadata.
        #The capability can be used for efficient address sanitizers (ASAN) implementation and for optimizations in JITs.
        ADDRESS_MASKING = yes;

        #TOMOYO.Disabled in kernel completly.
        #Render boot params like LSM:....,tomoyo useless.
        # Arch wiki:https://wiki.archlinux.org/title/TOMOYO_Linux#Installation_2 suggest this to enable
        # "CONFIG_SECURITY=y
        #CONFIG_SECURITYFS=y
        #CONFIG_SECURITY_NETWORK=y
        #CONFIG_SECURITY_PATH=y
        #CONFIG_SECURITY_TOMOYO=y
        #CONFIG_SECURITY_TOMOYO_POLICY_LOADER="/usr/bin/tomoyo-init"
        #CONFIG_SECURITY_TOMOYO_ACTIVATION_TRIGGER="/usr/lib/systemd/systemd"
        #CONFIG_LSM="landlock,lockdown,yama,integrity,tomoyo,bpf"

        #Diff between nixos kernel and github xanmod kernel is:
        SECURITY_TOMOYO = yes;
        SECURITY_TOMOYO_MAX_ACCEPT_ENTRY = "2048";
        SECURITY_TOMOYO_MAX_AUDIT_LOG = "1024";
        SECURITY_TOMOYO_POLICY_LOADER = "/sbin/tomoyo-init"; #probably need to adapt for nixos
        SECURITY_TOMOYO_ACTIVATION_TRIGGER = "/sbin/init"; #systemd as arch wiki suggest instead here?

        #Conflicted about this one. In xamod it's 0xa, in nixos xanmod + override it's 0x1
        RANDOMIZE_MEMORY_PHYSICAL_PADDING = "0xa";

        #Performance
        # NO_HZ: Reducing Scheduling-Clock Ticks: https://www.kernel.org/doc/Documentation/timers/NO_HZ.txt
        # This can can reduce the number of scheduling-clock interrupts, thereby improving energy
        # efficiency and reducing OS jitter.  Reducing OS jitter is important for
        # some types of computationally intensive high-performance computing (HPC)
        # applications and for real-time applications.
        # It was disabled for some reason in nixos xanmod by default. Laptop maybe don't wanna this?
        NO_HZ_IDLE = yes;

        #Optimization for x86_64-v3 processors. Just passing flags is not enough. The only difference between x86_64-v1 and x86_64-v3 xanmod github configs is this entry:
        GENERIC_CPU3 = yes; # this should optimize kernel for all x86_64-v3 cpu's I think.
        #Can be also are option:
        MZEN3 = yes; # For exact processor family. In my case is ZEN3. #https://github.com/CachyOS/linux-cachyos/blob/6.8.8/linux-cachyos-echo/configure
        PROCESSOR_SELECT = yes; #this entry exist in xanmod github config, but not in xanmod nixos.

        #DMA-BUF. DMA-BUF crucial for gpu video stuff performance and this was disabled?
        DMABUF_MOVE_NOTIFY = yes;
        DMABUF_HEAPS = yes;
        DMABUF_HEAPS_SYSTEM = yes;
        #for reference this is what enabled in cachyos kernel:
        # DMABUF options
        CONFIG_SYNC_FILE = yes;
        # CONFIG_SW_SYNC is not set
        CONFIG_UDMABUF = yes;
        # CONFIG_DMABUF_MOVE_NOTIFY is not set
        # CONFIG_DMABUF_DEBUG is not set
        # CONFIG_DMABUF_SELFTESTS is not set
        CONFIG_DMABUF_HEAPS = yes;
        CONFIG_DMABUF_SYSFS_STATS = yes;
        CONFIG_DMABUF_HEAPS_SYSTEM = yes;
        CONFIG_DMABUF_HEAPS_CMA = yes;
        # end of DMABUF options

        #It's more system stability than performance.
        RCU_CPU_STALL_TIMEOUT = "60"; # it was set to 24, but xanmod github using 60.
        RCU_CPU_STALL_CPUTIME = yes; # it was disabled.

        #Misc
        #what is this? It was set to 6 in my case.
        NODES_SHIFT = "10";

        #Disabled. Why?
        MEDIA_COMMON_OPTIONS = yes;
      };
    }
  ];
}
