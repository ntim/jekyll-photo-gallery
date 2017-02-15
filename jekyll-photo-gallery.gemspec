Gem::Specification.new do |spec|
  spec.name        = "jekyll-photo-gallery"
  spec.summary     = "Yet another jekyll photo gallery generator with thumbnails."
  spec.version     = "1.0.0"
  spec.authors     = ["Tim Niggemann"]
  spec.email       = "niggemann.tim@googlemail.com"
  spec.homepage    = "https://github.com/ntim/jekyll-photo-gallery"
  spec.licenses    = ["GPL-3.0"]

  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = ["lib"]

  spec.requirements << "imagemagick, >=v6.9 (needed by RMagick)"

  spec.add_runtime_dependency "exifr", "~> 1.2"
  spec.add_runtime_dependency "rmagick", "~> 2.12"

  spec.add_development_dependency "jekyll", "~> 2.0"
  spec.add_development_dependency "bundler", "~> 1.6"
end