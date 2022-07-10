In order to test this on your local machine, you need to install the dependencies.

Simplest method is Nix:
```nix
nix-env -if ./build.nix
```

Then run
```sh
lua ./main.lua
```
and
```sh
luacheck ./main.lua
```

OpenSSL bindings for Lua were taken from https://github.com/fffonion/lua-resty-openssl.

xml2lua is from https://github.com/manoelcampos/xml2lua

Note about ffi/sha2: it comes for KOReader and should be removed in the final plugin, it's just for local testing...