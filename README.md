# jekyll-photo-gallery


[![Gem Version](https://img.shields.io/gem/v/jekyll-photo-gallery.svg)](https://rubygems.org/gems/jekyll-photo-gallery)

Yet another jekyll photo gallery.

This [Jekyll plugin](http://jekyllrb.com/docs/plugins/) generates galleries from directories containing images recursively. Thumbnails are created using [rmagick](http://rmagick.rubyforge.org/).

## Usage

1. Install the `jekyll-photo-gallery` gem by e.g. adding `gem 'jekyll-photo-gallery'` to your `Gemfile` and running `bundle install`.

2. Add `jekyll-gallery-generator` to the gems list in your `_config.yml`:

    ```
gems:
  - jekyll-photo-gallery
```

3. Copy your images to your jekyll site. The directory structure should be as follows:

    ```
% tree
.
|- photos
 |- 2016 
  |- 2016-12-24 Christmas
   |- image1.jpg
   |- image2.jpg
   |- ...
  |- 2016-12-31 New years eve
 |- 2015
  |- ...
```

    An infinite depth of recursion is supported. Folders are allowed to contain both images and folders. The original files are made available in the `_site` directory using symbolic links.


## Configuration

Configure the plugin in your  `_config.yml`:

```
photo_gallery:
  path: photos
  thumbnail_size: 256
```

The thumbnails are generated as squares with the [resize_to_fill](https://rmagick.github.io/image3.html#resize_to_fill) method and saved in `_site` inside the mirrored folder structure of `path`.

## Templating

All important html elements of the generated photo gallery have dedicated CSS classes which can be used for styling or incorporating a javascript photo slideshow script.
