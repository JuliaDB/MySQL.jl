using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, "libmbedcrypto", :libmbedcrypto),
    LibraryProduct(prefix, "libmbedx509", :libmbedx509),
    LibraryProduct(prefix, "libmbedtls", :libmbedtls),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaBinaryWrappers/MbedTLS_jll.jl/releases/download/MbedTLS-v2.16.0+1"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/MbedTLS.v2.16.0.aarch64-linux-gnu.tar.gz", "19367fffbef2f97f341921859689f8327ce92de5a2949d292f216e7a1be811cf"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/MbedTLS.v2.16.0.aarch64-linux-musl.tar.gz", "7a2e6c5bc629f30c88c85b3489d8d4d0a2443d990694ebcee664e292445ad4db"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/MbedTLS.v2.16.0.arm-linux-gnueabihf.tar.gz", "8b13b81cc8afcfea77d10112011bca9fa4658f0da0d715325b48ddd9a793ef16"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/MbedTLS.v2.16.0.arm-linux-musleabihf.tar.gz", "24bdc7677a0b6fb6d0683008788caa2de5d1ddd28b147ed373bf007f7ebebff2"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/MbedTLS.v2.16.0.i686-linux-gnu.tar.gz", "5f36bd1c2a095067b6e3c45e834fec0072ecd210ea8ba152cc5e57ae974ddf53"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/MbedTLS.v2.16.0.i686-linux-musl.tar.gz", "0deb57307a9fe0bf5232b79e7d8991d3b1ac9ceb1837b770c0176204f49d4bfa"),
    Windows(:i686) => ("$bin_prefix/MbedTLS.v2.16.0.i686-w64-mingw32.tar.gz", "bb11966c4c39774ef714b3fb2e70aa9f74bd8a9c812a1596f336b24649dc360c"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/MbedTLS.v2.16.0.powerpc64le-linux-gnu.tar.gz", "202effd53c1aaa2592adcd20d2c83af6ec145d2bbd6acab30f293084fe14b6a9"),
    MacOS(:x86_64) => ("$bin_prefix/MbedTLS.v2.16.0.x86_64-apple-darwin14.tar.gz", "280b760ed78bc29d9a2ab468495735213cc6a209228c6aa972aeda05d7bb7a6a"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/MbedTLS.v2.16.0.x86_64-linux-gnu.tar.gz", "73eb0a2f588d2724f56db1f69e7acd2e7862655db96477c3588b488c310ead59"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/MbedTLS.v2.16.0.x86_64-linux-musl.tar.gz", "28df3a27d12ba39d6ee5981ea4595356ad23857261076694be100932a675812f"),
    FreeBSD(:x86_64) => ("$bin_prefix/MbedTLS.v2.16.0.x86_64-unknown-freebsd11.1.tar.gz", "02d032806f93fd43995df61dccb56444ff0505d1f80ad45344145d50d0a1367c"),
    Windows(:x86_64) => ("$bin_prefix/MbedTLS.v2.16.0.x86_64-w64-mingw32.tar.gz", "a1a78af0bd5b994aa837d784db2df67d4c0ffa373bf69888614a5c37120f415e"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)