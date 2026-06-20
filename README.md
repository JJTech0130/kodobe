## This project is unfinished

You can try to use https://github.com/Leseratte10/acsm-calibre-plugin with Calibre on your PC, then transferring the resulting book to KOReader.

See https://github.com/JJTech0130/kodobe/issues/1 for the details.

---

### Testing without KOReader
I have included some stubs in the `koreader` directory.
Use set_paths.lua to add it to the search path.

```sh
lua -l set_paths ./adobe/main.lua
```

You will also need to install `luasocket` and `luasec` installed using luarocks.

### Acknowledgements
+ OpenSSL FFI bindings were modified from https://github.com/fffonion/lua-resty-openssl.
+ `xml2lua` is from https://github.com/manoelcampos/xml2lua.
