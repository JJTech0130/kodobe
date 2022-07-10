### Testing without KOReader
I have included some stubs in the `koreader` directory.
Use set_paths.lua to add it to the search path.

```sh
lua -l set_paths ./main.lua
```

You will also need to install luasocket and luasec installed with luarocks.

### Acknowledgements
OpenSSL FFI bindings for Lua were modified from https://github.com/fffonion/lua-resty-openssl.

xml2lua is from https://github.com/manoelcampos/xml2lua