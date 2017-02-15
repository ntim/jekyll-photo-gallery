require 'exifr'
require 'rmagick'

module Jekyll

  class GalleryFile < StaticFile
    def write(dest)
      return false
    end
  end

  class GalleryPhoto
    def initialize(site, base, basepath, name)
      @site = site
      @base = base
      @name = name
      @basepath = basepath
      @path = File.join(basepath, name)
      # Create symlink in site destination.
      create_symlink
      # Read exif data.
      @exif = read_exif
      # Fetch date time field from exif data.
      @date_time = nil
      if !@exif.nil?
        @date_time = @exif[:date_time]
      end
      # Create thumbnail.
      @thumbnail = create_thumbnail
    end

    def create_symlink
      link_src = @site.in_source_dir(@path)
      link_dest = @site.in_dest_dir(@path)
      link_dest_basepath = @site.in_dest_dir(@basepath)
      # Delete existing static asset.
      @site.static_files.delete_if { |sf|
        sf.relative_path == "/#{@path}"
      }
      # Add new entry which prevents writing.
      @site.static_files << GalleryFile.new(@site, @base, @basepath, @name)
      # Create symlink in file system.
      if File.exists?(link_dest)
        # Correct link already exists.
        if File.readlink(link_dest) == link_src
          return
        end
        File.delete(link_dest)
      end
      puts "Creating symlink for #{@path}"
      # Create symlink
      FileUtils.mkdir_p(link_dest_basepath, :mode => 0755)
      File.symlink(link_src, link_dest)
    end

    def create_thumbnail
      config = @site.config["photo_gallery"] || {}
      thumbnail_size = config["thumbnail_size"] || 256
      # Compile thumbnail path
      thumb_dir = File.join(@site.dest, @basepath, "thumbs")
      thumb = File.join(thumb_dir, @name)
      thumb_name = File.join("thumbs", @name)
      # Add thumbnail to static assets
      @site.static_files << GalleryFile.new(@site, @base, thumb_dir, @name)
      # Create if it does not exist.
      FileUtils.mkdir_p(thumb_dir, :mode => 0755)
      if File.exists?(thumb)
        return thumb_name
      end
      begin
        puts "Creating thumbnail for #{@path}"
        # Read image.
        img = Magick::Image.read(@path).first
        # Resize Flickr style
        img = img.resize_to_fill(thumbnail_size, thumbnail_size)
        # Write thumbnail
        img.write(thumb)
      rescue Exception => e
        puts "Error generating thumbnail for #{@path}: #{e}"
        puts e.backtrace
        thumb_name = nil
      end
      thumb_name
    end

    def read_exif
      exif = nil
      begin
        exif = EXIFR::JPEG.new(@path).to_hash
      rescue EXIFR::MalformedJPEG
        puts "No EXIF data in #{@path}"
      rescue Exception => e
        puts "Error reading EXIF data for #{@path}: #{e}"
      end
      exif
    end

    def to_liquid
      {
        'name' => @name,
        'date_time' => @date_time,
        'thumbnail' => @thumbnail,
        'exif' => @exif.nil? ? nil : @exif.collect{|k,v| [k.to_s, v]}.to_h
      }
    end

    def to_s
      @path
    end

  end

  class GalleryPage < Page

    def discover 
      photos = []
      image_extensions = [".png", ".jpg", ".jpeg", ".gif"]
      Dir.foreach(@dir) do |item|
        # Skip files with wrong extension
        next unless item.downcase().end_with?(*image_extensions)
        photos << GalleryPhoto.new(@site, @base, @dir, item)
      end
      photos
    end

    def initialize(site, base, dir, name, parent=nil)
      @site = site
      @base = base
      @dir  = dir
      @name = 'index.html'

      self.process(@name)
      # Read template
      @path = File.realpath(File.join(File.dirname(__FILE__), "jekyll-photo-gallery.html"))
      self.read_yaml(File.dirname(@path), File.basename(@path))

      # Only display root page
      if parent.nil?
        name = "Photos"
        self.data["title"] = name
      end
      self.data["title_deferred"] = name
      self.data["parent"] = parent
      self.data["photos"] = discover
      self.data["children"] = []

      Jekyll::Hooks.trigger :pages, :post_init, self
    end
  end

  class GalleryGenerator < Generator
    safe true

    def is_empty(path)
      Dir["#{path}/*"].empty?
    end

    def iterate(site, basepath, parent)
      galleries = []
      Dir.foreach(basepath) do |item|
        # Skip . and ..
        next if item == '.' or item == '..'
        # Complete path
        path = File.join(basepath, item)
        # Skip if not a directory
        next if !File.directory?(path)
        # Skip if directory is empty
        next if is_empty(path)
        # Create gallery
        puts "Generating gallery \"#{path}\" ..."
        gallery = GalleryPage.new(site, site.source, path, item, parent)
        site.pages << gallery
        galleries << gallery
        # Descend into the directory
        iterate(site, path, gallery)
      end
      if !parent.nil?
        parent.data["children"] = galleries
      end
      galleries
    end

    def generate(site)
      # Get configuration option.
      config = site.config["photo_gallery"] || {}
      path = config["path"] || "photos"
      original_dir = Dir.getwd
      # Change into the photo gallery directory.
      Dir.chdir(site.source)
      begin
        puts "Generating galleries ..."
        gallery = GalleryPage.new(site, site.source, path, path)
        site.pages << gallery
        iterate(site, path, gallery)
      rescue Exception => e
        puts "Error generating galleries: #{e}"
        puts e.backtrace
      end
      # Change back.
      Dir.chdir(original_dir)
    end
  end

end