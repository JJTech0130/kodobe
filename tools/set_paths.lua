package.path = ";./koreader/?.lua;./koreader/?/init.lua" .. package.path
-- added so busted works properly...
package.path = ";./dependencies/?.lua;./dependencies/?/init.lua" .. package.path
package.path = package.path .. ";/nix/store/zkrzg214ca7rzrglm068ilpg03hqhl6j-luajit-2.1.0-2022-04-05-env/share/lua/5.1/?.lua;/nix/store/zkrzg214ca7rzrglm068ilpg03hqhl6j-luajit-2.1.0-2022-04-05-env/share/lua/5.1/?/init.lua"
package.cpath = package.cpath .. ";/nix/store/zkrzg214ca7rzrglm068ilpg03hqhl6j-luajit-2.1.0-2022-04-05-env/lib/lua/5.1/?.so"