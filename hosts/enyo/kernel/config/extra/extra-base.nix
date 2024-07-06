{lib, ...}: let
  inherit (lib.kernel) yes no freeform;
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.modules) mkForce;
in {
  boot.kernelPatches = [
    {
      name = "extra-base";
      patch = null;
      extraStructuredConfig = mapAttrs (_: mkForce) {
        # https://github.com/CachyOS/linux-cachyos/blob/master/linux-cachyos-bore/config cachyos config for reference.
        # https://github.com/CachyOS/linux-cachyos/blob/master/linux-cachyos-hardened/config cachyos hardened.
        # https://github.com/xanmod/linux/blob/6.9/CONFIGS/xanmod/gcc/config_x86-64-v3 xanmod git kernel config.

        ### Performance
        ## https://cateee.net/lkddb/web-lkddb/NO_HZ_FULL.html
        ## https://www.kernel.org/doc/Documentation/timers/NO_HZ.txt
        ## https://www.suse.com/c/cpu-isolation-introduction-part-1/

        # NO_HZ: Reducing Scheduling-Clock Ticks:
        # This can can reduce the number of scheduling-clock interrupts, thereby improving energy
        # efficiency and reducing OS jitter.  Reducing OS jitter is important for
        # some types of computationally intensive high-performance computing (HPC)
        # applications and for real-time applications."
        NO_HZ_IDLE = yes; # Enabled in xanmod git kernel.

        NO_HZ_FULL = yes; # CachyOS using
        # NO_HZ_FULL:Full dynticks system ( Tickless).
        # By default, without passing the boot.kernelParams, this behaves just like NO_HZ_IDLE, so we can safely use NO_HZ_FULL instead of NO_HZ_IDLE.

        # As for example, my AMD 5900 have two CCX. In theory, I should leave 1 or 2 cores in each CCX for doing "housekeeping" workload as state in "suse" guide.
        # By default, core 0 always will be reserved, even if I pass boot.kernelParams ["nohz_full=0-11"]. Question is: how should I treat hyperthreading cores?
        # For example lstopo output: lstopo-no-graphics --no-factorize --of txt show, that on CCX0 this cores allocated: P#0,P#1,P#2,P#3,P#4,P#5,P#12,P#13,P#14,P#15,P#16,P#17. P#12 hyperthreading core of P#0 and so on.
        # Should I treat hyperthreading core as "separate" core in terms of doing "housekeeping" workload, or better set "physical" cores only for doing such work?

        # In any case, for #gaming I probably want to make sure, that CPU "bottlenecked" games use only cpu-cores ( "physical" probably? ) that reside on one CCX, in order to avoid latency penalty, because of communication between two CCX.
        # Is it worth it? I'll test it one day.. I don't expecting big improvement like I would get from "X3D" cpu, but still.
        # Poor windows gamers nuking one CCX in order to get more FPS in CS:GO.
        # AMD ****X3D cpu's not affected by that, because of big shared! L3 cache for all cores. Double digits performance improvement compared to non X3D cpu's in games ( depend on game obv ). Building from source as for example don't get such compile speed improvement at all.

        # Optimization for x86_64-v3 processors.
        GENERIC_CPU3 = yes;
        # We can also enable compiler optimizations for AMD generation instead.
        MZEN3 = yes; # for zen3 for example.

        ### LTO. Clang only?
        ## LTO - Link Time Optimization
        ## https://cateee.net/lkddb/web-lkddb/LTO_CLANG_FULL.html
        ## https://clang.llvm.org/docs/ThinLTO.html
        # Sadly, there there is no LTO support for GCC for now. I tried to apply old patches from cachyos for GCC-LTO, but without success.
        LTO_NONE = no; # if yes, build the kernel normally, without Link Time Optimization (LTO).
        LTO_CLANG_FULL = yes; # This option enables Clang's full Link Time Optimization (LTO), which allows the compiler to optimize the kernel globally. During link time, this option can use a large amount of RAM, and may take much longer than the ThinLTO option.
        # LTO_CLANG_THIN = yes; # This option enables Clang's ThinLTO, which allows for parallel optimization and faster incremental compiles compared to the LTO_CLANG_FULL option. More information can be found from Clang's documentation
        LTO = yes;
        LTO_CLANG = yes;
        ARCH_SUPPORTS_LTO_CLANG = yes;
        ARCH_SUPPORTS_LTO_CLANG_THIN = yes;

        ### PGO. Profile-guided optimization
        ## https://yaoguopku.github.io/papers/Yuan-ScienceChina-18.pdf
        ## https://github.com/NixOS/nixpkgs/pull/112928
        ## https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/terminal-emulators/foot/default.nix
        ## https://github.com/NixOS/nixpkgs/commit/1f7e2f44372053bcf6293ba5938ca76f02757391
        ## https://github.com/ZaMaZaN4iK/awesome-pgo?tab=readme-ov-file
        ## https://lists.freedesktop.org/archives/mesa-dev/2020-February/224096.html
        ## https://wiki.gentoo.org/wiki/GCC_optimization#Profile_Guided_Optimization_.28PGO.29
        ## https://github.com/h0tc0d3/linux_pgo
        ## https://lpc.events/event/7/contributions/771/attachments/630/1193/Exploring_Profile_Guided_Optimization_of_the_Linux_Kernel.pdf

        # Profile guided optimization (PGO) consists of compiling and profiling a program to assess hot paths in the code. Optimizations are then applied based on this analysis.
        # Provide in some cases double digits performance imporvement. For example, compiled GCC with PGO do ~7-12%! compilations faster, than without it.
        # In Microsoft presentation, imporvement was 5-20% for Linux Kernel ( presentation sucks tbh. No explanation about how they make LTO work with GCC ).
        # NixOS decided to disabled PGO in GCC. edolstra: "Slowing down every C/C++ build by 7-12% is a substantial price to pay..." and "However from the perspective of content-addressable Nix, a deterministic GCC is certainly a lot better.". Ouch.
        # However, some packages compiled with PGO in NixOS: firefox and foot terminal atleast. Maybe more? Google also compile chrome with PGO.
        # PGO also synergize well with LTO. More in "mesa-dev" discussion for example.
        # Sounds amazing, but here are thing: We need compile package first with "profiling and debugging" support -> use app ( kernel in our case ) and do what you usually do ( longer is better ) in order to get profilling data -> feed this data to compiler.
        # From my understanding, we need to do this once, then we can just feed this data every rebuild.
        # Obviosly, I'm not gonna recompile every package, but I'm already compile from source linux kernel, so why not?
        # Need dig a bit later on this. I managed to compile linux kernel with clang with LTO already ( for some reason 18 clang give me error on compile, so 17 clang for now).
        # I need to verify myself this performance claims. I'll give are shot LTO+PGO on linux kernel soon..
        # Can Hyprland benefit from this?
        # I'm also tempted by mesa discussion...

        ### DMABUF
        ## https://www.kernelconfig.io/config_dmabuf_heaps?arch=x86&kernelversion=6.9.7
        ## https://www.kernelconfig.io/CONFIG_DMABUF_HEAPS_CMA?q=DMABUF_HEAPS_CMA&kernelversion=6.9.7&arch=x86
        ## https://cateee.net/lkddb/web-lkddb/DMABUF_MOVE_NOTIFY.html

        # Who knows why "heaps" was disabled by default.
        DMABUF_HEAPS = yes;
        DMABUF_HEAPS_SYSTEM = yes; # Enabled in cachyos/xanmod git configs.
        DMABUF_HEAPS_CMA = yes; # Disabled in xanmod github config. Enabled in cachyos.
        DMABUF_MOVE_NOTIFY = yes; # Security. Probably reason why it's disabled in cachyos kernel, because of "we don't yet have a consistent execution context and memory management between drivers".  Enabled in xanmod github config.

        ### Memory Management options
        ## ZSWAP
        ZSWAP_SHRINKER_DEFAULT_ON = yes; # https://cateee.net/lkddb/web-lkddb/ZSWAP_SHRINKER_DEFAULT_ON.html. Good thing overall, no? Enabled in cachyos/xanmod github config.
        ZSWAP_COMPRESSOR_DEFAULT_LZ4 = yes; # cachyos and nixos kernel use zstd instead. Xanmod github use LZ4.
        ZSWAP_COMPRESSOR_DEFAULT = "lz4"; # above.
        ZSWAP_ZPOOL_DEFAULT_Z3FOLD = yes; # NixOS xanmod and cachyos using zmalloc. Xanmod github kernel using z3fold.
        # https://www.kernel.org/doc/html/v5.0/vm/z3fold.html
        # https://www.kernel.org/doc/html/v5.5/vm/zsmalloc.html
        ZSWAP_ZPOOL_DEFAULT = "z3fold"; # above.
        Z3FOLD = yes; # above.
        ZSWAP_DEFAULT_ON = yes; # enabled in cachyos.
        ZSMALLOC_STAT = yes; # enabled in cachyos. Monitoring and debuging stuff.

        ### ZRAM
        # ZRAM by default enabled as module which is correct, because it allows changing number of zram devices without rebooting, by deactivating zram devices and re-loading module with new parameters.
        # Options below for some reasons was disabled in nixos xanmod, but xanmod github and cachyos bore + hardened enabling them.
        ZRAM_TRACK_ENTRY_ACTIME = yes;
        ZRAM_MEMORY_TRACKING = yes; # Track ZRAM block status.
        # Enabled in xanmod github. LZO instead of "zstd".
        ZRAM_DEF_COMP_LZORLE = yes;
        ZRAM_DEF_COMP = "lzo-rle";

        ## TMPFS
        TMPFS_INODE64 = yes; # https://docs.kernel.org/filesystems/tmpfs.html Also: https://chrisdown.name/2021/07/02/tmpfs-inode-corruption-introducing-inode64.html
        TMPFS_QUOTA = yes; # QUOTA support.
      };
    }
  ];
}
