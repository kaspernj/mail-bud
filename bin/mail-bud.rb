#!/usr/bin/ruby

Dir.chdir("#{File.dirname(__FILE__)}/../")

require_relative "../lib/mail-bud"
require "rubygems"
require "knjrbfw"
require "string-cases"
require "baza"

require "knj/autoload"
require "knj/gtk2"
Gtk

#Load config.
homedir = Knj::Os.homedir

data_dir = homedir + "/.mail-bud"
db_fn = homedir + "/.mail-bud/mail-bud.sqlite3"

if !File.exists?(data_dir)
	puts _("Making config-dir in home...")
	FileUtils.mkdir_p(data_dir)
end

#Load database.
$db = Baza::Db.new(
	:type => "sqlite3",
	:path => db_fn
)

rev = Baza::Revision.new
rev.init_db(:schema => MailBud::DbSchema::SCHEMA, :db => $db)

Knj::Opts.init("knjdb" => $db)


#Load arguments.
$opts = {
  "debug" => false
}
lang = ENV["LANG"]
ARGV.each do |arg|
	match = arg.match(/^--(.+)=(.+)$/)
  key = match[1]
  value = match[2]
	
	if key == "--help"
		print "Possible arguments:\n"
		print "   --language=da_DK\n"
		print "   --help\n"
		print "\n"
		exit
  else
    $opts[key] = value
  end
end

#Load locales.
if lang
	ENV["LANGUAGE"] = lang
	GetText.bindtextdomain("locales", "locales", lang)
end

#Load debug functions.
def debugputs(string)
	if ($opts["debug"])
		puts string
	end
end


#Start application.
$win_main = MailBud::Gui::WinMain.new
Gtk.main
