class MailBud::Gui::WinMain
	def initialize
		#@gui = Gtk::Builder.new
		#@gui.add_from_file("gui/win_main.ui")
		#@gui.connect_signals(){|handler|method(handler)}
		
		@emails_count = 0
		
		@icon = Gtk::StatusIcon.new
		updatePixMaps
		@icon.visible = true
		
		@icon.signal_connect("activate") do
			on_statusicon_activate
		end
		
		@icon.signal_connect("popup-menu") do
			tha_items = [
				[_("Accounts"), [self, "on_accounts_activate"]],
				[_("Options"), [self, "on_options_activate"]]
			]
			
			if @timeout
				tha_items << [_("Stop"), [self, "on_stop_activate"]]
			else
				tha_items << [_("Start"), [self, "on_start_activate"]]
			end
			
			tha_items << [_("Quit"), [self, "on_quit_activate"]]
			
			tha_menu = Knj::Gtk2::Menu.new({"items" => tha_items})
		end
		
		if Knj::Opts.get("autostart") == "1"
			on_start_activate
		end
	end
	
	def updatePixMaps
		fn_noemail = Knj::Opts.get("icon_noemail")
		if fn_noemail and fn_noemail.length > 0 and File.exist?(fn_noemail) and File.file?(fn_noemail)
			@pbuf_noemail = Gdk::Pixbuf.new(fn_noemail)
		else
			@pbuf_noemail = Gdk::Pixbuf.new("gfx/xfce-nomail.png")
		end
		
		fn_unreademail = Knj::Opts.get("icon_unreademail")
		if fn_unreademail and fn_unreademail.length > 0 and File.exist?(fn_noemail) and File.file?(fn_unreademail)
			@pbuf_email = Gdk::Pixbuf.new(fn_unreademail)
		else
			@pbuf_email = Gdk::Pixbuf.new("gfx/xfce-newmail.png")
		end
		
		@icon.pixbuf = @pbuf_noemail
	end
	
	#def on_window_destroy
	#	Gtk.main_quit
	#end
	
	def on_quit_activate
		Gtk.main_quit
	end
	
	def on_options_activate
		MailBud::Gui::WinOptions.new
	end
	
	def on_accounts_activate
		MailBud::Gui::WinAccounts.new
	end
	
	def on_statusicon_activate
		execute = Knj::Opts.get("execute")
		if execute and execute.length > 0
			Thread.new do
				system(execute + "&")
			end
		end
	end
	
	def on_start_activate
		Thread.new do
			begin
				checkEmail
				
        time = Knj::Opts.get("time").to_i
        time = 60 if time <= 0
        
				@timeout = GLib::Timeout.add(time * 1000) do
					Thread.new do
						checkEmail
					end
				end
			rescue => e
				puts e.inspect
				puts e.backtrace
			end
		end
	end
	
	def on_stop_activate
		if @timeout
			Gtk.timeout_remove(@timeout)
			@timeout = nil
			@icon.pixbuf = @pbuf_noemail
		end
	end
	
	def checkEmail
		begin
			newemails = []
			newemails_count = 0
			newemails_string = ""
			
			f_gaccounts = $db.select("accounts") do |d_gaccounts|
				debugputs "Checking for new email..."
				
				begin
					if d_gaccounts["ssl"].to_s == "1"
						sslval = true
					else
						sslval = false
					end
					
					debugputs "SSL: #{sslval}"
					
					debugputs("Connecting to account: #{d_gaccounts[:host]}")
					if d_gaccounts[:protocol] == "imap"
						conn = Net::IMAP.new(d_gaccounts[:host], d_gaccounts[:port].to_i, sslval)
					else
						conn = Net::POP.new(d_gaccounts[:host], d_gaccounts[:port].to_i, sslval)
					end
					
					debugputs("Logging in.")
					begin
						conn.login(d_gaccounts[:username], d_gaccounts[:password])
					rescue Net::IMAP::NoResponseError => e
						print "Could not log in on the account: #{d_gaccounts[:host]}: #{e.message}"
					end
					
          debugputs "Checking folders..."
					d_gaccounts[:folders].split(",").each do |foldername|
            debugputs "Checking folder: #{foldername}"
            
						folders_count = 0
						foldername = foldername.strip
						folder_ob = nil
						
						begin
							folder_ob = conn.examine(foldername)
						rescue Net::IMAP::NoResponseError => e
							puts "Could not open folder: #{foldername}: #{e.message}"
						end
						
						if folder_ob
							begin
								emails = conn.search(["NOT", "SEEN"])
								newemails_count += emails.count
								folders_count += emails.count
							rescue => e
								puts e.inspect
								puts e.backtrace
							end
						end
						
						if folders_count > 0
							if newemails_string.length > 0
								newemails_string += "\n\n"
							end
							
							newemails_string += "Folder \"#{foldername.gsub("INBOX.", "")}\" has #{folders_count} unread emails."
						end
					end
					
					conn.logout
					conn.disconnect
				rescue => e
					puts sprintf(_("Could not check account for unread emails: %s."), d_gaccounts["host"])
					puts e.inspect
					puts e.backtrace
				end
			end
			
			if newemails_count > 0
				@icon.pixbuf = @pbuf_email
			else
				@icon.pixbuf = @pbuf_noemail
			end
			
			if newemails_count > 0 and newemails_count != @emails_count and newemails_string.length > 0
				@emails_count = newemails_count
				@icon.tooltip = newemails_string
				
				Knj::Notify.send(
					"title" => _("New emails"),
					"msg" => newemails_string
				)
				
				runcommand = Knj::Opts.get("runcommand")
				if runcommand.length > 0
					Thread.new do
						system("#{runcommand} &")
					end
				end
			elsif newemails_count == 0
				@icon.tooltip = _("No unread emails.")
			end
		rescue => e
			puts e.inspect
			puts e.backtrace
		end
	end
end