require "middleman-core"

::Middleman::Extensions.register(:aldo) do
  require "middleman-aldo/extension"
  ::Middleman::AldoExtension
end
