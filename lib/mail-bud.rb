class ::Object
  # Used to translate strings without poluting global namespace.
  def _(str)
    return GetText.str
  end
end

class MailBud
  # Autoloader for subclasses to avoid slowing upstart and writing tons of requires.
  def self.const_missing(name)
    require_relative "../include/#{StringCases.camel_to_snake(name)}"
    raise "Still not loaded: #{name}", LoadError unless MailBud.const_defined?(name)
    return MailBud.const_get(name)
  end
end
