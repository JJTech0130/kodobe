with import <nixpkgs> {};

luajit.withPackages (ps: [ ps.luacheck ps.luasocket ps.luasec ps.lua-resty-openssl])
