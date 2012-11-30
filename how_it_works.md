Running `ichiban` on the terminal invokes `Command.new` and `Command#run`. `#run` switches on the first
command-line argument. When the argument is `watch`, `#run` calls `Watcher.new` and `Watcher#start`.

# `Watcher#start`

`Watcher#start` uses the Listen gem. It calls `Listen#start`, which accepts a block. The block
is executed whenever something changes, and it takes three parameters: `modified`, `added`, and
`removed`, each of which is an array.

# `File` Class

You can call `Ichiban::File.from_abs` on any absolute path, and it will return an instance of the
appropriate subclass of `File`. For example, an SCSS file in `assets/css` will result in an
instance of `SCSSFile`. Depending on the type of file, you may be able to call `dest` on this
instance to get an absolute path in the `compiled` directory.

Every instance of `File` also responds to `update`. This method does whatever is needed to write
the final file(s) to the `compiled` directory. So, for files that just need to be copied over without
modification, such as images, `compiled` just copies. Likewise, for HTML files, it compiles them
and then writes the compiled string. Some subclasses of `File` delegate this process to another
helper class; this is just to avoid bloating the `File` class.