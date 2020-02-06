using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = true
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(joinpath(prefix, "lib/mariadb"), "libmariadb", :libmariadb),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaBinaryWrappers/MariaDB_Connector_C_jll.jl/releases/download/MariaDB_Connector_C-v3.1.6+0"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/MariaDB_Connector_C.v3.1.6.aarch64-linux-gnu.tar.gz", "b6830355349db7be798e39737a76f75a4102cb42fddc26606c95422e81e0f285"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/MariaDB_Connector_C.v3.1.6.arm-linux-gnueabihf.tar.gz", "81bf9b79ff9c65f17d9874dbca7d8be27b6ea0e393f60c03bf330f23de5d02bc"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/MariaDB_Connector_C.v3.1.6.i686-linux-gnu.tar.gz", "453171c1547e3bbebbaf9bfcaaf3041b4e089f69117d1398bc0a7f1b74a73d91"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/MariaDB_Connector_C.v3.1.6.i686-linux-musl.tar.gz", "c016d0c0b6a35d958273933e66fa46cb19534862c534e33a9aa9b8b6d48cc029"),
    Windows(:i686) => ("$bin_prefix/MariaDB_Connector_C.v3.1.6.i686-w64-mingw32.tar.gz", "622603fa261d6622cfc4dd95a37b0759c9a083f7ee885a024ae496c4199b4e79"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/MariaDB_Connector_C.v3.1.6.powerpc64le-linux-gnu.tar.gz", "692abdddd35d0c10424564e79b437f3921e3267fbec7b2fcb96ae8bbca3585f8"),
    MacOS(:x86_64) => ("$bin_prefix/MariaDB_Connector_C.v3.1.6.x86_64-apple-darwin14.tar.gz", "fca6b653463e043c23d9e58fa0d8a6916634b24c550b9f16f891a81112f080a3"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/MariaDB_Connector_C.v3.1.6.x86_64-linux-gnu.tar.gz", "0f0d8fa127f2174c577e6f628cf50e1c3ae8b150426ecabddca6fe18e9ea9ca1"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/MariaDB_Connector_C.v3.1.6.x86_64-linux-musl.tar.gz", "ef6f3bc1828cd3c096d55b9cf36e905a75af22fe7569907faf69e3d8bd033122"),
    FreeBSD(:x86_64) => ("$bin_prefix/MariaDB_Connector_C.v3.1.6.x86_64-unknown-freebsd11.1.tar.gz", "be9b691b6c662bd76c4463d269e7d035c692963b175485ce0ab5e9e5683a3fa5"),
    Windows(:x86_64) => ("$bin_prefix/MariaDB_Connector_C.v3.1.6.x86_64-w64-mingw32.tar.gz", "d2e06d7915a4dac009ced2e1e69ca7635dbd92f146564abe34922839f3a834db"),
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

# for path in readdir(joinpath(@__DIR__, "usr", "lib", "mariadb"))
#     println("checking if should move $path")
#     if isfile(joinpath(@__DIR__, "usr", "lib", "mariadb", path))
#         println("moving $path")
#         mv(joinpath(@__DIR__, "usr", "lib", "mariadb", path), joinpath(@__DIR__, "usr", "lib", path); force=true)
#     end
# end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)