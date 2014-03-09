class MailBud::Gui::WinAccounts
	def initialize
		require "knj/gtk2_tv"
		require "knj/gtk2_cb"
		
		@gui = Gtk::Builder.new
		@gui.add_from_file("gui/win_accounts.ui")
		@gui.connect_signals{ |handler| method(handler) }
		@gui.translate
		
		@tv_accounts = @gui.get_object("tvAccounts")
		@tv_accounts.init([_("ID"), _("Host")])
		@tv_accounts.columns[0].visible = false
		@tv_accounts.selection.signal_connect("changed") do |selection|
			on_tvAccounts_changed
		end
		
		@cb_protocol = @gui.get_object("cbProtocol")
		@cb_protocol.init(["IMAP", "POP3"])
		
		updateAccounts
		on_tvAccounts_changed
		
		@gui.get_object("window").show_all
	end
	
	def updateAccounts
		@tv_accounts.model.clear
		
		f_gaccounts = $db.select("accounts", nil, {"orderby" => "host"}) do |d_gaccounts|
			@tv_accounts.append [d_gaccounts[:id], d_gaccounts[:host]]
		end
	end
	
	def on_tvAccounts_changed
		sel = @tv_accounts.sel
		@gui.get_object("cbSSL").active = false
		@cb_protocol.active = 0
		
		if !sel
			@gui.get_object("txtHost").text = ""
			@gui.get_object("txtPort").text = ""
			@gui.get_object("txtUsername").text = ""
			@gui.get_object("txtPassword").text = ""
			@gui.get_object("txtFolders").text = ""
			@gui.get_object("cbSSL").active = false
		else
			account_data = $db.single("accounts", "id" => sel[0])
      
			@gui.get_object("txtHost").text = account_data[:host]
			@gui.get_object("txtPort").text = account_data[:port].to_s
			@gui.get_object("txtUsername").text = account_data[:username]
			@gui.get_object("txtPassword").text = account_data[:password]
			@gui.get_object("txtFolders").text = account_data[:folders]
			
			if account_data[:ssl] == "1"
				@gui.get_object("cbSSL").active = true
			end
			
			if account_data[:protocol] == "pop3"
				@cb_protocol.active = 1
			end
		end
	end
	
	def on_btnSave_clicked
		sel = @tv_accounts.sel
		
		save_arr = {
			"host" => @gui.get_object("txtHost").text,
			"port" => @gui.get_object("txtPort").text,
			"username" => @gui.get_object("txtUsername").text,
			"password" => @gui.get_object("txtPassword").text,
			"folders" => @gui.get_object("txtFolders").text
		}
		
		if @gui.get_object("cbSSL").active?
			save_arr["ssl"] = "1"
		else
			save_arr["ssl"] = "0"
		end
		
		if @cb_protocol.active == 1
			save_arr["protocol"] = "pop3"
		else
			save_arr["protocol"] = "imap"
		end
		
		if !sel
			$db.insert("accounts", save_arr)
		else
			$db.update("accounts", save_arr, "id" => sel[0])
		end
		
		updateAccounts
	end
	
	def on_btnDelete_clicked
		
	end
end