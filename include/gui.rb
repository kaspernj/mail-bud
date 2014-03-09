class MailBud::Gui
  def self.const_missing(name)
    require_relative "../windows/#{StringCases.camel_to_snake(name)}"
    raise "Still not loaded: #{name}", LoadError unless MailBud::Gui.const_defined?(name)
    return MailBud::Gui.const_get(name)
  end
end
