require 'compass'
require 'zurb-foundation'
require 'awestruct_ext'
require 'tagger_patch'
require 'sass_functions'
require 'slim'

Awestruct::Extensions::Pipeline.new do
  engine = Awestruct::Engine.instance
  transformer Awestruct::Extensions::Minify.new([:js,:html])
end
