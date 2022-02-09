# Generally here needs to be symbolic links created for shared libraries to function and be managed by the OS properly. To accomplish this you can use the commands:

$ ln -s libJPClibs.so.1.0.0 libJPClibs.so
$ ln -s libJPClibs.so.1.0.0 libJPClibs.so.1
$ ln -s libJPClibs.so.1.0.0 libJPClibs.so.1.0


# With that, an (ls -la) should result in something similar to this:

lrwxrwxrwx 1 User User libJPClibs.so -> libJPClibs.so.1.0.0
lrwxrwxrwx 1 User User libJPClibs.so.1 -> libJPClibs.so.1.0.0
lrwxrwxrwx 1 User User libJPClibs.so.1.0 -> libJPClibs.so.1.0.0
-rwxrwxr-x 1 User User libJPClibs.so.1.0.0

