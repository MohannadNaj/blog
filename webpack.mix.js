let mix = require('laravel-mix');

mix.copyDirectory('node_modules/noto-sans-arabic/fonts', 'static/fonts')

mix.copyDirectory('node_modules/noto-sans-arabic/css', 'static/css')

mix.copy('node_modules/@fontsource/ibm-plex-sans-arabic/index.css', 'static/fonts/ibm-plex-sans-arabic.css')

mix.copyDirectory('node_modules/@fontsource/ibm-plex-sans-arabic/files', 'static/fonts/files')

mix.options({ manifest: false })
