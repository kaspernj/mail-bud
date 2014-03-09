class MailBud::Gui::WinOptions
	def initialize
		@gui = Gtk::Builder.new
		@gui.add_from_file("gui/win_options.ui")
		@gui.connect_signals(){|handler|method(handler)}
		@gui.translate
		
		updateOpts
		
		@gui.get_object("window").show_all
	end
	
	def updateOpts
		if Knj::Opts::get("autostart") == "1"
			@gui.get_object("cbAutoStart").active = true
		else
			@gui.get_object("cbAutoStart").active = false
		end
		
		icon_noemail = Knj::Opts.get("icon_noemail")
		if icon_noemail and icon_noemail.length > 0
			@gui.get_object("fcIconNoEmail").filename = icon_noemail
		else
			@gui.get_object("fcIconNoEmail").filename = ""
		end
		
		icon_unreademail = Knj::Opts.get("icon_unreademail")
		if icon_unreademail and icon_unreademail.length > 0
			@gui.get_object("fcIconUnreadEmail").filename = icon_unreademail
		else
			@gui.get_object("fcIconUnreadEmail").filename = ""
		end
		
		@gui.get_object("txtTime").text = Knj::Opts.get("time")
		@gui.get_object("txtExecute").text = Knj::Opts.get("execute")
		@gui.get_object("txtRunCommand").text = Knj::Opts.get("runcommand")
		
		$win_main.updatePixMaps
	end
	
	def on_btnSave_clicked
		Knj::Opts::set("time", @gui.get_object("txtTime").text)
		Knj::Opts::set("execute", @gui.get_object("txtExecute").text)
		Knj::Opts::set("runcommand", @gui.get_object("txtRunCommand").text)
		
		if @gui.get_object("cbAutoStart").active?
			Knj::Opts.set("autostart", "1")
		else
			Knj::Opts.set("autostart", "0")
		end
		
		fn_noemail = @gui.get_object("fcIconNoEmail").filename
		if fn_noemail and fn_noemail.length > 0 and File.exist?(fn_noemail) and File.file?(fn_noemail)
			Knj::Opts.set("icon_noemail", fn_noemail)
		else
			Knj::Opts.set("icon_noemail", "")
		end
		
		fn_unreademail = @gui.get_object("fcIconUnreadEmail").filename
		if fn_unreademail and fn_unreademail.length > 0 and File.exist?(fn_unreademail) and File.file?(fn_unreademail)
			Knj::Opts.set("icon_unreademail", fn_unreademail)
		else
			Knj::Opts.set("icon_unreademail", nil)
		end
		
		updateOpts
	end
	
	def on_btnCancel_clicked
		@gui.get_object("window").destroy
	end
	
	def on_btnIconNoEmailDelete_clicked
		@gui.get_object("fcIconNoEmail").filename = ""
	end
	
	def on_btnUnreadEmailDelete_clicked
		@gui.get_object("fcIconUnreadEmail").filename = ""
	end
end